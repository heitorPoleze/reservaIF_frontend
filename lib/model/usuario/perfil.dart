import '../enum_json.dart';

enum Perfil {
  aluno('ALUNO', 'Aluno'),
  tecnico('TECNICO', 'Técnico'),
  professor('PROFESSOR', 'Professor'),
  coordenador('COORDENADOR', 'Coordenador');

  const Perfil(this.valorJson, this.rotulo);

  final String valorJson;

  final String rotulo;

  static Perfil fromJson(Object? json) =>
      enumDoJson(values, (perfil) => perfil.valorJson, json);

  String toJson() => valorJson;
}
