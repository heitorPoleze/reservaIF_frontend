import 'perfil.dart';
import 'usuario.dart';

class Coordenacao extends Usuario {
  const Coordenacao({
    super.id,
    required super.nome,
    required super.email,
    super.telefone,
    this.coordenadorId,
    required this.departamento,
  }) : super(perfil: Perfil.coordenador);

  Coordenacao.fromJson(Map<String, dynamic> json)
      : coordenadorId = json['coordenadorId'] as String?,
        departamento = json['departamento'] as String,
        super.deJson(json, Perfil.coordenador);

  final String? coordenadorId;

  final String departamento;

  Coordenacao copyWith({
    String? id,
    String? nome,
    String? email,
    String? telefone,
    String? coordenadorId,
    String? departamento,
  }) =>
      Coordenacao(
        id: id ?? this.id,
        nome: nome ?? this.nome,
        email: email ?? this.email,
        telefone: telefone ?? this.telefone,
        coordenadorId: coordenadorId ?? this.coordenadorId,
        departamento: departamento ?? this.departamento,
      );

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        if (coordenadorId != null) 'coordenadorId': coordenadorId,
        'departamento': departamento,
      };
}
