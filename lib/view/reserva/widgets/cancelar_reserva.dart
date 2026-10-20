import 'package:flutter/material.dart';
import 'package:reserva_if/model/reserva/reserva.dart';
import 'package:reserva_if/view/reserva/widgets/dialogo_justificativa.dart';
import 'package:reserva_if/view/reserva/widgets/painel_detalhes_reserva.dart';
import 'package:reserva_if/view/widgets/feedback_usuario.dart';
import 'package:reserva_if/view/widgets/painel_modal.dart';
import 'package:reserva_if/viewmodel/reserva/cancelamento_de_reserva_mixin.dart';

void abrirDetalhesDaReserva(
  BuildContext context, {
  required Reserva reserva,
  required CancelamentoDeReservaMixin viewModel,
}) {
  mostrarPainelModal<void>(
    context: context,
    construir: (_) => PainelDetalhesReserva(
      reserva: reserva,
      podeCancelar: viewModel.podeCancelar(reserva),
      aoCancelar: () => cancelarReservaComFeedback(
        context,
        reserva: reserva,
        viewModel: viewModel,
      ),
    ),
  );
}

Future<void> cancelarReservaComFeedback(
  BuildContext context, {
  required Reserva reserva,
  required CancelamentoDeReservaMixin viewModel,
}) async {
  final justificativa = await pedirJustificativaDeCancelamento(context);
  if (justificativa == null || !context.mounted) return;

  final resultado = await viewModel.cancelar(reserva, justificativa);
  if (!context.mounted) return;

  if (resultado == null) {
    mostrarErro(
      context,
      viewModel.mensagemErroCancelamento ??
          'Não foi possível cancelar a reserva.',
    );
  } else if (resultado.solicitacaoEnviada) {
    mostrarInfo(context, resultado.mensagem);
  } else {
    mostrarSucesso(context, resultado.mensagem);
  }
}
