import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reserva_if/model/reserva/horario_do_dia.dart';
import 'package:reserva_if/model/sala/sala.dart';
import 'package:reserva_if/model/usuario/servidor_resumo.dart';
import 'package:reserva_if/services/services_reserva.dart';
import 'package:reserva_if/services/services_usuario.dart';
import 'package:reserva_if/utils/validator.dart';
import 'package:reserva_if/view/theme/app_estilos.dart';
import 'package:reserva_if/view/widgets/app_bar_padrao.dart';
import 'package:reserva_if/view/widgets/botao_padrao.dart';
import 'package:reserva_if/view/widgets/campo_texto.dart';
import 'package:reserva_if/view/widgets/campo_selecao.dart';
import 'package:reserva_if/view/widgets/cartao_entidade.dart';
import 'package:reserva_if/view/widgets/dialogos.dart';
import 'package:reserva_if/view/widgets/estados.dart';
import 'package:reserva_if/view/widgets/feedback_usuario.dart';
import 'package:reserva_if/view/widgets/formulario/validacao_formulario.dart';
import 'package:reserva_if/viewmodel/reserva/nova_reserva_viewmodel.dart';
import 'package:reserva_if/viewmodel/sessao/sessao_viewmodel.dart';

class NovaReservaView extends StatefulWidget {
  final HorarioDoDia horario;
  final Sala sala;

  const NovaReservaView({super.key, required this.horario, required this.sala});

  @override
  State<NovaReservaView> createState() => _NovaReservaViewState();
}

class _NovaReservaViewState extends State<NovaReservaView> {
  final _chaveDoFormulario = GlobalKey<FormState>();
  final _justificativaController = TextEditingController();
  final _observacoesController = TextEditingController();

  late final NovaReservaViewModel _viewModel = NovaReservaViewModel(
    horario: widget.horario,
    sala: widget.sala,
    usuario: context.read<SessaoViewModel>().usuario!,
    service: ServicesReserva(),
    serviceUsuario: ServicesUsuario(),
  );

  bool get _temDadosPreenchidos =>
      _viewModel.responsavel != null ||
      _justificativaController.text.trim().isNotEmpty ||
      _observacoesController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _viewModel.carregarServidores();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _justificativaController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  Future<void> _reservar() async {
    if (!validarRevelandoCampoInvalido(_chaveDoFormulario)) return;

    final resultado = await _viewModel.reservar(
      justificativa: _justificativaController.text,
      observacoes: _observacoesController.text,
    );
    if (!mounted) return;

    if (resultado == null) {
      mostrarErro(
        context,
        _viewModel.mensagemErro ?? 'Não foi possível reservar o horário.',
      );
      return;
    }

    if (resultado.aguardaAprovacao) {
      mostrarInfo(context, resultado.mensagem);
    } else {
      mostrarSucesso(context, resultado.mensagem);
    }
    Navigator.pop(context, true);
  }

  Future<void> _aoTentarSair(bool saiu, Object? _) async {
    if (saiu || _viewModel.isLoading) return;

    final descartar = await confirmarDescarte(context);
    if (descartar && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        _viewModel,
        _justificativaController,
        _observacoesController,
      ]),
      builder: (context, _) => PopScope(
        canPop: !_temDadosPreenchidos && !_viewModel.isLoading,
        onPopInvokedWithResult: _aoTentarSair,
        child: Scaffold(
          appBar: const AppBarPadrao(titulo: 'Reservar horário'),
          body: Form(
            key: _chaveDoFormulario,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppEstilos.espacoPagina,
                16,
                AppEstilos.espacoPagina,
                32,
              ),
              children: [
                _ResumoDoHorario(horario: widget.horario, sala: widget.sala),
                const SizedBox(height: 24),
                if (_viewModel.exigeResponsavel) ...[
                  _CampoResponsavel(viewModel: _viewModel),
                  const SizedBox(height: AppEstilos.espacoEntreCampos),
                ],
                CampoTexto(
                  rotulo: 'Justificativa',
                  controller: _justificativaController,
                  dica: 'Ex.: Aula prática de Banco de Dados',
                  opcional: true,
                  maxLinhas: 3,
                  capitalizacao: TextCapitalization.sentences,
                  habilitado: !_viewModel.isLoading,
                  validador: Validator.descricaoOpcional,
                ),
                const SizedBox(height: AppEstilos.espacoEntreCampos),
                CampoTexto(
                  rotulo: 'Observações',
                  controller: _observacoesController,
                  dica: 'Ex.: Necessário uso de projetor',
                  opcional: true,
                  maxLinhas: 3,
                  capitalizacao: TextCapitalization.sentences,
                  habilitado: !_viewModel.isLoading,
                  validador: Validator.descricaoOpcional,
                ),
                const SizedBox(height: 28),
                BotaoPadrao(
                  texto: 'Reservar',
                  icone: Icons.check,
                  carregando: _viewModel.isLoading,
                  aoPressionar: _reservar,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CampoResponsavel extends StatelessWidget {
  final NovaReservaViewModel viewModel;

  const _CampoResponsavel({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final erro = viewModel.mensagemErroServidores;

    if (erro != null) {
      return MensagemDeErro(
        mensagem: erro,
        aoTentarNovamente: viewModel.carregarServidores,
        padding: const EdgeInsets.symmetric(vertical: 16),
      );
    }

    final carregando = viewModel.isCarregandoServidores;

    return CampoSelecao<ServidorResumo>(
      key: ValueKey(viewModel.servidores),
      rotulo: 'Responsável',
      valor: viewModel.responsavel,
      opcoes: viewModel.servidores,
      rotuloDe: (servidor) => servidor.nome,
      iconeDe: (_) => Icons.person_outline,
      grupoDe: (servidor) => servidor.perfil.rotulo,
      dica: carregando
          ? 'Carregando servidores...'
          : 'Escolha o servidor responsável',
      validador: Validator.selecaoObrigatoria,
      habilitado: !carregando && !viewModel.isLoading,
      aoMudar: viewModel.selecionarResponsavel,
    );
  }
}

class _ResumoDoHorario extends StatelessWidget {
  final HorarioDoDia horario;
  final Sala sala;

  const _ResumoDoHorario({required this.horario, required this.sala});

  @override
  Widget build(BuildContext context) {
    return CartaoEntidade(
      icone: Icons.event_available,
      titulo: 'Horário livre',
      corpo: [
        LinhaCartao(
          icone: Icons.calendar_today_outlined,
          titulo: 'Dia',
          valor: horario.diaFormatado,
        ),
        LinhaCartao(
          icone: Icons.schedule,
          titulo: 'Horário',
          valor: horario.intervaloFormatado,
        ),
        LinhaCartao(
          icone: Icons.meeting_room_outlined,
          titulo: 'Sala',
          valor: sala.nomeComPredio,
        ),
      ],
    );
  }
}
