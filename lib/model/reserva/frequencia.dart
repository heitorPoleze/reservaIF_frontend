import '../enum_json.dart';

enum Frequencia {
  unica('UNICA', 'Única'),
  semanal('SEMANAL', 'Semanal'),
  quinzenal('QUINZENAL', 'Quinzenal'),
  mensal('MENSAL', 'Mensal');

  const Frequencia(this.valorJson, this.rotulo);

  final String valorJson;

  final String rotulo;

  static Frequencia fromJson(Object? json) =>
      enumDoJson(values, (frequencia) => frequencia.valorJson, json);

  String toJson() => valorJson;
}
