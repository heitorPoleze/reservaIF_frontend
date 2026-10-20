import '../../utils/datas.dart';
import '../../utils/formatacao.dart';
import 'reserva.dart';
import 'status_reserva.dart';

class HorarioDoDia {
  const HorarioDoDia({required this.inicio, required this.fim, this.reserva});

  static const primeiraHora = 7;

  static const ultimaHora = 21;

  static const duracao = Duration(minutes: 50);

  static List<HorarioDoDia> doDia(DateTime dia, List<Reserva> reservasDaSala) {
    final ativas = reservasDaSala.where((reserva) => !reserva.status.terminal);

    return [
      for (var hora = primeiraHora; hora <= ultimaHora; hora++)
        _faixa(combinarDataEHora(dia, hora, 0), ativas),
    ];
  }

  static HorarioDoDia _faixa(DateTime inicio, Iterable<Reserva> ativas) {
    final fim = inicio.add(duracao);

    return HorarioDoDia(
      inicio: inicio,
      fim: fim,
      reserva: ativas
          .where((r) => r.inicio.isBefore(fim) && inicio.isBefore(r.fim))
          .firstOrNull,
    );
  }

  final DateTime inicio;

  final DateTime fim;

  final Reserva? reserva;

  bool get livre => reserva == null;

  bool passado({DateTime? agora}) =>
      !(agora ?? DateTime.now()).isBefore(inicio);

  bool reservavel({DateTime? agora}) => livre && !passado(agora: agora);

  String get faixaFormatada => formatarFaixaDeHoras(inicio, fim);

  String get intervaloFormatado => formatarIntervaloDeHoras(inicio, fim);

  String get diaFormatado => formatarDiaDaSemanaEDiaDoMes(inicio);

  String situacao({DateTime? agora}) {
    final status = reserva?.status;
    if (status == StatusReserva.pendente) return StatusReserva.pendente.rotulo;
    if (status != null) return 'Reservado';

    return passado(agora: agora) ? 'Encerrado' : 'Livre';
  }
}
