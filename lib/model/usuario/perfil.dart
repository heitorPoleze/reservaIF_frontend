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

  TipoCredencial get tipoCredencial => switch (this) {
    Perfil.aluno => TipoCredencial.matriculaAluno,
    Perfil.professor || Perfil.coordenador => TipoCredencial.siapeDocente,
    Perfil.tecnico => TipoCredencial.siapeTecnico,
  };

  TipoEntrada get identificador =>
      this == Perfil.aluno ? TipoEntrada.matricula : TipoEntrada.siape;

  bool get exigeProvisionamento => tipoCredencial.ehServidor;

  bool get exigeDepartamento => tipoCredencial.ehServidor;

  bool get coordenaPredio => this == Perfil.coordenador;

  bool get podeAprovar => this == Perfil.coordenador;

  bool get solicitaCancelamentoDeAluno => this == Perfil.professor;

  bool get acompanhaPendencias => this != Perfil.aluno;

  bool get exigeResponsavel => this == Perfil.aluno;

  List<Perfil> get perfisDeResponsavel => switch (this) {
    Perfil.aluno => const [Perfil.coordenador, Perfil.professor, Perfil.tecnico],
    Perfil.coordenador => const [Perfil.professor, Perfil.tecnico],
    Perfil.professor || Perfil.tecnico => const [],
  };

  bool get escolheResponsavel => perfisDeResponsavel.isNotEmpty;

  static Perfil fromJson(Object? json) =>
      enumDoJson(values, (perfil) => perfil.valorJson, json);

  static Perfil fromNivelAcesso(Object? json) =>
      enumDoJson(values, (perfil) => perfil.nivelAcesso, json);

  String toJson() => valorJson;
}
