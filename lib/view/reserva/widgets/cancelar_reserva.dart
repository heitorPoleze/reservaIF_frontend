import 'package:flutter/material.dart';
import 'package:reserva_if/model/reserva/modo_cancelamento.dart';
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
      modoCancelamento: viewModel.modoDeCancelamento(reserva),
      aoCancelar: (modo) => cancelarReservaComFeedback(
        context,
        reserva: reserva,
        modo: modo,
        viewModel: viewModel,
      ),
    ),
  );
}

Future<void> cancelarReservaComFeedback(
  BuildContext context, {
  required Reserva reserva,
  required ModoCancelamento modo,
  required CancelamentoDeReservaMixin viewModel,
}) async {
  final justificativa = await pedirJustificativaDeCancelamento(
    context,
    modo,
  );
  if (justificativa == null || !context.mounted) return;

  final resultado = await viewModel.cancelar(
    reserva,
    modo,
    justificativa,
  );
  if (!context.mounted) return;

  if (resultado == null) {
    mostrarErro(
      context,
      viewModel.mensagemErroCancelamento ?? modo.falhaPadrao,
    );
  } else if (resultado.solicitacaoEnviada) {
    mostrarInfo(context, resultado.mensagem);
  } else {
    mostrarSucesso(context, resultado.mensagem);
  }
}
