import 'perfil.dart';
import 'servidor.dart';

class Tecnico extends Servidor {
  const Tecnico({
    super.id,
    required super.nome,
    required super.email,
    super.telefone,
    required super.departamento,
    required super.siape,
  }) : super(perfil: Perfil.tecnico);

  Tecnico.fromJson(Map<String, dynamic> json)
      : super.deJson(json, Perfil.tecnico);

  Tecnico copyWith({
    String? id,
    String? nome,
    String? email,
    String? telefone,
    String? departamento,
    String? siape,
  }) =>
      Tecnico(
        id: id ?? this.id,
        nome: nome ?? this.nome,
        email: email ?? this.email,
        telefone: telefone ?? this.telefone,
        departamento: departamento ?? this.departamento,
        siape: siape ?? this.siape,
      );
}
