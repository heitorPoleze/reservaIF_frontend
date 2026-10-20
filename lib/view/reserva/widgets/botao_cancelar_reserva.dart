import 'package:flutter/material.dart';
import 'package:reserva_if/model/reserva/modo_cancelamento.dart';
import 'package:reserva_if/view/theme/app_cores.dart';

class BotaoCancelarReserva extends StatelessWidget {
  final ModoCancelamento modo;
  final VoidCallback? aoPressionar;

  const BotaoCancelarReserva({
    super.key,
    required this.modo,
    required this.aoPressionar,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppCores.aviso,
        side: const BorderSide(color: AppCores.aviso, width: 1.5),
      ),
      onPressed: aoPressionar,
      icon: const Icon(Icons.event_busy_outlined, size: 20),
      label: Text(modo.rotuloAcao),
    );
  }
}
