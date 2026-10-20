import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reserva_if/model/reserva/reserva.dart';
import 'package:reserva_if/model/reserva/status_reserva.dart';
import 'package:reserva_if/model/usuario/perfil_usuario.dart';
import 'package:reserva_if/services/services_cancelamento.dart';
import 'package:reserva_if/services/services_reserva.dart';
import 'package:reserva_if/view/reserva/widgets/abas_por_status.dart';
import 'package:reserva_if/view/reserva/widgets/acoes_de_analise.dart';
import 'package:reserva_if/view/reserva/widgets/analisar_reserva.dart';
import 'package:reserva_if/view/reserva/widgets/acao_sobre_reserva.dart';
import 'package:reserva_if/view/reserva/widgets/selo_status_reserva.dart';
import 'package:reserva_if/view/theme/app_cores.dart';
import 'package:reserva_if/view/theme/app_estilos.dart';
import 'package:reserva_if/view/widgets/app_bar_padrao.dart';
import 'package:reserva_if/view/widgets/botao_padrao.dart';
import 'package:reserva_if/view/widgets/cartao_entidade.dart';
import 'package:reserva_if/view/widgets/dialogos.dart';
import 'package:reserva_if/view/widgets/estados.dart';
import 'package:reserva_if/viewmodel/reserva/reservas_mudaram.dart';
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
      serviceCancelamento: ServicesCancelamento(),
      reservasMudaram: context.read<ReservasMudaram>(),
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
    final geracao = context.watch<ReservasMudaram>().geracao;

    if (usuario == null || viewModel == null) {
      return const SizedBox.shrink();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) viewModel.sincronizarCom(geracao);
    });

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
              _SecaoMeusAgendamentos(
                viewModel: viewModel,
                abaSelecionada: _abaSelecionada,
                aoTrocarAba: (aba) => setState(() => _abaSelecionada = aba),
                intencoes: _IntencoesDeReserva(
                  aoTocar: (reserva) => abrirDetalhesDaReserva(
                    context,
                    reserva: reserva,
                    viewModel: viewModel,
                  ),
                  aoAprovar: (reserva) => aprovarReservaComFeedback(
                    context,
                    reserva: reserva,
                    viewModel: viewModel,
                  ),
                  aoRejeitar: (reserva) => rejeitarReservaComFeedback(
                    context,
                    reserva: reserva,
                    viewModel: viewModel,
                  ),
                ),
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

class _IntencoesDeReserva {
  final ValueChanged<Reserva> aoTocar;
  final ValueChanged<Reserva> aoAprovar;
  final ValueChanged<Reserva> aoRejeitar;

  const _IntencoesDeReserva({
    required this.aoTocar,
    required this.aoAprovar,
    required this.aoRejeitar,
  });
}

class _SecaoMeusAgendamentos extends StatelessWidget {
  final ReservasPerfilViewModel viewModel;
  final _AbaReservas abaSelecionada;
  final ValueChanged<_AbaReservas> aoTrocarAba;
  final _IntencoesDeReserva intencoes;

  const _SecaoMeusAgendamentos({
    required this.viewModel,
    required this.abaSelecionada,
    required this.aoTrocarAba,
    required this.intencoes,
  });

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(top: 4),
      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
      title: Text('Meus agendamentos', style: textos.titleLarge),
      subtitle: Text(
        viewModel.rotuloDeSolicitados,
        style: textos.bodySmall?.copyWith(color: AppCores.textoSecundario),
      ),
      trailing: viewModel.isAtualizandoReserva
          ? const SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
      children: [
        if (viewModel.podeVerResponsabilidades) ...[
          SegmentedButton<_AbaReservas>(
            segments: [
              ButtonSegment(
                value: _AbaReservas.solicitadas,
                label: Text('Solicitados (${viewModel.solicitadas.length})'),
              ),
              ButtonSegment(
                value: _AbaReservas.responsavel,
                label: Text(
                  'Sob responsabilidade '
                  '(${viewModel.sobMinhaResponsabilidade.length})',
                ),
              ),
            ],
            selected: {abaSelecionada},
            onSelectionChanged: (selecionadas) =>
                aoTrocarAba(selecionadas.first),
          ),
          const SizedBox(height: 16),
        ],
        _ListaDeReservas(
          viewModel: viewModel,
          mostrarResponsabilidade: abaSelecionada == _AbaReservas.responsavel,
          intencoes: intencoes,
        ),
      ],
    );
  }
}

class _ListaDeReservas extends StatelessWidget {
  final ReservasPerfilViewModel viewModel;
  final bool mostrarResponsabilidade;
  final _IntencoesDeReserva intencoes;

  const _ListaDeReservas({
    required this.viewModel,
    required this.mostrarResponsabilidade,
    required this.intencoes,
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

    return AbasPorStatus(
      contagemDe: (status) => _reservasCom(status).length,
      construirColuna: (status) => _ColunaDeStatus(
        status: status,
        reservas: _reservasCom(status),
        mostrarSolicitante: mostrarResponsabilidade,
        viewModel: viewModel,
        intencoes: intencoes,
      ),
    );
  }

  List<Reserva> _reservasCom(StatusReserva status) => mostrarResponsabilidade
      ? viewModel.sobMinhaResponsabilidadeCom(status)
      : viewModel.solicitadasCom(status);
}

class _ColunaDeStatus extends StatelessWidget {
  final StatusReserva status;
  final List<Reserva> reservas;
  final bool mostrarSolicitante;
  final ReservasPerfilViewModel viewModel;
  final _IntencoesDeReserva intencoes;

  const _ColunaDeStatus({
    required this.status,
    required this.reservas,
    required this.mostrarSolicitante,
    required this.viewModel,
    required this.intencoes,
  });

  @override
  Widget build(BuildContext context) {
    if (reservas.isEmpty) {
      return EstadoVazio(
        mensagem: 'Nenhum agendamento com status "${status.rotulo}".',
        icone: Icons.event_busy_outlined,
      );
    }

    return Column(
      children: [
        for (final reserva in reservas) ...[
          _CartaoDeReserva(
            reserva: reserva,
            mostrarSolicitante: mostrarSolicitante,
            aoTocar: () => intencoes.aoTocar(reserva),
            acoesDeAnalise: viewModel.podeAnalisar(reserva)
                ? AcoesDeAnalise(
                    aoAprovar: viewModel.isAnalisando
                        ? null
                        : () => intencoes.aoAprovar(reserva),
                    aoRejeitar: viewModel.isAnalisando
                        ? null
                        : () => intencoes.aoRejeitar(reserva),
                  )
                : null,
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
  final VoidCallback aoTocar;
  final Widget? acoesDeAnalise;

  const _CartaoDeReserva({
    required this.reserva,
    required this.mostrarSolicitante,
    required this.aoTocar,
    this.acoesDeAnalise,
  });

  @override
  Widget build(BuildContext context) {
    final finalidade = reserva.finalidade.trim();

    return CartaoEntidade(
      icone: Icons.event_note_outlined,
      titulo: reserva.periodoFormatado,
      acao: acoesDeAnalise ?? SeloStatusReserva(status: reserva.status),
      aoTocar: aoTocar,
      corpo: [
        if (finalidade.isNotEmpty)
          LinhaCartao(
            icone: Icons.subject,
            titulo: 'Finalidade',
            valor: finalidade,
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
