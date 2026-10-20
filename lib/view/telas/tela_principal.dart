import 'package:flutter/material.dart';
import 'package:reserva_if/model/predio/predio.dart';
import 'package:reserva_if/view/telas/tela_edificios.dart';

class TelaPrincipal extends StatefulWidget {
  final List<Predio> predios;

  const TelaPrincipal({super.key, this.predios = const []});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int _indiceSelecionado = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _indiceSelecionado,
        children: [
          TelaEdificios(predios: widget.predios),
          const _DestinoIndisponivel(
            titulo: 'Materiais',
            mensagem: 'A tela de materiais ainda não está disponível.',
            icone: Icons.inventory_2_outlined,
          ),
          const _DestinoIndisponivel(
            titulo: 'Perfil',
            mensagem: 'A tela de perfil ainda não está disponível.',
            icone: Icons.person_outline,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceSelecionado,
        onDestinationSelected: (indice) {
          setState(() => _indiceSelecionado = indice);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Materiais',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class _DestinoIndisponivel extends StatelessWidget {
  final String titulo;
  final String mensagem;
  final IconData icone;

  const _DestinoIndisponivel({
    required this.titulo,
    required this.mensagem,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 48, color: esquema.primary),
            const SizedBox(height: 12),
            Text(mensagem, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
