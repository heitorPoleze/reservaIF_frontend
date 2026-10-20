import '../sala/sala.dart';
import 'endereco.dart';

class Predio {
  const Predio({
    this.id,
    required this.nome,
    this.endereco,
    this.salas = const [],
  });

  factory Predio.fromJson(Map<String, dynamic> json) {
    final resumo = Predio(
      id: json['id'] as String?,
      nome: json['nome'] as String,
      endereco: Endereco.fromJsonOpcional(json['endereco']),
    );
    final salas = json['salas'];

    if (salas is! List) return resumo;

    return resumo.copyWith(
      salas: List<Sala>.unmodifiable(
        salas.map(
          (sala) => Sala.fromJsonDoPredio(sala as Map<String, dynamic>, resumo),
        ),
      ),
    );
  }

  final String? id;

  final String nome;

  final Endereco? endereco;

  final List<Sala> salas;

  Predio copyWith({
    String? id,
    String? nome,
    Endereco? endereco,
    List<Sala>? salas,
  }) =>
      Predio(
        id: id ?? this.id,
        nome: nome ?? this.nome,
        endereco: endereco ?? this.endereco,
        salas: salas ?? this.salas,
      );

  Map<String, dynamic> toJson() => {
        'nome': nome,
        if (endereco != null) 'endereco': endereco?.toJson(),
      };
}
