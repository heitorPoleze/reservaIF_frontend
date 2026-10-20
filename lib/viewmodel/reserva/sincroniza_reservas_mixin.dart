import 'package:reserva_if/viewmodel/notifica_se_vivo_mixin.dart';

mixin SincronizaReservasMixin on NotificaSeVivoMixin {
  int? _geracaoVista;

  Future<void> recarregarReservas();

  void sincronizarCom(int geracao) {
    final vista = _geracaoVista;
    _geracaoVista = geracao;

    if (vista == null || vista == geracao || descartado) return;

    recarregarReservas();
  }
}
