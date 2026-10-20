import 'package:flutter/foundation.dart';
import 'package:reserva_if/model/predio/predio.dart';
import 'package:reserva_if/model/reserva/horario_do_dia.dart';
import 'package:reserva_if/model/reserva/reserva.dart';
import 'package:reserva_if/model/sala/sala.dart';
import 'package:reserva_if/model/usuario/perfil_usuario.dart';
import 'package:reserva_if/services/services_cancelamento.dart';
import 'package:reserva_if/services/services_predio.dart';
import 'package:reserva_if/services/services_reserva.dart';
import 'package:reserva_if/utils/datas.dart';
import 'package:reserva_if/utils/formatacao.dart';
import 'package:reserva_if/viewmodel/estado_de_carga.dart';
import 'package:reserva_if/viewmodel/notifica_se_vivo_mixin.dart';
import 'package:reserva_if/viewmodel/reserva/acao_sobre_reserva_mixin.dart';
import 'package:reserva_if/viewmodel/reserva/reservas_mudaram.dart';
import 'package:reserva_if/viewmodel/reserva/sincroniza_reservas_mixin.dart';

class AgendamentoViewModel extends ChangeNotifier
    with
        NotificaSeVivoMixin,
        EstadoDeCarregamentoMixin,
        AcaoSobreReservaMixin,
        SincronizaReservasMixin {
  AgendamentoViewModel({
    required this.predio,
    required this.usuario,
    required this._servicePredio,
    required this._serviceReserva,
    required this.reservasMudaram,
    required this._serviceCancelamento,
  });

  final Predio predio;
  @override
  final PerfilUsuario usuario;
  final ServicesPredio _servicePredio;
  final ServicesReserva _serviceReserva;
  @override
  final ReservasMudaram reservasMudaram;
  final ServicesCancelamento _serviceCancelamento;

  late final EstadoDeCarga _cargaReservas = EstadoDeCarga(
    aoMudar: notificarSeVivo,
  );

  List<Sala> _salas = const [];
  Sala? _salaSelecionada;
  List<Reserva> _reservas = const [];
  DateTime _diaSelecionado = hoje();

  List<Sala> get salas => _salas;

  Sala? get salaSelecionada => _salaSelecionada;

  List<Reserva> get reservas => _reservas;

  DateTime get diaSelecionado => _diaSelecionado;

  bool get isCarregandoReservas => _cargaReservas.isLoading;

  String? get mensagemErroReservas => _cargaReservas.mensagemErro;

  Set<DateTime> get diasComReserva => {
    for (final reserva in _reservas)
      if (!reserva.status.terminal) apenasData(reserva.inicio),
  };

  List<HorarioDoDia> get horariosDoDia =>
      HorarioDoDia.doDia(_diaSelecionado, _reservas);

  int get quantidadeLivres =>
      horariosDoDia.where((horario) => horario.reservavel()).length;

  String get rotuloLivres => contarItens(quantidadeLivres, 'livre', 'livres');

  String get rotuloDoDiaSelecionado =>
      formatarDiaDaSemanaEDiaDoMes(_diaSelecionado);

  @override
  ServicesReserva get serviceReserva => _serviceReserva;

  @override
  ServicesCancelamento get serviceCancelamento => _serviceCancelamento;

  @override
  Future<void> recarregarReservas() => carregarReservas();

  Future<void> carregarSalas() {
    if (isLoading) return Future.value();

    return cargaPrincipal.executar(
      chamada: () async =>
          _salas = await _servicePredio.buscarSalas(predio.id!),
      aoFalhar: () {},
    );
  }

  Future<void> recarregar() =>
      _salaSelecionada == null ? carregarSalas() : carregarReservas();

  void selecionarSala(Sala? sala) {
    if (sala == null || sala.id == _salaSelecionada?.id) return;

    _salaSelecionada = sala;
    _reservas = const [];
    notificarSeVivo();
    carregarReservas();
  }

  void selecionarDia(DateTime dia) {
    _diaSelecionado = apenasData(dia);
    notificarSeVivo();
  }

  Future<void> carregarReservas() {
    final idSala = _salaSelecionada?.id;
    if (idSala == null) return Future.value();

    bool aindaEhASala() => _salaSelecionada?.id == idSala;

    return _cargaReservas.executar(
      chamada: () async {
        final reservas = await _serviceReserva.buscarPorSala(idSala);
        if (aindaEhASala()) _reservas = reservas;
      },
      aoFalhar: () {},
      aindaVale: aindaEhASala,
    );
  }
}
