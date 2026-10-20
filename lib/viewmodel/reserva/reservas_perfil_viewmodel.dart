import 'package:flutter/foundation.dart';
import 'package:reserva_if/model/reserva/reserva.dart';
import 'package:reserva_if/model/reserva/status_reserva.dart';
import 'package:reserva_if/model/usuario/perfil_usuario.dart';
import 'package:reserva_if/model/usuario/perfil.dart';
import 'package:reserva_if/services/services_cancelamento.dart';
import 'package:reserva_if/services/services_reserva.dart';
import 'package:reserva_if/utils/formatacao.dart';
import 'package:reserva_if/viewmodel/estado_de_carga.dart';
import 'package:reserva_if/viewmodel/notifica_se_vivo_mixin.dart';
import 'package:reserva_if/viewmodel/reserva/analise_de_reserva_mixin.dart';
import 'package:reserva_if/viewmodel/reserva/acao_sobre_reserva_mixin.dart';
import 'package:reserva_if/viewmodel/reserva/reservas_mudaram.dart';
import 'package:reserva_if/viewmodel/reserva/sincroniza_reservas_mixin.dart';

class ReservasPerfilViewModel extends ChangeNotifier
    with
        NotificaSeVivoMixin,
        EstadoDeCarregamentoMixin,
        AcaoSobreReservaMixin,
        AnaliseDeReservaMixin,
        SincronizaReservasMixin {
  ReservasPerfilViewModel({
    required this.usuario,
    required this.service,
    required this.serviceCancelamento,
    required this.reservasMudaram,
  });

  @override
  final PerfilUsuario usuario;
  final ServicesReserva service;
  @override
  final ServicesCancelamento serviceCancelamento;
  @override
  final ReservasMudaram reservasMudaram;

  @override
  ServicesReserva get serviceReserva => service;

  @override
  Future<void> recarregarReservas() => carregar();

  List<Reserva> _solicitadas = const [];
  List<Reserva> _sobMinhaResponsabilidade = const [];

  List<Reserva> get solicitadas => _solicitadas;

  List<Reserva> get sobMinhaResponsabilidade => _sobMinhaResponsabilidade;

  List<Reserva> solicitadasCom(StatusReserva status) =>
      _comStatus(_solicitadas, status);

  List<Reserva> sobMinhaResponsabilidadeCom(StatusReserva status) =>
      _comStatus(_sobMinhaResponsabilidade, status);

  static List<Reserva> _comStatus(
    List<Reserva> reservas,
    StatusReserva status,
  ) => [
    for (final reserva in reservas)
      if (reserva.status == status) reserva,
  ];

  String get rotuloDeSolicitados =>
      contarItens(_solicitadas.length, 'solicitado', 'solicitados');

  bool get isAtualizandoReserva => isExecutandoAcao || isAnalisando;

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
