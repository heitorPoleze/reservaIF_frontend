import '../enum_json.dart';

enum StatusSolicitacaoCancelamento {
  pendente('PENDENTE', 'Pendente'),
  aprovada('APROVADA', 'Aprovada'),
  rejeitada('REJEITADA', 'Rejeitada');

  const StatusSolicitacaoCancelamento(this.valorJson, this.rotulo);

  final String valorJson;

  final String rotulo;

  static StatusSolicitacaoCancelamento fromJson(Object? json) =>
      enumDoJson(values, (status) => status.valorJson, json);

  String toJson() => valorJson;
}
