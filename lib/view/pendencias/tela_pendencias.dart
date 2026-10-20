import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reserva_if/model/reserva/reserva.dart';
import 'package:reserva_if/services/services_reserva.dart';
import 'package:reserva_if/view/reserva/widgets/acoes_de_analise.dart';
import 'package:reserva_if/view/reserva/widgets/analisar_reserva.dart';
import 'package:reserva_if/view/theme/app_estilos.dart';
import 'package:reserva_if/view/widgets/app_bar_padrao.dart';
import 'package:reserva_if/view/widgets/cartao_entidade.dart';
import 'package:reserva_if/view/widgets/corpo_com_estado.dart';
import 'package:reserva_if/view/widgets/estados.dart';
import 'package:reserva_if/viewmodel/reserva/pendencias_viewmodel.dart';
import 'package:reserva_if/viewmodel/reserva/reservas_mudaram.dart';
import 'package:reserva_if/viewmodel/sessao/sessao_viewmodel.dart';

class TelaPendencias extends StatefulWidget {
  const TelaPendencias({super.key});

  @override
  State<TelaPendencias> createState() => _TelaPendenciasState();
}

class _TelaPendenciasState extends State<TelaPendencias> {
  PendenciasViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final usuario = context.read<SessaoViewModel>().usuario;
    if (usuario == null || _viewModel != null) return;

    _viewModel = PendenciasViewModel(
      usuario: usuario,
      service: ServicesReserva(),
      reservasMudaram: context.read<ReservasMudaram>(),
    )..carregar();
  }

  @override
  void dispose() {
    _viewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = _viewModel;
    final geracao = context.watch<ReservasMudaram>().geracao;

    if (viewModel == null) return const SizedBox.shrink();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) viewModel.sincronizarCom(geracao);
    });

    return Scaffold(
      appBar: const AppBarPadrao(titulo: 'Pendências'),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) => RefreshIndicator(
          onRefresh: viewModel.carregar,
          child: CorpoComEstado(
            isLoading: viewModel.isLoading,
            mensagemErro: viewModel.convites.isEmpty
                ? viewModel.mensagemErro
                : null,
            vazio: viewModel.convites.isEmpty,
            manterConteudoAoRecarregar: true,
            aoTentarNovamente: viewModel.carregar,
            construirVazio: (_) => const EstadoVazio(
              mensagem: 'Nenhum convite pendente.',
              icone: Icons.inventory_2_outlined,
            ),
            construirConteudo: (_) => _ListaDeConvites(
              viewModel: viewModel,
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
        ),
      ),
    );
  }
}

class _ListaDeConvites extends StatelessWidget {
  final PendenciasViewModel viewModel;
  final ValueChanged<Reserva> aoAprovar;
  final ValueChanged<Reserva> aoRejeitar;

  const _ListaDeConvites({
    required this.viewModel,
    required this.aoAprovar,
    required this.aoRejeitar,
  });

  @override
  Widget build(BuildContext context) {
    final bloqueado = viewModel.isAnalisando;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppEstilos.espacoPagina),
      children: [
        _CabecalhoDaSecao(
          titulo: 'Convites Pendentes',
          contagem: viewModel.rotuloDeConvites,
          carregando: bloqueado,
        ),
        const SizedBox(height: 16),
        for (final reserva in viewModel.convites) ...[
          _CartaoDeConvite(
            reserva: reserva,
            aoAprovar: bloqueado ? null : () => aoAprovar(reserva),
            aoRejeitar: bloqueado ? null : () => aoRejeitar(reserva),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _CabecalhoDaSecao extends StatelessWidget {
  final String titulo;
  final String contagem;
  final bool carregando;

  const _CabecalhoDaSecao({
    required this.titulo,
    required this.contagem,
    required this.carregando,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(titulo, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (carregando) ...[
          const SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
        ],
        Chip(label: Text(contagem)),
      ],
    );
  }
}

class _CartaoDeConvite extends StatelessWidget {
  final Reserva reserva;
  final VoidCallback? aoAprovar;
  final VoidCallback? aoRejeitar;

  const _CartaoDeConvite({
    required this.reserva,
    required this.aoAprovar,
    required this.aoRejeitar,
  });

  @override
  Widget build(BuildContext context) {
    final finalidade = reserva.finalidade.trim();

    return CartaoEntidade(
      icone: Icons.person_outline,
      titulo: reserva.solicitante.nome,
      acao: AcoesDeAnalise(aoAprovar: aoAprovar, aoRejeitar: aoRejeitar),
      corpo: [
        LinhaCartao(
          icone: Icons.meeting_room_outlined,
          titulo: 'Sala',
          valor: reserva.sala.nomeComPredio,
        ),
        LinhaCartao(
          icone: Icons.schedule,
          titulo: 'Horário',
          valor: reserva.periodoFormatado,
        ),
        if (finalidade.isNotEmpty)
          LinhaCartao(
            icone: Icons.subject,
            titulo: 'Finalidade',
            valor: finalidade,
          ),
      ],
    );
  }
}
