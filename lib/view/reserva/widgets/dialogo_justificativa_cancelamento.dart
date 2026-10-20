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
    builder: (_) => _DialogoJustificativa(modo: modo),
  );
}

class _DialogoJustificativa extends StatefulWidget {
  const _DialogoJustificativa({required this.modo});

  final ModoCancelamento modo;

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
    final modo = widget.modo;

    return AlertDialog(
      title: Text(modo.tituloConfirmacao),
      content: Form(
        key: _chaveDoFormulario,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(modo.explicacao),
              const SizedBox(height: 16),
              CampoTexto(
                rotulo: 'Justificativa',
                controller: _justificativa,
                dica: modo.dicaJustificativa,
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
        rotuloConfirmar: modo.rotuloAcao,
        corConfirmar: AppCores.aviso,
        aoConfirmar: _confirmar,
      ),
    );
  }
}
