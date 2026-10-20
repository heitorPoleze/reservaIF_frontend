import 'package:flutter/material.dart';
import 'package:reserva_if/model/reserva/horario_do_dia.dart';
import 'package:reserva_if/model/sala/sala.dart';
import 'package:reserva_if/view/theme/app_cores.dart';
import 'package:reserva_if/view/theme/app_estilos.dart';
import 'package:reserva_if/view/widgets/botao_padrao.dart';
import 'package:reserva_if/view/widgets/cartao_entidade.dart';

class PainelHorarioLivre extends StatelessWidget {
  final HorarioDoDia horario;
  final Sala sala;
  final VoidCallback aoReservar;

  const PainelHorarioLivre({
    super.key,
    required this.horario,
    required this.sala,
    required this.aoReservar,
  });

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppCores.fundoIcone,
                  borderRadius: BorderRadius.circular(AppEstilos.raioCampo),
                ),
                child: const Icon(Icons.event_available, color: AppCores.acao),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Horário livre', style: textos.titleLarge),
                    const SizedBox(height: 2),
                    Text(
                      horario.diaFormatado,
                      style: textos.bodyMedium?.copyWith(
                        color: AppCores.textoSecundario,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          LinhaCartao(
            icone: Icons.schedule,
            titulo: 'Horário',
            valor: horario.intervaloFormatado,
          ),
          const SizedBox(height: 14),
          LinhaCartao(
            icone: Icons.meeting_room_outlined,
            titulo: 'Sala',
            valor: sala.nomeComPredio,
          ),
          const SizedBox(height: 28),
          BotaoPadrao(
            texto: 'Reservar horário',
            icone: Icons.arrow_forward,
            aoPressionar: () {
              Navigator.pop(context);
              aoReservar();
            },
          ),
        ],
      ),
    );
  }
}
