import 'package:flutter/material.dart';
import 'package:reserva_if/model/reserva/tipo_recorrencia.dart';
import 'package:reserva_if/view/widgets/dialogos.dart';

Future<void> explicarRecorrencias(
  BuildContext context,
  List<TipoRecorrencia> tipos,
) {
  return informarEmDialogo(
    context,
    titulo: 'Como funciona a recorrência',
    conteudo: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [for (final tipo in tipos) _ExplicacaoDoTipo(tipo: tipo)],
    ),
  );
}

class BotaoExplicarRecorrencias extends StatelessWidget {
  final List<TipoRecorrencia> tipos;

  const BotaoExplicarRecorrencias({super.key, required this.tipos});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: TextButton.icon(
        onPressed: () => explicarRecorrencias(context, tipos),
        icon: const Icon(Icons.info_outline, size: 18),
        label: const Text('Como funciona a recorrência?'),
      ),
    );
  }
}

class _ExplicacaoDoTipo extends StatelessWidget {
  final TipoRecorrencia tipo;

  const _ExplicacaoDoTipo({required this.tipo});

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tipo.rotulo, style: textos.titleSmall),
          const SizedBox(height: 2),
          Text(tipo.descricao, style: textos.bodyMedium),
        ],
      ),
    );
  }
}
