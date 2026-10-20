import '../../enum_json.dart';
import '../matricula.dart';
import '../siape.dart';

enum TipoEntrada {
  siape('SIAPE', 'SIAPE'),
  matricula('MATRICULA', 'Matrícula');

  const TipoEntrada(this.valorJson, this.rotulo);

  final String valorJson;

  final String rotulo;

  static TipoEntrada? inferir(String entrada) {
    if (Siape.isValid(entrada)) return TipoEntrada.siape;
    if (Matricula.isValid(entrada)) return TipoEntrada.matricula;
    return null;
  }

  static TipoEntrada fromJson(Object? json) =>
      enumDoJson(values, (tipo) => tipo.valorJson, json);

  String toJson() => valorJson;
}
