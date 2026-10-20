import 'package:flutter/material.dart';
import 'package:reserva_if/model/usuario/perfil.dart';
import 'package:reserva_if/model/usuario/servidor_resumo.dart';
import 'package:reserva_if/view/theme/app_cores.dart';
import 'package:reserva_if/view/widgets/estados.dart';
import 'package:reserva_if/view/widgets/painel_modal.dart';

Future<ServidorResumo?> escolherResponsavel(
  BuildContext context, {
  required List<Perfil> perfis,
  required List<ServidorResumo> Function(Perfil) servidoresDo,
  ServidorResumo? selecionado,
}) {
  return mostrarPainelModal<ServidorResumo>(
    context: context,
    construir: (_) => PainelSelecaoResponsavel(
      perfis: perfis,
      servidoresDo: servidoresDo,
      selecionado: selecionado,
    ),
  );
}

class PainelSelecaoResponsavel extends StatelessWidget {
  final List<Perfil> perfis;
  final List<ServidorResumo> Function(Perfil) servidoresDo;
  final ServidorResumo? selecionado;

  const PainelSelecaoResponsavel({
    super.key,
    required this.perfis,
    required this.servidoresDo,
    this.selecionado,
  });

  int get _abaInicial {
    final indice = perfis.indexOf(selecionado?.perfil ?? perfis.first);
    return indice < 0 ? 0 : indice;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: perfis.length,
      initialIndex: _abaInicial,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                'Escolha o responsável',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [for (final perfil in perfis) Tab(text: perfil.rotulo)],
          ),
          const Divider(height: 1),
          Flexible(
            child: TabBarView(
              children: [
                for (final perfil in perfis)
                  _ListaDeServidores(
                    servidores: servidoresDo(perfil),
                    selecionado: selecionado,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ListaDeServidores extends StatelessWidget {
  final List<ServidorResumo> servidores;
  final ServidorResumo? selecionado;

  const _ListaDeServidores({required this.servidores, this.selecionado});

  @override
  Widget build(BuildContext context) {
    if (servidores.isEmpty) {
      return const EstadoVazio(
        mensagem: 'Nenhum servidor disponível com este perfil.',
        icone: Icons.person_off_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: servidores.length,
      itemBuilder: (context, indice) {
        final servidor = servidores[indice];
        final escolhido = servidor.id == selecionado?.id;

        return ListTile(
          leading: const Icon(Icons.person_outline),
          title: Text(servidor.nome),
          selected: escolhido,
          trailing: escolhido
              ? const Icon(Icons.check, color: AppCores.acao)
              : null,
          onTap: () => Navigator.pop(context, servidor),
        );
      },
    );
  }
}
