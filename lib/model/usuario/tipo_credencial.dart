import '../enum_json.dart';

enum TipoCredencial {
  matriculaAluno('MATRICULA_ALUNO'),
  siapeDocente('SIAPE_DOCENTE'),
  siapeTecnico('SIAPE_TECNICO');

  const TipoCredencial(this.valorJson);

  final String valorJson;

  bool get ehServidor => this != TipoCredencial.matriculaAluno;

  static TipoCredencial fromJson(Object? json) =>
      enumDoJson(values, (tipo) => tipo.valorJson, json);

  String toJson() => valorJson;
}
