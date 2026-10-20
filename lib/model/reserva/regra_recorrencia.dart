import '../../utils/datas.dart';
import 'dia_semana.dart';
import 'tipo_recorrencia.dart';

class RegraRecorrencia {
  const RegraRecorrencia._({
    required this.tipo,
    required this.dataFim,
    required this.diasSemana,
  });

  factory RegraRecorrencia.criar({
    required TipoRecorrencia tipo,
    DateTime? dataFim,
    List<DiaSemana> diasSemana = const [],
  }) {
    if (tipo == TipoRecorrencia.unica) {
      throw ArgumentError.value(tipo, 'tipo', 'Recorrência exige repetição');
    }
    if (tipo.exigeDataFim && dataFim == null) {
      throw ArgumentError.notNull('dataFim');
    }
    if (tipo.exigeDataFim && diasSemana.isEmpty) {
      throw ArgumentError.value(
        diasSemana,
        'diasSemana',
        'Recorrência semanal exige ao menos um dia',
      );
    }

    return RegraRecorrencia._(
      tipo: tipo,
      dataFim: dataFim == null ? null : apenasData(dataFim),
      diasSemana: List.unmodifiable({...diasSemana}),
    );
  }

  final TipoRecorrencia tipo;

  final DateTime? dataFim;

  final List<DiaSemana> diasSemana;

  Map<String, dynamic> toJson() {
    final fim = dataFim;

    return {
      'tipo': tipo.toJson(),
      if (fim != null) 'dataFim': dataParaJson(fim),
      if (diasSemana.isNotEmpty)
        'diasSemana': diasSemana.map((dia) => dia.toJson()).toList(),
    };
  }
}
