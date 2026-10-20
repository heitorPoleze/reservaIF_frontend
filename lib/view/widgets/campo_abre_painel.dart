import 'package:flutter/material.dart';
import 'package:reserva_if/view/theme/app_estilos.dart';
import 'package:reserva_if/view/widgets/campos_formulario.dart';

class CampoAbrePainel<T> extends StatelessWidget {
  final String rotulo;
  final T? valor;
  final String Function(T) rotuloDe;
  final Future<T?> Function(BuildContext) abrir;
  final ValueChanged<T> aoMudar;
  final IconData? icone;
  final String? dica;
  final String? Function(T?)? validador;
  final bool habilitado;

  const CampoAbrePainel({
    super.key,
    required this.rotulo,
    required this.valor,
    required this.rotuloDe,
    required this.abrir,
    required this.aoMudar,
    this.icone,
    this.dica,
    this.validador,
    this.habilitado = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        rotuloDeCampo(context, rotulo),
        FormField<T>(
          initialValue: valor,
          enabled: habilitado,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: validador,
          builder: (campo) => InkWell(
            onTap: habilitado ? () => _escolher(context, campo) : null,
            borderRadius: BorderRadius.circular(AppEstilos.raioCampo),
            child: InputDecorator(
              isEmpty: campo.value == null,
              decoration: InputDecoration(
                hintText: dica,
                errorText: campo.errorText,
                enabled: habilitado,
                prefixIcon: icone == null ? null : Icon(icone),
                suffixIcon: const Icon(Icons.expand_more),
              ),
              child: _valorEscolhido(context, campo.value),
            ),
          ),
        ),
      ],
    );
  }

  Widget? _valorEscolhido(BuildContext context, T? escolhido) {
    if (escolhido == null) return null;

    return Text(
      rotuloDe(escolhido),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: estiloDeValorDeCampo(context),
    );
  }

  Future<void> _escolher(BuildContext context, FormFieldState<T> campo) async {
    final escolhido = await abrir(context);
    if (escolhido == null || !campo.mounted) return;

    campo.didChange(escolhido);
    aoMudar(escolhido);
  }
}
