class UsuarioResumo {
  const UsuarioResumo({required this.id, required this.nome});

  factory UsuarioResumo.fromJson(Map<String, dynamic> json) => UsuarioResumo(
        id: json['id'] as String,
        nome: json['nome'] as String,
      );

  static UsuarioResumo? fromJsonOpcional(Object? json) => json == null
      ? null
      : UsuarioResumo.fromJson(json as Map<String, dynamic>);

  final String id;

  final String nome;
}
