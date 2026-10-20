import 'package:flutter/foundation.dart';
import 'package:reserva_if/model/reserva/reserva.dart';
import 'package:reserva_if/model/usuario/perfil_usuario.dart';
import 'package:reserva_if/model/usuario/perfil.dart';
import 'package:reserva_if/services/services_reserva.dart';
import 'package:reserva_if/viewmodel/estado_de_carga.dart';
import 'package:reserva_if/viewmodel/notifica_se_vivo_mixin.dart';

class ReservasPerfilViewModel extends ChangeNotifier
    with NotificaSeVivoMixin, EstadoDeCarregamentoMixin {
  ReservasPerfilViewModel({required this.usuario, required this.service});

  final PerfilUsuario usuario;
  final ServicesReserva service;

  List<Reserva> _solicitadas = const [];
  List<Reserva> _sobMinhaResponsabilidade = const [];

  List<Reserva> get solicitadas => _solicitadas;

  List<Reserva> get sobMinhaResponsabilidade => _sobMinhaResponsabilidade;

  bool get podeVerResponsabilidades => usuario.perfil != Perfil.aluno;

  Future<void> carregar() {
    if (isLoading) return Future.value();

    return cargaPrincipal.executar(
      chamada: () async {
        final resultados = await Future.wait([
          service.buscarSolicitadas(),
          if (podeVerResponsabilidades)
            service.buscarSobMinhaResponsabilidade(),
        ]);
        _solicitadas = resultados.first;
        _sobMinhaResponsabilidade = podeVerResponsabilidades
            ? resultados.last
            : const [];
      },
      aoFalhar: () {},
    );
  }
}
