import '../../utils/datas.dart';
import 'status_solicitacao_cancelamento.dart';

class SolicitacaoCancelamento {
  const SolicitacaoCancelamento({
    this.id,
    required this.reservaId,
    required this.solicitadoPorId,
    required this.justificativa,
    this.finalidade,
    this.status = StatusSolicitacaoCancelamento.pendente,
    required this.criadoEm,
  });

  factory SolicitacaoCancelamento.fromJson(Map<String, dynamic> json) =>
      SolicitacaoCancelamento(
        id: json['id'] as String?,
        reservaId: json['reservaId'] as String,
        solicitadoPorId: json['solicitadoPorId'] as String,
        justificativa: json['justificativa'] as String,
        finalidade: json['finalidade'] as String?,
        status: json['status'] == null
            ? StatusSolicitacaoCancelamento.pendente
            : StatusSolicitacaoCancelamento.fromJson(json['status']),
        criadoEm: lerInstanteDoJson(json['criadoEm'])!,
      );

  final String? id;

  final String reservaId;

  final String solicitadoPorId;

  final String justificativa;

  final String? finalidade;

  final StatusSolicitacaoCancelamento status;

  final DateTime criadoEm;

  String get idParaDecisao => id ?? reservaId;
}
