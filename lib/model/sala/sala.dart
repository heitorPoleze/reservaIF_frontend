import '../../utils/formatacao.dart';
import '../predio/predio.dart';

class Sala {
  const Sala({
    this.id,
    required this.nome,
    required this.predio,
    this.capacidade,
  });

  factory Sala.fromJson(Map<String, dynamic> json) => Sala.fromJsonDoPredio(
        json,
        Predio.fromJson(json['predio'] as Map<String, dynamic>),
      );

  Sala.fromJsonDoPredio(Map<String, dynamic> json, this.predio)
      : id = json['id'] as String?,
        nome = json['nomeSala'] as String,
        capacidade = json['capacidade'] as int?;

  final String? id;

  final String nome;

  final Predio predio;

  final int? capacidade;

  String get nomeComPredio => '$nome · ${predio.nome}';

  String get capacidadeFormatada {
    final lugares = capacidade;

    return lugares == null
        ? 'Capacidade não informada'
        : contarItens(lugares, 'lugar', 'lugares');
  }

  Sala copyWith({
    String? id,
    String? nome,
    Predio? predio,
    int? capacidade,
  }) =>
      Sala(
        id: id ?? this.id,
        nome: nome ?? this.nome,
        predio: predio ?? this.predio,
        capacidade: capacidade ?? this.capacidade,
      );

  Map<String, dynamic> toJson() => {
        'nomeSala': nome,
        'predioId': predio.id,
        if (capacidade != null) 'capacidade': capacidade,
      };
}
