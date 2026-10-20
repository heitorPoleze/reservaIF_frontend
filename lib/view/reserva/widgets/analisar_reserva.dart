import 'package:flutter/material.dart';
import 'package:reserva_if/model/reserva/reserva.dart';
import 'package:reserva_if/view/reserva/widgets/dialogo_justificativa.dart';
import 'package:reserva_if/view/theme/app_cores.dart';
import 'package:reserva_if/view/widgets/dialogos.dart';
import 'package:reserva_if/view/widgets/feedback_usuario.dart';
import 'package:reserva_if/viewmodel/reserva/analise_de_reserva_mixin.dart';

Future<void> aprovarReservaComFeedback(
  BuildContext context, {
  required Reserva reserva,
  required AnaliseDeReservaMixin viewModel,
}) async {
  final confirmou = await confirmarAcao(
    context,
    titulo: 'Aprovar reserva?',
    mensagem:
        'A reserva de ${reserva.solicitante.nome} em '
        '${reserva.periodoFormatado} será aprovada.',
    rotuloConfirmar: 'Aprovar',
    corConfirmar: AppCores.acao,
  );
  if (!confirmou || !context.mounted) return;

  final aprovou = await viewModel.aprovar(reserva);
  if (!context.mounted) return;

  mostrarResultado(
    context,
    _mensagemDoDesfecho(
      viewModel,
      sucesso: aprovou,
      mensagemSucesso: 'Reserva aprovada.',
    ),
    sucesso: aprovou,
  );
}

Future<void> rejeitarReservaComFeedback(
  BuildContext context, {
  required Reserva reserva,
  required AnaliseDeReservaMixin viewModel,
}) async {
  final motivo = await pedirMotivoDeRejeicao(context);
  if (motivo == null || !context.mounted) return;

  final rejeitou = await viewModel.rejeitar(reserva, motivo);
  if (!context.mounted) return;

  mostrarResultado(
    context,
    _mensagemDoDesfecho(
      viewModel,
      sucesso: rejeitou,
      mensagemSucesso: 'Reserva rejeitada.',
    ),
    sucesso: rejeitou,
  );
}

String _mensagemDoDesfecho(
  AnaliseDeReservaMixin viewModel, {
  required bool sucesso,
  required String mensagemSucesso,
}) => sucesso
    ? mensagemSucesso
    : viewModel.mensagemErroAnalise ?? 'Não foi possível analisar a reserva.';
