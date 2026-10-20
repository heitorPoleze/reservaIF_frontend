import 'perfil.dart';
import 'servidor.dart';

class Professor extends Servidor {
  const Professor({
    super.id,
    required super.nome,
    super.email,
    super.telefone,
    required super.departamento,
    required super.siape,
  }) : super(perfil: Perfil.professor);

  Professor.fromJson(Map<String, dynamic> json)
      : super.deJson(json, Perfil.professor);

  Professor copyWith({
    String? id,
    String? nome,
    String? email,
    String? telefone,
    String? departamento,
    String? siape,
  }) =>
      Professor(
        id: id ?? this.id,
        nome: nome ?? this.nome,
        email: email ?? this.email,
        telefone: telefone ?? this.telefone,
        departamento: departamento ?? this.departamento,
        siape: siape ?? this.siape,
      );
}
