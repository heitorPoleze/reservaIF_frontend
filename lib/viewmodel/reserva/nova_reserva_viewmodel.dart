import 'package:flutter/foundation.dart';
import 'package:reserva_if/model/reserva/horario_do_dia.dart';
import 'package:reserva_if/model/reserva/reserva.dart';
import 'package:reserva_if/model/reserva/resultado_criacao_reserva.dart';
import 'package:reserva_if/model/sala/sala.dart';
import 'package:reserva_if/model/usuario/perfil.dart';
import 'package:reserva_if/model/usuario/perfil_usuario.dart';
import 'package:reserva_if/model/usuario/servidor_resumo.dart';
import 'package:reserva_if/model/usuario/usuario_resumo.dart';
import 'package:reserva_if/services/services_reserva.dart';
import 'package:reserva_if/services/services_usuario.dart';
import 'package:reserva_if/viewmodel/estado_de_carga.dart';
import 'package:reserva_if/viewmodel/notifica_se_vivo_mixin.dart';

class NovaReservaViewModel extends ChangeNotifier
    with NotificaSeVivoMixin, EstadoDeCarregamentoMixin {
  NovaReservaViewModel({
    required this.horario,
    required this.sala,
    required this.usuario,
    required this._service,
    required this._serviceUsuario,
  });

  static const perfisDeResponsavel = [
    Perfil.coordenador,
    Perfil.professor,
    Perfil.tecnico,
  ];

  final HorarioDoDia horario;
  final Sala sala;
  final PerfilUsuario usuario;
  final ServicesReserva _service;
  final ServicesUsuario _serviceUsuario;

  late final EstadoDeCarga _cargaServidores = EstadoDeCarga(
    aoMudar: notificarSeVivo,
  );

  List<ServidorResumo> _servidores = const [];
  ServidorResumo? _responsavel;

  bool get exigeResponsavel => usuario.perfil.exigeResponsavel;

  List<ServidorResumo> servidoresDo(Perfil perfil) => [
    for (final servidor in _servidores)
      if (servidor.perfil == perfil) servidor,
  ];

  ServidorResumo? get responsavel => _responsavel;

  bool get isCarregandoServidores => _cargaServidores.isLoading;

  String? get mensagemErroServidores => _cargaServidores.mensagemErro;

  Future<void> carregarServidores() {
    if (!exigeResponsavel || isCarregandoServidores) return Future.value();

    return _cargaServidores.executar(
      chamada: () async =>
          _servidores = await _serviceUsuario.buscarServidores(),
      aoFalhar: () {},
    );
  }

  void selecionarResponsavel(ServidorResumo? servidor) {
    _responsavel = servidor;
    notificarSeVivo();
  }

  Future<ResultadoCriacaoReserva?> reservar({
    required String justificativa,
    required String observacoes,
  }) {
    if (isLoading) return Future.value();

    final responsavel = exigeResponsavel ? _responsavel?.resumo : usuario.resumo;
    if (responsavel == null) return Future.value();

    final reserva = _montarReserva(
      responsavel,
      justificativa.trim(),
      observacoes.trim(),
    );

    return cargaPrincipal.executar<ResultadoCriacaoReserva?>(
      chamada: () => _service.solicitar(reserva),
      aoFalhar: () => null,
    );
  }

  Reserva _montarReserva(
    UsuarioResumo responsavel,
    String finalidade,
    String observacoes,
  ) => Reserva(
    sala: sala,
    solicitante: usuario.resumo,
    responsavel: responsavel,
    inicio: horario.inicio,
    fim: horario.fim,
    finalidade: finalidade.isEmpty
        ? Reserva.finalidadeNaoInformada
        : finalidade,
    observacoes: observacoes.isEmpty ? null : observacoes,
  );
}
