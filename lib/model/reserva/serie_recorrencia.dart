import '../../utils/datas.dart';
import '../../utils/formatacao.dart';
import '../usuario/usuario_resumo.dart';
import 'dia_semana.dart';
import 'tipo_recorrencia.dart';

class SerieRecorrencia {
  const SerieRecorrencia({
    required this.id,
    required this.criadoPor,
    required this.tipoRecorrencia,
    required this.dataInicio,
    required this.dataFim,
    required this.diasSemana,
    required this.criadoEm,
  });

  factory SerieRecorrencia.fromJson(Map<String, dynamic> json) =>
      SerieRecorrencia(
        id: json['id'] as String,
        criadoPor:
            UsuarioResumo.fromJson(json['criadoPor'] as Map<String, dynamic>),
        tipoRecorrencia: TipoRecorrencia.fromJson(json['tipoRecorrencia']),
        dataInicio: lerDataDoJson(json['dataInicio'])!,
        dataFim: lerDataDoJson(json['dataFim'])!,
        diasSemana: List<DiaSemana>.unmodifiable(
          (json['diasSemana'] as List).map(DiaSemana.fromJson),
        ),
        criadoEm: lerInstanteDoJson(json['criadoEm'])!,
      );

  static SerieRecorrencia? fromJsonOpcional(Object? json) => json == null
      ? null
      : SerieRecorrencia.fromJson(json as Map<String, dynamic>);

  final String id;

  final UsuarioResumo criadoPor;

  final TipoRecorrencia tipoRecorrencia;

  final DateTime dataInicio;

  final DateTime dataFim;

  final List<DiaSemana> diasSemana;

  final DateTime criadoEm;

  String get periodoFormatado =>
      '${formatarDataBr(dataInicio)} a ${formatarDataBr(dataFim)}';
}
