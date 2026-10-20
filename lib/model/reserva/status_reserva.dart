import '../enum_json.dart';

enum StatusReserva {
  pendente('PENDENTE_APROVACAO', 'Em Análise'),
  aprovada('APROVADA', 'Aprovada'),
  agendada('AGENDADO', 'Agendada'),
  rejeitada('REJEITADA', 'Rejeitada'),
  cancelada('CANCELADA', 'Cancelada'),
  concluida('CONCLUIDA', 'Concluída');

  const StatusReserva(this.valorJson, this.rotulo);

  final String valorJson;

  final String rotulo;

  bool get ocupaSala => this == aprovada || this == agendada;

  bool get terminal =>
      this == rejeitada || this == cancelada || this == concluida;

  static StatusReserva fromJson(Object? json) =>
      enumDoJson(values, (status) => status.valorJson, json);

  String toJson() => valorJson;
}
