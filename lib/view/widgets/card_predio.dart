import 'package:flutter/material.dart';

class CardPredio extends StatelessWidget {
  final String nome;
  final VoidCallback? aoTocar;

  const CardPredio({super.key, required this.nome, this.aoTocar});

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;

    return Material(
      color: esquema.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: aoTocar,
        child: Container(
          height: 153,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: esquema.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 40,
                decoration: BoxDecoration(
                  color: esquema.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.meeting_room_outlined,
                  size: 20,
                  color: esquema.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  nome,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(color: esquema.primary),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: esquema.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
