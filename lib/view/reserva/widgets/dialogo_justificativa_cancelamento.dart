import 'package:flutter/material.dart';
import 'package:reserva_if/utils/validator.dart';
import 'package:reserva_if/view/theme/app_cores.dart';
import 'package:reserva_if/view/widgets/campo_texto.dart';
import 'package:reserva_if/view/widgets/dialogos.dart';
import 'package:reserva_if/view/widgets/formulario/validacao_formulario.dart';

Future<String?> pedirJustificativaDeCancelamento(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (_) => const _DialogoJustificativa(),
  );
}

class _DialogoJustificativa extends StatefulWidget {
  const _DialogoJustificativa();

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
      title: const Text('Cancelar reserva?'),
      content: Form(
        key: _chaveDoFormulario,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'O horário volta a ficar livre e a reserva segue no '
                'histórico como cancelada.',
              ),
              const SizedBox(height: 16),
              CampoTexto(
                rotulo: 'Justificativa',
                controller: _justificativa,
                dica: 'Por que a reserva está sendo cancelada?',
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
        rotuloConfirmar: 'Cancelar reserva',
        corConfirmar: AppCores.aviso,
        aoConfirmar: _confirmar,
      ),
    );
  }
}
