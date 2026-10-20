import 'package:flutter/material.dart';
import 'package:reserva_if/model/reserva/acao_sobre_reserva.dart';
import 'package:reserva_if/view/theme/app_cores.dart';

class BotaoAcaoSobreReserva extends StatelessWidget {
  final AcaoSobreReserva acao;
  final VoidCallback? aoPressionar;

  const BotaoAcaoSobreReserva({
    super.key,
    required this.acao,
    required this.aoPressionar,
  });

  @override
  Widget build(BuildContext context) {
    final cor = corDaAcaoSobreReserva(acao);

    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: cor,
        side: BorderSide(color: cor, width: 1.5),
      ),
      onPressed: aoPressionar,
      icon: Icon(_icone, size: 20),
      label: Text(acao.rotuloAcao),
    );
  }

  IconData get _icone => switch (acao) {
    AcaoSobreReserva.cancelarReserva => Icons.event_busy_outlined,
    AcaoSobreReserva.solicitarHorario => Icons.swap_horiz,
  };
}

Color corDaAcaoSobreReserva(AcaoSobreReserva acao) => switch (acao) {
  AcaoSobreReserva.cancelarReserva => AppCores.aviso,
  AcaoSobreReserva.solicitarHorario => AppCores.acao,
};
