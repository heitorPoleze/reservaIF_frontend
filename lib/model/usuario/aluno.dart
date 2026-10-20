import 'perfil.dart';
import 'usuario.dart';

class Aluno extends Usuario {
  const Aluno({
    super.id,
    required super.nome,
    required super.email,
    super.telefone,
    required this.matricula,
    required this.curso,
  }) : super(perfil: Perfil.aluno);

  Aluno.fromJson(Map<String, dynamic> json)
      : matricula = json['matricula'] as String,
        curso = json['curso'] as String,
        super.deJson(json, Perfil.aluno);

  final String matricula;

  final String curso;

  Aluno copyWith({
    String? id,
    String? nome,
    String? email,
    String? telefone,
    String? matricula,
    String? curso,
  }) =>
      Aluno(
        id: id ?? this.id,
        nome: nome ?? this.nome,
        email: email ?? this.email,
        telefone: telefone ?? this.telefone,
        matricula: matricula ?? this.matricula,
        curso: curso ?? this.curso,
      );

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'matricula': matricula,
        'curso': curso,
      };
}
