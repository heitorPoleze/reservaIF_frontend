import 'package:flutter/foundation.dart';
import 'package:reserva_if/model/reserva/reserva.dart';
import 'package:reserva_if/model/usuario/perfil_usuario.dart';
import 'package:reserva_if/services/services_reserva.dart';
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
    required this.reservasMudaram,
  });

  @override
  final PerfilUsuario usuario;
  final ServicesReserva service;
  @override
  final ReservasMudaram reservasMudaram;

  @override
  ServicesReserva get serviceReserva => service;

  @override
  Future<void> recarregarReservas() => carregar();

  List<Reserva> _convites = const [];

  List<Reserva> get convites => _convites;

  String get rotuloDeConvites =>
      contarItens(_convites.length, 'convite', 'convites');

  Future<void> carregar() {
    if (isLoading) return Future.value();

    return cargaPrincipal.executar(
      chamada: () async {
        final reservas = await service.buscarSobMinhaResponsabilidade();
        _convites = [
          for (final reserva in reservas)
            if (reserva.analisavelPor(usuario)) reserva,
        ];
      },
      aoFalhar: () {},
    );
  }
}
