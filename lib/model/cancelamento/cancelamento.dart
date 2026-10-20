class Cancelamento {
  const Cancelamento({
    this.id,
    required this.reservaId,
    required this.canceladorId,
    required this.justificativa,
  });

  factory Cancelamento.fromJson(Map<String, dynamic> json) => Cancelamento(
        id: json['id'] as String?,
        reservaId: json['reservaId'] as String,
        canceladorId: json['canceladorId'] as String,
        justificativa: json['justificativa'] as String,
      );

  final String? id;

  final String reservaId;

  final String canceladorId;

  final String justificativa;

  Cancelamento copyWith({
    String? id,
    String? reservaId,
    String? canceladorId,
    String? justificativa,
  }) =>
      Cancelamento(
        id: id ?? this.id,
        reservaId: reservaId ?? this.reservaId,
        canceladorId: canceladorId ?? this.canceladorId,
        justificativa: justificativa ?? this.justificativa,
      );

  Map<String, dynamic> toJson() => {
        'reservaId': reservaId,
        'canceladorId': canceladorId,
        'justificativa': justificativa,
      };
}
