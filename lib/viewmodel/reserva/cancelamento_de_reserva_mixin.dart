import 'package:reserva_if/model/reserva/modo_cancelamento.dart';
import 'package:reserva_if/model/reserva/reserva.dart';
import 'package:reserva_if/model/reserva/resultado_cancelamento.dart';
import 'package:reserva_if/model/usuario/perfil_usuario.dart';
import 'package:reserva_if/services/services_cancelamento.dart';
import 'package:reserva_if/services/services_reserva.dart';
import 'package:reserva_if/viewmodel/estado_de_carga.dart';
import 'package:reserva_if/viewmodel/notifica_se_vivo_mixin.dart';
import 'package:reserva_if/viewmodel/reserva/reservas_mudaram.dart';

mixin CancelamentoDeReservaMixin on NotificaSeVivoMixin {
  PerfilUsuario get usuario;

  ServicesReserva get serviceReserva;

  ServicesCancelamento get serviceCancelamento;

  ReservasMudaram get reservasMudaram;

  late final EstadoDeCarga _cargaCancelamento = EstadoDeCarga(
    aoMudar: notificarSeVivo,
  );

  bool get isCancelando => _cargaCancelamento.isLoading;

  String? get mensagemErroCancelamento => _cargaCancelamento.mensagemErro;

  ModoCancelamento? modoDeCancelamento(Reserva reserva) =>
      reserva.modoDeCancelamentoPara(usuario);

  Future<ResultadoCancelamento?> cancelar(
    Reserva reserva,
    ModoCancelamento modo,
    String justificativa,
  ) {
    if (isCancelando) return Future.value();

    return _cargaCancelamento.executar(
      chamada: () async {
        final resultado = await _enviarCancelamento(
          reserva.id!,
          modo,
          justificativa.trim(),
        );
        reservasMudaram.invalidar();
        return resultado;
      },
      aoFalhar: () => null,
    );
  }

  Future<ResultadoCancelamento> _enviarCancelamento(
    String idReserva,
    ModoCancelamento modo,
    String justificativa,
  ) => switch (modo) {
    ModoCancelamento.cancelar => serviceReserva.cancelar(
      idReserva,
      justificativa,
    ),
    ModoCancelamento.solicitar => serviceCancelamento.solicitarHorario(
      idReserva,
      justificativa,
    ),
  };
}
