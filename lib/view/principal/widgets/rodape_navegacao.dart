import 'package:flutter/material.dart';

class AbaPrincipal {
  final String rotulo;
  final IconData icone;
  final IconData iconeSelecionado;
  final Widget pagina;

  const AbaPrincipal({
    required this.rotulo,
    required this.icone,
    required this.iconeSelecionado,
    required this.pagina,
  });
}

class RodapeNavegacao extends StatelessWidget {
  final List<AbaPrincipal> abas;
  final int indiceSelecionado;
  final ValueChanged<int> aoSelecionar;

  const RodapeNavegacao({
    super.key,
    required this.abas,
    required this.indiceSelecionado,
    required this.aoSelecionar,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: indiceSelecionado,
      onDestinationSelected: aoSelecionar,
      destinations: [
        for (final aba in abas)
          NavigationDestination(
            icon: Icon(aba.icone),
            selectedIcon: Icon(aba.iconeSelecionado),
            label: aba.rotulo,
          ),
      ],
    );
  }
}
