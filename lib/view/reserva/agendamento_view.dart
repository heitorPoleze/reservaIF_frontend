import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reserva_if/model/predio/predio.dart';
import 'package:reserva_if/model/reserva/horario_do_dia.dart';
import 'package:reserva_if/model/reserva/modo_cancelamento.dart';
import 'package:reserva_if/model/reserva/reserva.dart';
import 'package:reserva_if/model/sala/sala.dart';
import 'package:reserva_if/services/services_predio.dart';
import 'package:reserva_if/services/services_reserva.dart';
import 'package:reserva_if/view/reserva/nova_reserva_view.dart';
import 'package:reserva_if/view/reserva/widgets/dialogo_justificativa_cancelamento.dart';
import 'package:reserva_if/view/reserva/widgets/lista_horarios_do_dia.dart';
import 'package:reserva_if/view/reserva/widgets/painel_detalhes_reserva.dart';
import 'package:reserva_if/view/reserva/widgets/painel_horario_livre.dart';
import 'package:reserva_if/view/theme/app_cores.dart';
import 'package:reserva_if/view/theme/app_estilos.dart';
import 'package:reserva_if/view/widgets/app_bar_padrao.dart';
import 'package:reserva_if/view/widgets/calendario_mensal.dart';
import 'package:reserva_if/view/widgets/campo_selecao.dart';
import 'package:reserva_if/view/widgets/estados.dart';
import 'package:reserva_if/view/widgets/feedback_usuario.dart';
import 'package:reserva_if/view/widgets/painel_modal.dart';
import 'package:reserva_if/viewmodel/reserva/agendamento_viewmodel.dart';
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
      _abrirDetalhes(reserva);
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

  Future<void> _reservar(HorarioDoDia horario, Sala sala) async {
    final reservou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => NovaReservaView(horario: horario, sala: sala),
      ),
    );

    if (reservou == true && mounted) _viewModel.carregarReservas();
  }

  void _abrirDetalhes(Reserva reserva) {
    mostrarPainelModal<void>(
      context: context,
      construir: (_) => PainelDetalhesReserva(
        reserva: reserva,
        modoCancelamento: _viewModel.modoDeCancelamento(reserva),
        aoCancelar: (modo) => _cancelar(reserva, modo),
      ),
    );
  }

  Future<void> _cancelar(Reserva reserva, ModoCancelamento modo) async {
    final justificativa = await pedirJustificativaDeCancelamento(
      context,
      modo,
    );
    if (justificativa == null || !mounted) return;

    final resultado = await _viewModel.cancelar(reserva, justificativa);
    if (!mounted) return;

    if (resultado == null) {
      mostrarErro(
        context,
        _viewModel.mensagemErroCancelamento ??
            'Não foi possível cancelar a reserva.',
      );
    } else if (resultado.solicitacaoEnviada) {
      mostrarInfo(context, resultado.mensagem);
    } else {
      mostrarSucesso(context, resultado.mensagem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarPadrao(titulo: 'Agendamentos'),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) => RefreshIndicator(
          onRefresh: _viewModel.recarregar,
          child: _ConteudoDoAgendamento(
            viewModel: _viewModel,
            aoTocarHorario: _aoTocarHorario,
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
        CalendarioMensal(
          diasMarcados: viewModel.diasComReserva,
          diaSelecionado: viewModel.diaSelecionado,
          carregando: viewModel.isCarregandoReservas,
          aoSelecionarDia: viewModel.selecionarDia,
        ),
        const SizedBox(height: 24),
        _SecaoDaSala(viewModel: viewModel, aoTocarHorario: aoTocarHorario),
      ],
    );
  }
}

class _SecaoDaSala extends StatelessWidget {
  final AgendamentoViewModel viewModel;
  final ValueChanged<HorarioDoDia> aoTocarHorario;

  const _SecaoDaSala({required this.viewModel, required this.aoTocarHorario});

  @override
  Widget build(BuildContext context) {
    final semSalas = viewModel.salas.isEmpty;

    if (semSalas && viewModel.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final erro = semSalas ? viewModel.mensagemErro : null;

    if (erro != null) {
      return MensagemDeErro(
        mensagem: erro,
        aoTentarNovamente: viewModel.carregarSalas,
      );
    }

    if (semSalas) {
      return const CartaoVazio(
        icone: Icons.meeting_room_outlined,
        mensagem: 'Este prédio ainda não tem salas disponíveis.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
        const SizedBox(height: 28),
        _CabecalhoDosHorarios(viewModel: viewModel),
        const SizedBox(height: 12),
        _SecaoDeHorarios(viewModel: viewModel, aoTocarHorario: aoTocarHorario),
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
    final mostrarLivres =
        viewModel.salaSelecionada != null &&
        viewModel.mensagemErroReservas == null;

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
        if (viewModel.isCancelando) ...[
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
    if (viewModel.salaSelecionada == null) {
      return const CartaoVazio(
        icone: Icons.meeting_room_outlined,
        mensagem: 'Escolha uma sala para ver os horários do dia.',
      );
    }

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
