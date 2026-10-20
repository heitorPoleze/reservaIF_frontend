import 'package:flutter/material.dart';
import 'package:reserva_if/model/reserva/modo_cancelamento.dart';
import 'package:reserva_if/utils/validator.dart';
import 'package:reserva_if/view/theme/app_cores.dart';
import 'package:reserva_if/view/widgets/campo_texto.dart';
import 'package:reserva_if/view/widgets/dialogos.dart';
import 'package:reserva_if/view/widgets/formulario/validacao_formulario.dart';

Future<String?> pedirJustificativaDeCancelamento(
  BuildContext context,
  ModoCancelamento modo,
) {
  return showDialog<String>(
    context: context,
    builder: (_) => _DialogoJustificativa(
      titulo: modo.tituloConfirmacao,
      mensagem: modo.explicacao,
      rotuloCampo: 'Justificativa',
      dica: modo.dicaJustificativa,
      rotuloConfirmar: modo.rotuloAcao,
      corConfirmar: AppCores.aviso,
    ),
  );
}

Future<String?> pedirMotivoDeRejeicao(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (_) => const _DialogoJustificativa(
      titulo: 'Rejeitar reserva?',
      mensagem:
          'O horário não será reservado e o solicitante verá o motivo '
          'da rejeição.',
      rotuloCampo: 'Motivo',
      dica: 'Por que a reserva está sendo rejeitada?',
      rotuloConfirmar: 'Rejeitar',
      corConfirmar: AppCores.erro,
    ),
  );
}

class _DialogoJustificativa extends StatefulWidget {
  final String titulo;
  final String mensagem;
  final String rotuloCampo;
  final String dica;
  final String rotuloConfirmar;
  final Color corConfirmar;

  const _DialogoJustificativa({
    required this.titulo,
    required this.mensagem,
    required this.rotuloCampo,
    required this.dica,
    required this.rotuloConfirmar,
    required this.corConfirmar,
  });

  @override
  State<_DialogoJustificativa> createState() => _DialogoJustificativaState();
}

class _DialogoJustificativaState extends State<_DialogoJustificativa> {
  final _chaveDoFormulario = GlobalKey<FormState>();
  final _justificativa = TextEditingController();

  @override
  void dispose() {
    _justificativa.dispose();
    super.dispose();
  }

  void _confirmar() {
    if (!validarRevelandoCampoInvalido(_chaveDoFormulario)) return;

    Navigator.pop(context, _justificativa.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo),
      content: Form(
        key: _chaveDoFormulario,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.mensagem),
              const SizedBox(height: 16),
              CampoTexto(
                rotulo: widget.rotuloCampo,
                controller: _justificativa,
                dica: widget.dica,
                validador: Validator.descricaoObrigatoria,
                maxLinhas: 3,
                capitalizacao: TextCapitalization.sentences,
                acaoDoTeclado: TextInputAction.done,
              ),
            ],
          ),
        ),
      ),
      actions: acoesDeDialogo(
        context: context,
        rotuloCancelar: 'Voltar',
        rotuloConfirmar: widget.rotuloConfirmar,
        corConfirmar: widget.corConfirmar,
        aoConfirmar: _confirmar,
      ),
    );
  }
}
