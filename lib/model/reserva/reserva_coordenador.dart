import 'frequencia.dart';
import 'reserva.dart';
import 'status_reserva.dart';

class ReservaCoordenador extends Reserva {
  ReservaCoordenador({
    super.id,
    required super.inicio,
    required super.fim,
    required super.salaId,
    required super.finalidade,
    super.status,
    required super.solicitanteId,
    super.aprovadoPorId,
    super.observacoes,
    super.criadoEm,
    super.aprovadoEm,
    required this.frequencia,
  });

  ReservaCoordenador.fromJson(super.json)
      : frequencia = Frequencia.fromJson(json['frequencia']),
        super.fromJson();

  final Frequencia frequencia;

  @override
  ReservaCoordenador copyWith({
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
    Frequencia? frequencia,
  }) =>
      ReservaCoordenador(
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
        frequencia: frequencia ?? this.frequencia,
      );

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'frequencia': frequencia.toJson(),
      };
}
