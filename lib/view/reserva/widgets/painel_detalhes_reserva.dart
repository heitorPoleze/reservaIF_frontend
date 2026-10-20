import 'package:flutter/material.dart';
import 'package:reserva_if/model/reserva/modo_cancelamento.dart';
import 'package:reserva_if/model/reserva/reserva.dart';
import 'package:reserva_if/view/reserva/widgets/botao_cancelar_reserva.dart';
import 'package:reserva_if/view/reserva/widgets/selo_status_reserva.dart';
import 'package:reserva_if/view/widgets/cartao_entidade.dart';

class PainelDetalhesReserva extends StatelessWidget {
  final Reserva reserva;
  final ModoCancelamento? modoCancelamento;
  final ValueChanged<ModoCancelamento> aoCancelar;

  const PainelDetalhesReserva({
    super.key,
    required this.reserva,
    required this.modoCancelamento,
    required this.aoCancelar,
  });

  @override
  Widget build(BuildContext context) {
    final modo = modoCancelamento;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          CartaoEntidade(
            icone: Icons.event_note,
            titulo: reserva.finalidade,
            acao: SeloStatusReserva(status: reserva.status),
            corpo: _linhas(),
          ),
          if (modo != null) ...[
            const SizedBox(height: 20),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: BotaoCancelarReserva(
                modo: modo,
                aoPressionar: () {
                  Navigator.pop(context);
                  aoCancelar(modo);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _linhas() {
    final observacoes = reserva.observacoes;
    final criadoEm = reserva.criadoEmFormatado;
    final aceitoEm = reserva.aceitoPeloResponsavelEmFormatado;
    final analisadoPor = reserva.analisadoPor;
    final analisadoEm = reserva.analisadoEmFormatado;
    final motivoRejeicao = reserva.motivoRejeicao;
    final cancelamento = reserva.cancelamento;

    return [
      LinhaCartao(
        icone: Icons.calendar_today_outlined,
        titulo: 'Data',
        valor: reserva.dataComDiaDaSemana,
      ),
      LinhaCartao(
        icone: Icons.schedule,
        titulo: 'Horário',
        valor: reserva.horarioFormatado,
      ),
      LinhaCartao(
        icone: Icons.meeting_room_outlined,
        titulo: 'Sala',
        valor: reserva.sala.nomeComPredio,
      ),
      LinhaCartao(
        icone: Icons.groups_outlined,
        titulo: 'Capacidade',
        valor: reserva.sala.capacidadeFormatada,
      ),
      LinhaCartao(
        icone: Icons.person_outline,
        titulo: 'Solicitante',
        valor: reserva.solicitante.nome,
      ),
      if (reserva.delegada)
        LinhaCartao(
          icone: Icons.supervisor_account_outlined,
          titulo: 'Responsável',
          valor: reserva.responsavel.nome,
        ),
      LinhaCartao(
        icone: Icons.repeat,
        titulo: 'Recorrência',
        valor: reserva.recorrenciaFormatada,
      ),
      if (observacoes != null && observacoes.trim().isNotEmpty)
        LinhaCartao(
          icone: Icons.notes,
          titulo: 'Observações',
          valor: observacoes,
        ),
      if (criadoEm != null)
        LinhaCartao(
          icone: Icons.history,
          titulo: 'Solicitada em',
          valor: criadoEm,
        ),
      if (aceitoEm != null)
        LinhaCartao(
          icone: Icons.how_to_reg_outlined,
          titulo: 'Aceita pelo responsável em',
          valor: aceitoEm,
        ),
      if (analisadoPor != null)
        LinhaCartao(
          icone: Icons.fact_check_outlined,
          titulo: 'Analisada por',
          valor: analisadoPor.nome,
        ),
      if (analisadoEm != null)
        LinhaCartao(
          icone: Icons.event_available_outlined,
          titulo: 'Analisada em',
          valor: analisadoEm,
        ),
      if (motivoRejeicao != null)
        LinhaCartao(
          icone: Icons.block,
          titulo: 'Motivo da rejeição',
          valor: motivoRejeicao,
        ),
      if (cancelamento != null) ...[
        LinhaCartao(
          icone: Icons.comment_outlined,
          titulo: 'Justificativa do cancelamento',
          valor: cancelamento.justificativa,
        ),
        LinhaCartao(
          icone: Icons.event_busy_outlined,
          titulo: 'Cancelada em',
          valor: cancelamento.canceladoEmFormatado,
        ),
      ],
    ];
  }
}
