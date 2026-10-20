import 'package:flutter/material.dart';
import 'package:reserva_if/view/theme/app_cores.dart';

class AcoesDeAnalise extends StatelessWidget {
  final VoidCallback? aoAprovar;
  final VoidCallback? aoRejeitar;

  const AcoesDeAnalise({
    super.key,
    required this.aoAprovar,
    required this.aoRejeitar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Aprovar',
          color: AppCores.acao,
          onPressed: aoAprovar,
          icon: const Icon(Icons.check, size: 28),
        ),
        IconButton(
          tooltip: 'Rejeitar',
          color: AppCores.erro,
          onPressed: aoRejeitar,
          icon: const Icon(Icons.close, size: 28),
        ),
      ],
    );
  }
}
