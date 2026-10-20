import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reserva_if/model/predio/predio.dart';
import 'package:reserva_if/model/reserva/horario_do_dia.dart';
import 'package:reserva_if/model/sala/sala.dart';
import 'package:reserva_if/services/services_cancelamento.dart';
import 'package:reserva_if/services/services_predio.dart';
import 'package:reserva_if/services/services_reserva.dart';
import 'package:reserva_if/view/reserva/nova_reserva_view.dart';
import 'package:reserva_if/view/reserva/widgets/acao_sobre_reserva.dart';
import 'package:reserva_if/view/reserva/widgets/lista_horarios_do_dia.dart';
import 'package:reserva_if/view/reserva/widgets/painel_horario_livre.dart';
import 'package:reserva_if/view/theme/app_cores.dart';
import 'package:reserva_if/view/theme/app_estilos.dart';
import 'package:reserva_if/view/widgets/app_bar_padrao.dart';
import 'package:reserva_if/view/widgets/calendario_mensal.dart';
import 'package:reserva_if/view/widgets/campo_selecao.dart';
import 'package:reserva_if/view/widgets/corpo_com_estado.dart';
import 'package:reserva_if/view/widgets/estados.dart';
import 'package:reserva_if/view/widgets/painel_modal.dart';
import 'package:reserva_if/viewmodel/reserva/agendamento_viewmodel.dart';
import 'package:reserva_if/viewmodel/reserva/reservas_mudaram.dart';
import 'package:reserva_if/viewmodel/sessao/sessao_viewmodel.dart';

class AgendamentoView extends StatefulWidget {
  final Predio predio;

  const AgendamentoView({super.key, required this.predio});

  @override
  State<AgendamentoView> createState() => _AgendamentoViewState();
}

class _AgendamentoViewState extends State<AgendamentoView> {
  late final AgendamentoViewModel _viewModel = AgendamentoViewModel(
    predio: widget.predio,
    usuario: context.read<SessaoViewModel>().usuario!,
    servicePredio: ServicesPredio(),
    serviceReserva: ServicesReserva(),
    reservasMudaram: context.read<ReservasMudaram>(),
    serviceCancelamento: ServicesCancelamento(),
  );

  @override
  void initState() {
    super.initState();
    _viewModel.carregarSalas();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _aoTocarHorario(HorarioDoDia horario) {
    final reserva = horario.reserva;

    if (reserva == null) {
      _abrirHorarioLivre(horario);
    } else {
      abrirDetalhesDaReserva(context, reserva: reserva, viewModel: _viewModel);
    }
  }

  void _abrirHorarioLivre(HorarioDoDia horario) {
    final sala = _viewModel.salaSelecionada;
    if (sala == null) return;

    mostrarPainelModal<void>(
      context: context,
      construir: (_) => PainelHorarioLivre(
        horario: horario,
        sala: sala,
        aoReservar: () => _reservar(horario, sala),
      ),
    );
  }

  void _reservar(HorarioDoDia horario, Sala sala) {
    Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => NovaReservaView(horario: horario, sala: sala),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final geracao = context.watch<ReservasMudaram>().geracao;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _viewModel.sincronizarCom(geracao);
    });

    return Scaffold(
      appBar: const AppBarPadrao(titulo: 'Agendamentos'),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) => RefreshIndicator(
          onRefresh: _viewModel.recarregar,
          child: CorpoComEstado(
            isLoading: _viewModel.isLoading,
            mensagemErro: _viewModel.mensagemErro,
            vazio: _viewModel.salas.isEmpty,
            manterConteudoAoRecarregar: true,
            aoTentarNovamente: _viewModel.carregarSalas,
            construirVazio: (_) => const EstadoVazio(
              mensagem: 'Este prédio ainda não tem salas disponíveis.',
              icone: Icons.meeting_room_outlined,
            ),
            construirConteudo: (_) => _ConteudoDoAgendamento(
              viewModel: _viewModel,
              aoTocarHorario: _aoTocarHorario,
            ),
          ),
        ),
      ),
    );
  }
}

class _ConteudoDoAgendamento extends StatelessWidget {
  final AgendamentoViewModel viewModel;
  final ValueChanged<HorarioDoDia> aoTocarHorario;

  const _ConteudoDoAgendamento({
    required this.viewModel,
    required this.aoTocarHorario,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppEstilos.espacoPagina,
        8,
        AppEstilos.espacoPagina,
        32,
      ),
      children: [
        CampoSelecao<Sala>(
          rotulo: 'Selecionar sala',
          valor: viewModel.salaSelecionada,
          opcoes: viewModel.salas,
          rotuloDe: (sala) => sala.nome,
          iconeDe: (_) => Icons.meeting_room_outlined,
          dica: 'Escolha uma sala',
          aoMudar: viewModel.selecionarSala,
        ),
        const SizedBox(height: 24),
        if (viewModel.salaSelecionada == null)
          const CartaoVazio(
            icone: Icons.meeting_room_outlined,
            mensagem:
                'Escolha uma sala para ver a agenda e os horários do dia.',
          )
        else ...[
          CalendarioMensal(
            diasMarcados: viewModel.diasComReserva,
            diaSelecionado: viewModel.diaSelecionado,
            carregando: viewModel.isCarregandoReservas,
            aoSelecionarDia: viewModel.selecionarDia,
          ),
          const SizedBox(height: 28),
          _CabecalhoDosHorarios(viewModel: viewModel),
          const SizedBox(height: 12),
          _SecaoDeHorarios(
            viewModel: viewModel,
            aoTocarHorario: aoTocarHorario,
          ),
        ],
      ],
    );
  }
}

class _CabecalhoDosHorarios extends StatelessWidget {
  final AgendamentoViewModel viewModel;

  const _CabecalhoDosHorarios({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final mostrarLivres = viewModel.mensagemErroReservas == null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Horários do dia', style: textos.titleMedium),
              const SizedBox(height: 2),
              Text(
                viewModel.rotuloDoDiaSelecionado,
                style: textos.bodySmall?.copyWith(
                  color: AppCores.textoSecundario,
                ),
              ),
            ],
          ),
        ),
        if (viewModel.isExecutandoAcao) ...[
          const SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
        ],
        if (mostrarLivres) _SeloDeLivres(rotulo: viewModel.rotuloLivres),
      ],
    );
  }
}

class _SeloDeLivres extends StatelessWidget {
  final String rotulo;

  const _SeloDeLivres({required this.rotulo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppCores.fundoIcone,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        rotulo,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppCores.acao,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SecaoDeHorarios extends StatelessWidget {
  final AgendamentoViewModel viewModel;
  final ValueChanged<HorarioDoDia> aoTocarHorario;

  const _SecaoDeHorarios({
    required this.viewModel,
    required this.aoTocarHorario,
  });

  @override
  Widget build(BuildContext context) {
    final erro = viewModel.mensagemErroReservas;

    if (erro != null) {
      return MensagemDeErro(
        mensagem: erro,
        aoTentarNovamente: viewModel.carregarReservas,
      );
    }

    if (viewModel.isCarregandoReservas && viewModel.reservas.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return ListaHorariosDoDia(
      horarios: viewModel.horariosDoDia,
      aoTocar: aoTocarHorario,
    );
  }
}
