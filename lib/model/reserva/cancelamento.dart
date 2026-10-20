import '../../utils/datas.dart';
import '../../utils/formatacao.dart';

class Cancelamento {
  const Cancelamento({
    required this.canceladoPorId,
    required this.justificativa,
    required this.canceladoEm,
  });

  factory Cancelamento.fromJson(Map<String, dynamic> json) => Cancelamento(
        canceladoPorId: json['canceladoPorId'] as String,
        justificativa: json['justificativa'] as String,
        canceladoEm: lerInstanteDoJson(json['canceladoEm'])!,
      );

  static Cancelamento? fromJsonOpcional(Object? json) =>
      json == null ? null : Cancelamento.fromJson(json as Map<String, dynamic>);

  final String canceladoPorId;

  final String justificativa;

  final DateTime canceladoEm;

  String get canceladoEmFormatado => formatarDataEHora(canceladoEm);
}
