import '../../utils/formatacao.dart';

class Sala {
  const Sala({
    this.id,
    required this.nome,
    required this.predioId,
    required this.capacidade,
  });

  factory Sala.fromJson(Map<String, dynamic> json) => Sala(
        id: json['id'] as String?,
        nome: json['nomeSala'] as String,
        predioId: json['predioId'] as String,
        capacidade: json['capacidade'] as int,
      );

  final String? id;

  final String nome;

  final String predioId;

  final int capacidade;

  String get capacidadeFormatada => contarItens(capacidade, 'lugar', 'lugares');

  Sala copyWith({
    String? id,
    String? nome,
    String? predioId,
    int? capacidade,
  }) =>
      Sala(
        id: id ?? this.id,
        nome: nome ?? this.nome,
        predioId: predioId ?? this.predioId,
        capacidade: capacidade ?? this.capacidade,
      );

  Map<String, dynamic> toJson() => {
        'nomeSala': nome,
        'predioId': predioId,
        'capacidade': capacidade,
      };
}
