import 'reserva.dart';
import 'serie_recorrencia.dart';
import 'status_reserva.dart';

class ResultadoCriacaoReserva {
  const ResultadoCriacaoReserva({
    this.serieRecorrencia,
    required this.reservas,
  });

  factory ResultadoCriacaoReserva.fromJson(Map<String, dynamic> json) =>
      ResultadoCriacaoReserva(
        serieRecorrencia: SerieRecorrencia.fromJsonOpcional(
          json['serieRecorrencia'],
        ),
        reservas: List.unmodifiable(
          (json['reservas'] as List).map(
            (reserva) => Reserva.fromJson(reserva as Map<String, dynamic>),
          ),
        ),
      );

  final SerieRecorrencia? serieRecorrencia;

  final List<Reserva> reservas;

  bool get aguardaAprovacao =>
      reservas.any((reserva) => reserva.status == StatusReserva.pendente);

  String get mensagem {
    if (aguardaAprovacao) return 'Solicitação enviada para aprovação.';

    return serieRecorrencia == null
        ? 'Reserva confirmada.'
        : '${reservas.length} reservas confirmadas.';
  }
}
