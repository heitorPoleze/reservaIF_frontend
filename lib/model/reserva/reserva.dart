import '../../utils/datas.dart';
import '../../utils/formatacao.dart';
import '../sala/sala.dart';
import '../usuario/perfil_usuario.dart';
import '../usuario/usuario_resumo.dart';
import 'cancelamento.dart';
import 'modo_cancelamento.dart';
import 'serie_recorrencia.dart';
import 'status_reserva.dart';
import 'tipo_recorrencia.dart';

class Reserva {
  static const finalidadeNaoInformada = 'Não informada';

  Reserva({
    this.id,
    required this.sala,
    required this.solicitante,
    required this.responsavel,
    this.analisadoPor,
    this.serieRecorrencia,
    this.tipoRecorrencia = TipoRecorrencia.unica,
    required this.inicio,
    required this.fim,
    required this.finalidade,
    this.observacoes,
    this.status = StatusReserva.pendente,
    this.motivoRejeicao,
    this.cancelamento,
    this.criadoEm,
    this.aceitoPeloResponsavelEm,
    this.analisadoEm,
  }) {
    if (sala.id == null) {
      throw ArgumentError.value(sala, 'sala', 'Deve estar cadastrada');
    }
    if (!fim.isAfter(inicio)) {
      throw ArgumentError.value(fim, 'fim', 'Deve ser posterior ao início');
    }
  }

  Reserva.fromJson(Map<String, dynamic> json)
    : this(
        id: json['id'] as String?,
        sala: Sala.fromJson(json['sala'] as Map<String, dynamic>),
        solicitante: UsuarioResumo.fromJson(
          json['solicitante'] as Map<String, dynamic>,
        ),
        responsavel: UsuarioResumo.fromJson(
          json['responsavel'] as Map<String, dynamic>,
        ),
        analisadoPor: UsuarioResumo.fromJsonOpcional(json['analisadoPor']),
        serieRecorrencia: SerieRecorrencia.fromJsonOpcional(
          json['serieRecorrencia'],
        ),
        tipoRecorrencia: TipoRecorrencia.fromJson(json['tipoRecorrencia']),
        inicio: lerInstanteDoJson(json['dataHoraInicio'])!,
        fim: lerInstanteDoJson(json['dataHoraFim'])!,
        finalidade: json['finalidade'] as String,
        observacoes: json['observacoes'] as String?,
        status: StatusReserva.fromJson(json['status']),
        motivoRejeicao: json['motivoRejeicao'] as String?,
        cancelamento: Cancelamento.fromJsonOpcional(json['cancelamento']),
        criadoEm: lerInstanteDoJson(json['criadoEm']),
        aceitoPeloResponsavelEm: lerInstanteDoJson(
          json['aceitoPeloResponsavelEm'],
        ),
        analisadoEm: lerInstanteDoJson(json['analisadoEm']),
      );

  final String? id;

  final Sala sala;

  final UsuarioResumo solicitante;

  final UsuarioResumo responsavel;

  final UsuarioResumo? analisadoPor;

  final SerieRecorrencia? serieRecorrencia;

  final TipoRecorrencia tipoRecorrencia;

  final DateTime inicio;

  final DateTime fim;

  final String finalidade;

  final String? observacoes;

  final StatusReserva status;

  final String? motivoRejeicao;

  final Cancelamento? cancelamento;

  final DateTime? criadoEm;

  final DateTime? aceitoPeloResponsavelEm;

  final DateTime? analisadoEm;

  String get diaDaSemana => formatarDiaDaSemana(inicio);

  String get periodoFormatado =>
      '${formatarDataBr(inicio)}, ${formatarIntervaloDeHoras(inicio, fim)}';

  String get dataComDiaDaSemana => formatarDataComDiaDaSemana(inicio);

  String get horarioFormatado => formatarIntervaloDeHoras(inicio, fim);

  String get recorrenciaFormatada {
    final serie = serieRecorrencia;

    return serie == null
        ? tipoRecorrencia.rotulo
        : '${tipoRecorrencia.rotulo}, de ${serie.periodoFormatado}';
  }

  String? get criadoEmFormatado => _formatarInstante(criadoEm);

  String? get analisadoEmFormatado => _formatarInstante(analisadoEm);

  String? get aceitoPeloResponsavelEmFormatado =>
      _formatarInstante(aceitoPeloResponsavelEm);

  static String? _formatarInstante(DateTime? instante) =>
      instante == null ? null : formatarDataEHora(instante);

  Duration get duracao => fim.difference(inicio);

  bool get recorrente => tipoRecorrencia != TipoRecorrencia.unica;

  bool get delegada => responsavel.id != solicitante.id;

  bool get aguardandoAceiteDoResponsavel =>
      status == StatusReserva.pendente &&
      delegada &&
      aceitoPeloResponsavelEm == null;

  bool get emAndamento {
    final agora = DateTime.now();

    return status.ocupaSala && !agora.isBefore(inicio) && agora.isBefore(fim);
  }

  ModoCancelamento? modoDeCancelamentoPara(
    PerfilUsuario usuario, {
    DateTime? agora,
  }) {
    if (status.terminal || !(agora ?? DateTime.now()).isBefore(inicio)) {
      return null;
    }
    if (usuario.podeAprovar || solicitante.id == usuario.uuid) {
      return ModoCancelamento.cancelar;
    }
    if (usuario.solicitaCancelamentoDeAluno && solicitante.ehAluno) {
      return ModoCancelamento.solicitar;
    }
    return null;
  }

  bool analisavelPor(PerfilUsuario usuario) =>
      status == StatusReserva.pendente &&
      delegada &&
      responsavel.id == usuario.uuid;

  bool conflitaCom(Reserva outra) =>
      sala.id == outra.sala.id &&
      status.ocupaSala &&
      outra.status.ocupaSala &&
      inicio.isBefore(outra.fim) &&
      outra.inicio.isBefore(fim);

  Reserva copyWith({
    String? id,
    Sala? sala,
    UsuarioResumo? solicitante,
    UsuarioResumo? responsavel,
    UsuarioResumo? analisadoPor,
    SerieRecorrencia? serieRecorrencia,
    TipoRecorrencia? tipoRecorrencia,
    DateTime? inicio,
    DateTime? fim,
    String? finalidade,
    String? observacoes,
    StatusReserva? status,
    String? motivoRejeicao,
    Cancelamento? cancelamento,
    DateTime? criadoEm,
    DateTime? aceitoPeloResponsavelEm,
    DateTime? analisadoEm,
  }) => Reserva(
    id: id ?? this.id,
    sala: sala ?? this.sala,
    solicitante: solicitante ?? this.solicitante,
    responsavel: responsavel ?? this.responsavel,
    analisadoPor: analisadoPor ?? this.analisadoPor,
    serieRecorrencia: serieRecorrencia ?? this.serieRecorrencia,
    tipoRecorrencia: tipoRecorrencia ?? this.tipoRecorrencia,
    inicio: inicio ?? this.inicio,
    fim: fim ?? this.fim,
    finalidade: finalidade ?? this.finalidade,
    observacoes: observacoes ?? this.observacoes,
    status: status ?? this.status,
    motivoRejeicao: motivoRejeicao ?? this.motivoRejeicao,
    cancelamento: cancelamento ?? this.cancelamento,
    criadoEm: criadoEm ?? this.criadoEm,
    aceitoPeloResponsavelEm:
        aceitoPeloResponsavelEm ?? this.aceitoPeloResponsavelEm,
    analisadoEm: analisadoEm ?? this.analisadoEm,
  );

  Map<String, dynamic> toJson() => {
    'salaId': sala.id,
    'responsavelId': responsavel.id,
    'dataHoraInicio': instanteParaJson(inicio),
    'dataHoraFim': instanteParaJson(fim),
    'finalidade': finalidade,
    if (observacoes != null) 'observacoes': observacoes,
  };
}
