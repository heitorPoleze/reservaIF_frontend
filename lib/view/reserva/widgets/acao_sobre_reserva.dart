import 'package:flutter/material.dart';
import 'package:reserva_if/model/reserva/acao_sobre_reserva.dart';
import 'package:reserva_if/model/reserva/reserva.dart';
import 'package:reserva_if/view/reserva/widgets/dialogo_justificativa.dart';
import 'package:reserva_if/view/reserva/widgets/painel_detalhes_reserva.dart';
import 'package:reserva_if/view/widgets/feedback_usuario.dart';
import 'package:reserva_if/view/widgets/painel_modal.dart';
import 'package:reserva_if/viewmodel/reserva/acao_sobre_reserva_mixin.dart';

void abrirDetalhesDaReserva(
  BuildContext context, {
  required Reserva reserva,
  required AcaoSobreReservaMixin viewModel,
}) {
  mostrarPainelModal<void>(
    context: context,
    construir: (_) => PainelDetalhesReserva(
      reserva: reserva,
      acao: viewModel.acaoDisponivel(reserva),
      aoExecutarAcao: (acao) => executarAcaoComFeedback(
        context,
        reserva: reserva,
        acao: acao,
        viewModel: viewModel,
      ),
    ),
  );
}

Future<void> executarAcaoComFeedback(
  BuildContext context, {
  required Reserva reserva,
  required AcaoSobreReserva acao,
  required AcaoSobreReservaMixin viewModel,
}) async {
  final justificativa = await pedirJustificativaDaAcao(context, acao);
  if (justificativa == null || !context.mounted) return;

  final resultado = await viewModel.executarAcao(reserva, acao, justificativa);
  if (!context.mounted) return;

  if (resultado == null) {
    mostrarErro(context, viewModel.mensagemErroDaAcao ?? acao.falhaPadrao);
  } else if (resultado.solicitacaoEnviada) {
    mostrarInfo(context, resultado.mensagem);
  } else {
    mostrarSucesso(context, resultado.mensagem);
  }
}
