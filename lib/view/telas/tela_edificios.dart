import 'package:flutter/material.dart';
import 'package:reserva_if/model/predio/predio.dart';
import 'package:reserva_if/view/widgets/app_bar_padrao.dart';
import 'package:reserva_if/view/widgets/card_predio.dart';

class TelaEdificios extends StatelessWidget {
  final List<Predio> predios;
  final ValueChanged<Predio>? aoSelecionarPredio;

  const TelaEdificios({
    super.key,
    required this.predios,
    this.aoSelecionarPredio,
  });

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: esquema.surfaceContainerLow,
      appBar: const AppBarPadrao(titulo: 'Edifícios'),
      body: predios.isEmpty
          ? Center(
              child: Text(
                'Nenhum edifício encontrado.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              itemCount: predios.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final predio = predios[index];
                return CardPredio(
                  nome: predio.nome,
                  aoTocar: () => aoSelecionarPredio?.call(predio),
                );
              },
            ),
    );
  }
}
