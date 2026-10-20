import '../enum_json.dart';

enum TipoRecorrencia {
  unica('UNICA', 'Única'),
  semanal('SEMANAL', 'Semanal'),
  mensal('MENSAL', 'Mensal'),
  semestral('SEMESTRAL', 'Semestral'),
  anual('ANUAL', 'Anual');

  const TipoRecorrencia(this.valorJson, this.rotulo);

  final String valorJson;

  final String rotulo;

  bool get exigeDataFim => this == semanal;

  static TipoRecorrencia fromJson(Object? json) =>
      enumDoJson(values, (tipo) => tipo.valorJson, json);

  String toJson() => valorJson;
}
