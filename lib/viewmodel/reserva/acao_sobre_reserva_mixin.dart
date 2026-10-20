import 'package:reserva_if/model/reserva/acao_sobre_reserva.dart';
import 'package:reserva_if/model/reserva/reserva.dart';
import 'package:reserva_if/model/reserva/resultado_cancelamento.dart';
import 'package:reserva_if/model/usuario/perfil_usuario.dart';
import 'package:reserva_if/services/services_cancelamento.dart';
import 'package:reserva_if/services/services_reserva.dart';
import 'package:reserva_if/viewmodel/estado_de_carga.dart';
import 'package:reserva_if/viewmodel/notifica_se_vivo_mixin.dart';
import 'package:reserva_if/viewmodel/reserva/reservas_mudaram.dart';

mixin AcaoSobreReservaMixin on NotificaSeVivoMixin {
  PerfilUsuario get usuario;

  ServicesReserva get serviceReserva;

  ServicesCancelamento get serviceCancelamento;

  ReservasMudaram get reservasMudaram;

  late final EstadoDeCarga _cargaDaAcao = EstadoDeCarga(
    aoMudar: notificarSeVivo,
  );

  bool get isExecutandoAcao => _cargaDaAcao.isLoading;

  String? get mensagemErroDaAcao => _cargaDaAcao.mensagemErro;

  AcaoSobreReserva? acaoDisponivel(Reserva reserva) =>
      reserva.acaoDisponivelPara(usuario);

  Future<ResultadoCancelamento?> executarAcao(
    Reserva reserva,
    AcaoSobreReserva acao,
    String justificativa,
  ) {
    if (isExecutandoAcao) return Future.value();

    return _cargaDaAcao.executar(
      chamada: () async {
        final resultado = await _enviarAcao(
          reserva.id!,
          acao,
          justificativa.trim(),
        );
        reservasMudaram.invalidar();
        return resultado;
      },
      aoFalhar: () => null,
    );
  }

  Future<ResultadoCancelamento> _enviarAcao(
    String idReserva,
    AcaoSobreReserva acao,
    String justificativa,
  ) => switch (acao) {
    AcaoSobreReserva.cancelarReserva => serviceReserva.cancelar(
      idReserva,
      justificativa,
    ),
    AcaoSobreReserva.solicitarHorario => serviceCancelamento.solicitarHorario(
      idReserva,
      justificativa,
    ),
  };
}
