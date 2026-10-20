class Predio {
  const Predio({this.id, required this.nome});

  factory Predio.fromJson(Map<String, dynamic> json) => Predio(
        id: json['id'] as String?,
        nome: json['nome'] as String,
      );

  final String? id;

  final String nome;

  Predio copyWith({String? id, String? nome}) =>
      Predio(id: id ?? this.id, nome: nome ?? this.nome);

  Map<String, dynamic> toJson() => {'nome': nome};
}
