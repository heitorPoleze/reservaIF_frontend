import 'package:reserva_if/model/reserva/reserva.dart';
import 'package:reserva_if/model/usuario/perfil_usuario.dart';
import 'package:reserva_if/services/services_reserva.dart';
import 'package:reserva_if/viewmodel/estado_de_carga.dart';
import 'package:reserva_if/viewmodel/notifica_se_vivo_mixin.dart';
import 'package:reserva_if/viewmodel/reserva/reservas_mudaram.dart';

mixin AnaliseDeReservaMixin on NotificaSeVivoMixin {
  PerfilUsuario get usuario;

  ServicesReserva get serviceReserva;

  ReservasMudaram get reservasMudaram;

  late final EstadoDeCarga _cargaAnalise = EstadoDeCarga(
    aoMudar: notificarSeVivo,
  );

  bool get isAnalisando => _cargaAnalise.isLoading;

  String? get mensagemErroAnalise => _cargaAnalise.mensagemErro;

  bool podeAnalisar(Reserva reserva) => reserva.analisavelPor(usuario);

  Future<bool> aprovar(Reserva reserva) =>
      _analisar(() => serviceReserva.aprovar(reserva.id!));

  Future<bool> rejeitar(Reserva reserva, String motivo) =>
      _analisar(() => serviceReserva.rejeitar(reserva.id!, motivo.trim()));

  Future<bool> _analisar(Future<Reserva> Function() chamadaAoServico) {
    if (isAnalisando) return Future.value(false);

    return _cargaAnalise.executar(
      chamada: () async {
        await chamadaAoServico();
        reservasMudaram.invalidar();
        return true;
      },
      aoFalhar: () => false,
    );
  }
}
