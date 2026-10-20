import 'tipo_credencial.dart';

class UsuarioResumo {
  const UsuarioResumo({
    required this.id,
    required this.nome,
    this.tipoCredencial,
  });

  factory UsuarioResumo.fromJson(Map<String, dynamic> json) => UsuarioResumo(
        id: json['id'] as String,
        nome: json['nome'] as String,
        tipoCredencial: json['tipoCredencial'] == null
            ? null
            : TipoCredencial.fromJson(json['tipoCredencial']),
      );

  static UsuarioResumo? fromJsonOpcional(Object? json) => json == null
      ? null
      : UsuarioResumo.fromJson(json as Map<String, dynamic>);

  final String id;

  final String nome;

  final TipoCredencial? tipoCredencial;

  bool get ehAluno => tipoCredencial == TipoCredencial.matriculaAluno;
}
