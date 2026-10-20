import '../enum_json.dart';

enum TipoRecorrencia {
  unica('UNICA', 'Única', 'Acontece só no dia e horário escolhidos.'),
  semanal(
    'SEMANAL',
    'Semanal',
    'Repete toda semana, nos dias escolhidos, até a data final informada.',
  ),
  mensal(
    'MENSAL',
    'Mensal',
    'Repete 1 vez por semana, no mesmo dia da semana e horário, por 1 mês.',
  ),
  semestral(
    'SEMESTRAL',
    'Semestral',
    'Repete 1 vez por semana, no mesmo dia da semana e horário, por 6 meses.',
  ),
  anual(
    'ANUAL',
    'Anual',
    'Repete 1 vez por semana, no mesmo dia da semana e horário, por 12 meses.',
  );

  const TipoRecorrencia(this.valorJson, this.rotulo, this.descricao);

  final String valorJson;

  final String rotulo;

  final String descricao;

  bool get exigeDataFim => this == semanal;

  static List<TipoRecorrencia> get dispensamDatas => [
    for (final tipo in values)
      if (!tipo.exigeDataFim) tipo,
  ];

  static TipoRecorrencia fromJson(Object? json) =>
      enumDoJson(values, (tipo) => tipo.valorJson, json);

  String toJson() => valorJson;
}
