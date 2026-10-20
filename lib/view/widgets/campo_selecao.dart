import 'package:flutter/material.dart';
import 'package:reserva_if/view/widgets/campos_formulario.dart';

class CampoSelecao<T> extends StatelessWidget {
  final String rotulo;
  final T? valor;
  final List<T> opcoes;
  final String Function(T) rotuloDe;
  final IconData Function(T)? iconeDe;
  final ValueChanged<T?> aoMudar;
  final String? dica;
  final String? Function(T?)? validador;
  final bool habilitado;
  final bool opcional;

  const CampoSelecao({
    super.key,
    required this.rotulo,
    required this.valor,
    required this.opcoes,
    required this.rotuloDe,
    required this.aoMudar,
    this.iconeDe,
    this.dica,
    this.validador,
    this.habilitado = true,
    this.opcional = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        rotuloDeCampo(context, rotulo, opcional: opcional),
        DropdownButtonFormField<T>(
          initialValue: valor,
          isExpanded: true,
          itemHeight: null,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: validador,
          style: estiloDeValorDeCampo(context),
          decoration: InputDecoration(
            hintText: dica,
            prefixIcon: _iconeSelecionado,
          ),
          selectedItemBuilder: (_) => [
            for (final opcao in opcoes)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  rotuloDe(opcao),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          items: [
            for (final opcao in opcoes)
              DropdownMenuItem<T>(
                value: opcao,
                child: _ItemDeSelecao(
                  texto: rotuloDe(opcao),
                  icone: iconeDe?.call(opcao),
                ),
              ),
          ],
          onChanged: habilitado ? aoMudar : null,
        ),
      ],
    );
  }

  Widget? get _iconeSelecionado {
    final selecionado = valor;
    final icone = iconeDe;
    if (selecionado == null || icone == null) return null;
    return Icon(icone(selecionado));
  }
}

class _ItemDeSelecao extends StatelessWidget {
  final String texto;
  final IconData? icone;

  const _ItemDeSelecao({required this.texto, this.icone});

  @override
  Widget build(BuildContext context) {
    final rotulo = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(texto, maxLines: 2, overflow: TextOverflow.ellipsis),
    );

    if (icone == null) return rotulo;

    return Row(
      children: [
        Icon(icone, size: 20),
        const SizedBox(width: 12),
        Expanded(child: rotulo),
      ],
    );
  }
}
