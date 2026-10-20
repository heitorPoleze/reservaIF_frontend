import 'package:flutter/material.dart';
import 'package:reserva_if/view/theme/app_cores.dart';
import 'package:reserva_if/view/theme/app_estilos.dart';

class CartaoPessoaDoConflito extends StatelessWidget {
  final String nome;
  final String rotulo;

  const CartaoPessoaDoConflito({
    super.key,
    required this.nome,
    required this.rotulo,
  });

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: AppEstilos.cartao(),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.person_outline, color: AppCores.acao, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text(nome, style: textos.titleMedium)),
            const SizedBox(width: 8),
            Text(
              rotulo,
              style: textos.labelMedium?.copyWith(
                color: AppCores.acao,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
