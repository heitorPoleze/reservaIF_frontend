import 'package:flutter/material.dart';
import 'package:reserva_if/model/reserva/status_reserva.dart';
import 'package:reserva_if/view/theme/app_cores.dart';

class SeloStatusReserva extends StatelessWidget {
  final StatusReserva status;

  const SeloStatusReserva({super.key, required this.status});

  static Color corDo(StatusReserva status) => switch (status) {
    StatusReserva.pendente => AppCores.aviso,
    StatusReserva.aprovada || StatusReserva.agendada => AppCores.acao,
    StatusReserva.rejeitada => AppCores.erro,
    StatusReserva.cancelada ||
    StatusReserva.concluida => AppCores.textoTerciario,
  };

  @override
  Widget build(BuildContext context) {
    final cor = corDo(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.rotulo,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: cor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
