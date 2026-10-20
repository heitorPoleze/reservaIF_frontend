import 'package:flutter/foundation.dart';
import 'package:reserva_if/model/reserva/conflito_de_horario.dart';
import 'package:reserva_if/model/reserva/reserva.dart';
import 'package:reserva_if/model/reserva/solicitacao_cancelamento.dart';
import 'package:reserva_if/model/reserva/status_solicitacao_cancelamento.dart';
import 'package:reserva_if/model/usuario/perfil_usuario.dart';
import 'package:reserva_if/model/usuario/servidor_resumo.dart';
import 'package:reserva_if/services/services_cancelamento.dart';
import 'package:reserva_if/services/services_reserva.dart';
import 'package:reserva_if/services/services_usuario.dart';
import 'package:reserva_if/utils/formatacao.dart';
import 'package:reserva_if/viewmodel/estado_de_carga.dart';
import 'package:reserva_if/viewmodel/notifica_se_vivo_mixin.dart';
import 'package:reserva_if/viewmodel/reserva/analise_de_reserva_mixin.dart';
import 'package:reserva_if/viewmodel/reserva/reservas_mudaram.dart';
import 'package:reserva_if/viewmodel/reserva/sincroniza_reservas_mixin.dart';

class PendenciasViewModel extends ChangeNotifier
    with
        NotificaSeVivoMixin,
        EstadoDeCarregamentoMixin,
        AnaliseDeReservaMixin,
        SincronizaReservasMixin {
  PendenciasViewModel({
    required this.usuario,
    required this.service,
    required this.serviceCancelamento,
    required this.serviceUsuario,
    required this.reservasMudaram,
  });

  @override
  final PerfilUsuario usuario;
  final ServicesReserva service;
  final ServicesCancelamento serviceCancelamento;
  final ServicesUsuario serviceUsuario;
  @override
  final ReservasMudaram reservasMudaram;

  @override
  ServicesReserva get serviceReserva => service;

  @override
  Future<void> recarregarReservas() => carregar();

  List<Reserva> _convites = const [];

  List<ConflitoDeHorario> _conflitos = const [];

  List<Reserva> get convites => _convites;

  List<ConflitoDeHorario> get conflitos => _conflitos;

  bool get semPendencias => _convites.isEmpty && _conflitos.isEmpty;

  String get rotuloDeConvites =>
      contarItens(_convites.length, 'convite', 'convites');

  String get rotuloDeConflitos =>
      contarItens(_conflitos.length, 'solicitação', 'solicitações');

  Future<void> carregar() {
    if (isLoading) return Future.value();

    return cargaPrincipal.executar(
      chamada: () async {
        final (reservas, conflitos) = await (
          service.buscarSobMinhaResponsabilidade(),
          _buscarConflitos(),
        ).wait;
        _convites = [
          for (final reserva in reservas)
            if (reserva.analisavelPor(usuario)) reserva,
        ];
        _conflitos = conflitos;
      },
      aoFalhar: () {},
    );
  }

  Future<List<ConflitoDeHorario>> _buscarConflitos() async {
    if (!usuario.resolveConflitosDeHorario) return const [];

    final (solicitacoes, servidores) = await (
      serviceCancelamento.buscarSolicitacoesPendentes(),
      serviceUsuario.buscarServidores(),
    ).wait;
    final pendentes = [
      for (final solicitacao in solicitacoes)
        if (solicitacao.status == StatusSolicitacaoCancelamento.pendente)
          solicitacao,
    ];
    final professores = {
      for (final servidor in servidores) servidor.id: servidor,
    };

    return Future.wait([
      for (final solicitacao in pendentes)
        _montarConflito(solicitacao, professores),
    ]);
  }

  Future<ConflitoDeHorario> _montarConflito(
    SolicitacaoCancelamento solicitacao,
    Map<String, ServidorResumo> professores,
  ) async => ConflitoDeHorario(
    solicitacao: solicitacao,
    reserva: await service.buscarPorId(solicitacao.reservaId),
    professor: professores[solicitacao.solicitadoPorId],
  );
}
