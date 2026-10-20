import 'perfil.dart';
import 'usuario.dart';
import 'usuario_resumo.dart';

class Coordenacao extends Usuario {
  const Coordenacao({
    super.id,
    required super.nome,
    required super.email,
    super.telefone,
    this.coordenador,
    required this.departamento,
  }) : super(perfil: Perfil.coordenador);

  Coordenacao.fromJson(Map<String, dynamic> json)
      : coordenador = UsuarioResumo.fromJsonOpcional(json['coordenador']),
        departamento = json['departamento'] as String,
        super.deJson(json, Perfil.coordenador);

  final UsuarioResumo? coordenador;

  final String departamento;

  Coordenacao copyWith({
    String? id,
    String? nome,
    String? email,
    String? telefone,
    UsuarioResumo? coordenador,
    String? departamento,
  }) =>
      Coordenacao(
        id: id ?? this.id,
        nome: nome ?? this.nome,
        email: email ?? this.email,
        telefone: telefone ?? this.telefone,
        coordenador: coordenador ?? this.coordenador,
        departamento: departamento ?? this.departamento,
      );

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        if (coordenador != null) 'coordenadorId': coordenador?.id,
        'departamento': departamento,
      };
}
