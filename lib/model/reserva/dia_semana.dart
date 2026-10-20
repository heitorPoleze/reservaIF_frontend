import '../enum_json.dart';

enum DiaSemana {
  domingo('DOMINGO', 'Domingo'),
  segunda('SEGUNDA', 'Segunda-feira'),
  terca('TERCA', 'Terça-feira'),
  quarta('QUARTA', 'Quarta-feira'),
  quinta('QUINTA', 'Quinta-feira'),
  sexta('SEXTA', 'Sexta-feira'),
  sabado('SABADO', 'Sábado');

  const DiaSemana(this.valorJson, this.rotulo);

  final String valorJson;

  final String rotulo;

  static DiaSemana de(DateTime data) => values[data.weekday % DateTime.daysPerWeek];

  static DiaSemana fromJson(Object? json) =>
      enumDoJson(values, (dia) => dia.valorJson, json);

  String toJson() => valorJson;
}
