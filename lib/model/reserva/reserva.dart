import '../../utils/datas.dart';
import '../../utils/formatacao.dart';
import 'status_reserva.dart';

class Reserva {
  Reserva({
    this.id,
    required this.inicio,
    required this.fim,
    required this.salaId,
    required this.finalidade,
    this.status = StatusReserva.pendente,
    required this.solicitanteId,
    this.aprovadoPorId,
    this.observacoes,
    this.criadoEm,
    this.aprovadoEm,
  }) {
    if (!fim.isAfter(inicio)) {
      throw ArgumentError.value(fim, 'fim', 'Deve ser posterior ao início');
    }
  }

  Reserva.fromJson(Map<String, dynamic> json)
      : this(
          id: json['id'] as String?,
          inicio: lerInstanteDoJson(json['inicio'])!,
          fim: lerInstanteDoJson(json['fim'])!,
          salaId: json['salaId'] as String,
          finalidade: json['finalidade'] as String,
          status: StatusReserva.fromJson(json['status']),
          solicitanteId: json['solicitanteId'] as String,
          aprovadoPorId: json['aprovadoPorId'] as String?,
          observacoes: json['observacoes'] as String?,
          criadoEm: lerInstanteDoJson(json['criadoEm']),
          aprovadoEm: lerInstanteDoJson(json['aprovadoEm']),
        );

  final String? id;

  final DateTime inicio;

  final DateTime fim;

  final String salaId;

  final String finalidade;

  final StatusReserva status;

  final String solicitanteId;

  final String? aprovadoPorId;

  final String? observacoes;

  final DateTime? criadoEm;

  final DateTime? aprovadoEm;

  String get diaDaSemana => formatarDiaDaSemana(inicio);

  String get periodoFormatado =>
      '${formatarDataBr(inicio)}, ${formatarIntervaloDeHoras(inicio, fim)}';

  Duration get duracao => fim.difference(inicio);

  bool get emAndamento {
    final agora = DateTime.now();

    return status.ocupaSala &&
        !agora.isBefore(inicio) &&
        agora.isBefore(fim);
  }

  bool conflitaCom(Reserva outra) =>
      salaId == outra.salaId &&
      status.ocupaSala &&
      outra.status.ocupaSala &&
      inicio.isBefore(outra.fim) &&
      outra.inicio.isBefore(fim);

  Reserva copyWith({
    String? id,
    DateTime? inicio,
    DateTime? fim,
    String? salaId,
    String? finalidade,
    StatusReserva? status,
    String? solicitanteId,
    String? aprovadoPorId,
    String? observacoes,
    DateTime? criadoEm,
    DateTime? aprovadoEm,
  }) =>
      Reserva(
        id: id ?? this.id,
        inicio: inicio ?? this.inicio,
        fim: fim ?? this.fim,
        salaId: salaId ?? this.salaId,
        finalidade: finalidade ?? this.finalidade,
        status: status ?? this.status,
        solicitanteId: solicitanteId ?? this.solicitanteId,
        aprovadoPorId: aprovadoPorId ?? this.aprovadoPorId,
        observacoes: observacoes ?? this.observacoes,
        criadoEm: criadoEm ?? this.criadoEm,
        aprovadoEm: aprovadoEm ?? this.aprovadoEm,
      );

  Map<String, dynamic> toJson() => {
        'inicio': instanteParaJson(inicio),
        'fim': instanteParaJson(fim),
        'salaId': salaId,
        'finalidade': finalidade,
        'solicitanteId': solicitanteId,
        if (observacoes != null) 'observacoes': observacoes,
      };
}
