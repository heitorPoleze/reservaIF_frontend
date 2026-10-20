import 'usuario.dart';

abstract class Servidor extends Usuario {
  const Servidor({
    super.id,
    required super.nome,
    super.email,
    super.telefone,
    required super.perfil,
    required this.departamento,
    required this.siape,
  });

  Servidor.deJson(super.json, super.perfil)
      : departamento = json['departamento'] as String,
        siape = json['siape'] as String,
        super.deJson();

  final String departamento;

  final String siape;

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'departamento': departamento,
        'siape': siape,
      };
}
