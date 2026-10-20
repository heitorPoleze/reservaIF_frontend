import 'package:flutter/foundation.dart';
import 'package:reserva_if/model/predio/predio.dart';
import 'package:reserva_if/model/reserva/horario_do_dia.dart';
import 'package:reserva_if/model/reserva/modo_cancelamento.dart';
import 'package:reserva_if/model/reserva/reserva.dart';
import 'package:reserva_if/model/reserva/resultado_cancelamento.dart';
import 'package:reserva_if/model/sala/sala.dart';
import 'package:reserva_if/model/usuario/perfil_usuario.dart';
import 'package:reserva_if/services/services_predio.dart';
import 'package:reserva_if/services/services_reserva.dart';
import 'package:reserva_if/utils/datas.dart';
import 'package:reserva_if/utils/formatacao.dart';
import 'package:reserva_if/viewmodel/estado_de_carga.dart';
import 'package:reserva_if/viewmodel/notifica_se_vivo_mixin.dart';

class AgendamentoViewModel extends ChangeNotifier
    with NotificaSeVivoMixin, EstadoDeCarregamentoMixin {
  AgendamentoViewModel({
    required this.predio,
    required this.usuario,
    required this._servicePredio,
    required this._serviceReserva,
  });

  final Predio predio;
  final PerfilUsuario usuario;
  final ServicesPredio _servicePredio;
  final ServicesReserva _serviceReserva;

  late final EstadoDeCarga _cargaReservas = EstadoDeCarga(
    aoMudar: notificarSeVivo,
  );

  late final EstadoDeCarga _cargaCancelamento = EstadoDeCarga(
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

  bool get isCancelando => _cargaCancelamento.isLoading;

  String? get mensagemErroCancelamento => _cargaCancelamento.mensagemErro;

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

  ModoCancelamento? modoDeCancelamento(Reserva reserva) =>
      reserva.modoDeCancelamentoPara(usuario);

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

  Future<ResultadoCancelamento?> cancelar(
    Reserva reserva,
    String justificativa,
  ) {
    if (isCancelando) return Future.value();

    return _cargaCancelamento.executar(
      chamada: () async {
        final resultado = await _serviceReserva.cancelar(
          reserva.id!,
          justificativa.trim(),
        );
        await carregarReservas();
        return resultado;
      },
      aoFalhar: () => null,
    );
  }
}
