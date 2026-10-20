import 'package:flutter/foundation.dart';
import 'package:reserva_if/model/reserva/conflito_de_horario.dart';
import 'package:reserva_if/model/reserva/solicitacao_cancelamento.dart';
import 'package:reserva_if/services/services_cancelamento.dart';
import 'package:reserva_if/viewmodel/estado_de_carga.dart';
import 'package:reserva_if/viewmodel/notifica_se_vivo_mixin.dart';
import 'package:reserva_if/viewmodel/reserva/reservas_mudaram.dart';

class ResolverConflitoViewModel extends ChangeNotifier
    with NotificaSeVivoMixin, EstadoDeCarregamentoMixin {
  ResolverConflitoViewModel({
    required this.conflito,
    required this.service,
    required this.reservasMudaram,
  });

  final ConflitoDeHorario conflito;
  final ServicesCancelamento service;
  final ReservasMudaram reservasMudaram;

  String get _idDaSolicitacao => conflito.solicitacao.idParaDecisao;

  Future<bool> trocar() =>
      _decidir(() => service.aprovarSolicitacao(_idDaSolicitacao));

  Future<bool> declinar() =>
      _decidir(() => service.rejeitarSolicitacao(_idDaSolicitacao));

  Future<bool> _decidir(
    Future<SolicitacaoCancelamento> Function() chamadaAoServico,
  ) {
    if (isLoading) return Future.value(false);

    return cargaPrincipal.executar(
      chamada: () async {
        await chamadaAoServico();
        reservasMudaram.invalidar();
        return true;
      },
      aoFalhar: () => false,
    );
  }
}
