import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reserva_if/model/usuario/perfil_usuario.dart';
import 'package:reserva_if/view/theme/app_cores.dart';
import 'package:reserva_if/view/theme/app_estilos.dart';
import 'package:reserva_if/view/widgets/app_bar_padrao.dart';
import 'package:reserva_if/view/widgets/botao_padrao.dart';
import 'package:reserva_if/view/widgets/dialogos.dart';
import 'package:reserva_if/viewmodel/sessao/sessao_viewmodel.dart';

class TelaPerfil extends StatelessWidget {
  const TelaPerfil({super.key});

  Future<void> _sair(BuildContext context) async {
    final confirmou = await confirmarAcao(
      context,
      titulo: 'Sair da conta?',
      mensagem: 'Você vai precisar entrar de novo para usar o aplicativo.',
      rotuloConfirmar: 'Sair',
      corConfirmar: AppCores.acao,
    );

    if (!confirmou || !context.mounted) return;

    await context.read<SessaoViewModel>().sair();
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.select<SessaoViewModel, PerfilUsuario?>(
      (sessao) => sessao.usuario,
    );

    if (usuario == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: const AppBarPadrao(titulo: 'Perfil'),
      body: ListView(
        padding: const EdgeInsets.all(AppEstilos.espacoPagina),
        children: [
          _CartaoDoUsuario(usuario: usuario),
          const SizedBox(height: 32),
          BotaoPadrao(
            texto: 'Sair',
            icone: Icons.logout,
            contornado: true,
            aoPressionar: () => _sair(context),
          ),
        ],
      ),
    );
  }
}

class _CartaoDoUsuario extends StatelessWidget {
  final PerfilUsuario usuario;

  const _CartaoDoUsuario({required this.usuario});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppCores.fundoIcone,
                  child: Icon(
                    Icons.person_outline,
                    size: 40,
                    color: tema.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  usuario.nome,
                  textAlign: TextAlign.center,
                  style: tema.textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  usuario.perfil.rotulo,
                  style: tema.textTheme.bodyMedium?.copyWith(
                    color: AppCores.textoSecundario,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.badge_outlined),
            title: Text(usuario.identificadorFormatado),
          ),
          ListTile(
            leading: const Icon(Icons.mail_outline),
            title: Text(usuario.email),
          ),
          if (usuario.telefone != null)
            ListTile(
              leading: const Icon(Icons.phone_outlined),
              title: Text(usuario.telefone!),
            ),
        ],
      ),
    );
  }
}
