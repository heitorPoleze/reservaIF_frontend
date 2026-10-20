import 'reserva.dart';

class ResultadoCancelamento {
  const ResultadoCancelamento({
    this.reserva,
    required this.solicitacaoEnviada,
    required this.mensagem,
  });

  factory ResultadoCancelamento.fromJson(Map<String, dynamic> json) {
    final reserva = json['reserva'];

    return ResultadoCancelamento(
      reserva: reserva == null
          ? null
          : Reserva.fromJson(reserva as Map<String, dynamic>),
      solicitacaoEnviada: json['solicitacaoEnviada'] as bool,
      mensagem: json['mensagem'] as String,
    );
  }

  final Reserva? reserva;

  final bool solicitacaoEnviada;

  final String mensagem;
}
