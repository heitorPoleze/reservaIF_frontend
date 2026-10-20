import '../enum_json.dart';
import 'credencial/tipo_entrada.dart';
import 'tipo_credencial.dart';

enum Perfil {
  aluno('ALUNO', 'Aluno'),
  tecnico('TECNICO', 'Técnico'),
  professor('PROFESSOR', 'Professor'),
  coordenador('COORDENADOR', 'Coordenador');

  const Perfil(this.valorJson, this.rotulo);

  final String valorJson;

  final String rotulo;

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

  static Perfil fromJson(Object? json) =>
      enumDoJson(values, (perfil) => perfil.valorJson, json);

  String toJson() => valorJson;
}
