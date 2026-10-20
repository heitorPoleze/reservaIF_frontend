import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reserva_if/model/reserva/reserva.dart';
import 'package:reserva_if/model/usuario/perfil_usuario.dart';
import 'package:reserva_if/services/services_reserva.dart';
import 'package:reserva_if/view/reserva/widgets/painel_detalhes_reserva.dart';
import 'package:reserva_if/view/reserva/widgets/selo_status_reserva.dart';
import 'package:reserva_if/view/theme/app_cores.dart';
import 'package:reserva_if/view/theme/app_estilos.dart';
import 'package:reserva_if/view/widgets/app_bar_padrao.dart';
import 'package:reserva_if/view/widgets/botao_padrao.dart';
import 'package:reserva_if/view/widgets/cartao_entidade.dart';
import 'package:reserva_if/view/widgets/dialogos.dart';
import 'package:reserva_if/view/widgets/estados.dart';
import 'package:reserva_if/view/widgets/painel_modal.dart';
import 'package:reserva_if/viewmodel/reserva/reservas_perfil_viewmodel.dart';
import 'package:reserva_if/viewmodel/sessao/sessao_viewmodel.dart';

class TelaPerfil extends StatefulWidget {
  const TelaPerfil({super.key});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

enum _AbaReservas { solicitadas, responsavel }

class _TelaPerfilState extends State<TelaPerfil> {
  ReservasPerfilViewModel? _viewModel;
  _AbaReservas _abaSelecionada = _AbaReservas.solicitadas;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final usuario = context.read<SessaoViewModel>().usuario;
    if (usuario == null || _viewModel != null) return;

    _viewModel = ReservasPerfilViewModel(
      usuario: usuario,
      service: ServicesReserva(),
    )..carregar();
  }

  @override
  void dispose() {
    _viewModel?.dispose();
    super.dispose();
  }

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
    final viewModel = _viewModel;

    if (usuario == null || viewModel == null) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      appBar: const AppBarPadrao(titulo: 'Perfil'),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) => RefreshIndicator(
          onRefresh: viewModel.carregar,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppEstilos.espacoPagina),
            children: [
              _CartaoDoUsuario(usuario: usuario),
              const SizedBox(height: 28),
              Text(
                'Meus agendamentos',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (viewModel.podeVerResponsabilidades) ...[
                SegmentedButton<_AbaReservas>(
                  segments: [
                    ButtonSegment(
                      value: _AbaReservas.solicitadas,
                      label: Text(
                        'Solicitados (${viewModel.solicitadas.length})',
                      ),
                    ),
                    ButtonSegment(
                      value: _AbaReservas.responsavel,
                      label: Text(
                        'Sob responsabilidade '
                        '(${viewModel.sobMinhaResponsabilidade.length})',
                      ),
                    ),
                  ],
                  selected: {_abaSelecionada},
                  onSelectionChanged: (selecionadas) =>
                      setState(() => _abaSelecionada = selecionadas.first),
                ),
                const SizedBox(height: 16),
              ],
              _ListaDeReservas(
                viewModel: viewModel,
                mostrarResponsabilidade:
                    _abaSelecionada == _AbaReservas.responsavel,
              ),
              const SizedBox(height: 28),
              BotaoPadrao(
                texto: 'Sair',
                icone: Icons.logout,
                contornado: true,
                aoPressionar: () => _sair(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListaDeReservas extends StatelessWidget {
  final ReservasPerfilViewModel viewModel;
  final bool mostrarResponsabilidade;

  const _ListaDeReservas({
    required this.viewModel,
    required this.mostrarResponsabilidade,
  });

  @override
  Widget build(BuildContext context) {
    final reservas = mostrarResponsabilidade
        ? viewModel.sobMinhaResponsabilidade
        : viewModel.solicitadas;

    if (viewModel.isLoading && reservas.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final erro = viewModel.mensagemErro;
    if (erro != null) {
      return MensagemDeErro(
        mensagem: erro,
        aoTentarNovamente: viewModel.carregar,
      );
    }

    if (reservas.isEmpty) {
      return EstadoVazio(
        mensagem: mostrarResponsabilidade
            ? 'Nenhum agendamento está sob sua responsabilidade.'
            : 'Você ainda não solicitou agendamentos.',
        icone: Icons.event_busy_outlined,
      );
    }

    return Column(
      children: [
        for (final reserva in reservas) ...[
          _CartaoDeReserva(
            reserva: reserva,
            mostrarSolicitante: mostrarResponsabilidade,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _CartaoDeReserva extends StatelessWidget {
  final Reserva reserva;
  final bool mostrarSolicitante;

  const _CartaoDeReserva({
    required this.reserva,
    required this.mostrarSolicitante,
  });

  @override
  Widget build(BuildContext context) {
    return CartaoEntidade(
      icone: Icons.event_note_outlined,
      titulo: reserva.finalidade,
      acao: SeloStatusReserva(status: reserva.status),
      aoTocar: () => mostrarPainelModal<void>(
        context: context,
        construir: (_) => PainelDetalhesReserva(
          reserva: reserva,
          podeCancelar: false,
          aoCancelar: () {},
        ),
      ),
      corpo: [
        LinhaCartao(
          icone: Icons.calendar_today_outlined,
          titulo: 'Data e horário',
          valor: reserva.periodoFormatado,
        ),
        LinhaCartao(
          icone: Icons.meeting_room_outlined,
          titulo: 'Sala',
          valor: reserva.sala.nomeComPredio,
        ),
        LinhaCartao(
          icone: Icons.person_outline,
          titulo: mostrarSolicitante ? 'Solicitante' : 'Responsável',
          valor: mostrarSolicitante
              ? reserva.solicitante.nome
              : reserva.responsavel.nome,
        ),
      ],
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
