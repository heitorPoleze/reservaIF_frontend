import '../enum_json.dart';
import 'credencial/tipo_entrada.dart';
import 'tipo_credencial.dart';

enum Perfil {
  aluno('ALUNO', 'Aluno', 0),
  tecnico('TECNICO', 'Técnico', 3),
  professor('PROFESSOR', 'Professor', 1),
  coordenador('COORDENADOR', 'Coordenador', 2);

  const Perfil(this.valorJson, this.rotulo, this.nivelAcesso);

  final String valorJson;

  final String rotulo;

  final int nivelAcesso;

  TipoCredencial? get tipoCredencial => switch (this) {
        Perfil.aluno => TipoCredencial.matriculaAluno,
        Perfil.professor => TipoCredencial.siapeDocente,
        Perfil.tecnico => TipoCredencial.siapeTecnico,
        Perfil.coordenador => null,
      };

  TipoEntrada get identificador =>
      this == Perfil.aluno ? TipoEntrada.matricula : TipoEntrada.siape;

  bool get cadastroDisponivel => tipoCredencial != null;

  bool get exigeProvisionamento => tipoCredencial?.ehServidor ?? true;

  bool get vinculaCurso => this == Perfil.aluno;

  bool get podeAprovar => this == Perfil.coordenador;

  static Perfil fromJson(Object? json) =>
      enumDoJson(values, (perfil) => perfil.valorJson, json);

  static Perfil fromNivelAcesso(Object? json) =>
      enumDoJson(values, (perfil) => perfil.nivelAcesso, json);

  String toJson() => valorJson;
}
