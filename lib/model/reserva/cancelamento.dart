import '../../utils/datas.dart';
import '../../utils/formatacao.dart';
import '../usuario/usuario_resumo.dart';

class Cancelamento {
  const Cancelamento({
    required this.canceladoPor,
    required this.justificativa,
    required this.canceladoEm,
  });

  factory Cancelamento.fromJson(Map<String, dynamic> json) => Cancelamento(
        canceladoPor:
            UsuarioResumo.fromJson(json['canceladoPor'] as Map<String, dynamic>),
        justificativa: json['justificativa'] as String,
        canceladoEm: lerInstanteDoJson(json['canceladoEm'])!,
      );

  static Cancelamento? fromJsonOpcional(Object? json) =>
      json == null ? null : Cancelamento.fromJson(json as Map<String, dynamic>);

  final UsuarioResumo canceladoPor;

  final String justificativa;

  final DateTime canceladoEm;

  String get canceladoEmFormatado => formatarDataEHora(canceladoEm);
}
