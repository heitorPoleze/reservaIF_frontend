import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reserva_if/model/reserva/conflito_de_horario.dart';
import 'package:reserva_if/services/services_cancelamento.dart';
import 'package:reserva_if/view/pendencias/widgets/cartao_pessoa_do_conflito.dart';
import 'package:reserva_if/view/theme/app_cores.dart';
import 'package:reserva_if/view/theme/app_estilos.dart';
import 'package:reserva_if/view/widgets/app_bar_padrao.dart';
import 'package:reserva_if/view/widgets/botao_padrao.dart';
import 'package:reserva_if/view/widgets/campos_formulario.dart';
import 'package:reserva_if/view/widgets/dialogos.dart';
import 'package:reserva_if/view/widgets/feedback_usuario.dart';
import 'package:reserva_if/viewmodel/reserva/reservas_mudaram.dart';
import 'package:reserva_if/viewmodel/reserva/resolver_conflito_viewmodel.dart';

class ResolverConflitoView extends StatefulWidget {
  final ConflitoDeHorario conflito;

  const ResolverConflitoView({super.key, required this.conflito});

  @override
  State<ResolverConflitoView> createState() => _ResolverConflitoViewState();
}

class _ResolverConflitoViewState extends State<ResolverConflitoView> {
  late final ResolverConflitoViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ResolverConflitoViewModel(
      conflito: widget.conflito,
      service: ServicesCancelamento(),
      reservasMudaram: context.read<ReservasMudaram>(),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _trocar() async {
    final conflito = _viewModel.conflito;
    final confirmou = await confirmarAcao(
      context,
      titulo: 'Trocar o horário?',
      mensagem:
          'A reserva de ${conflito.nomeDoAluno} será cancelada e o horário '
          'passará para ${conflito.nomeDoProfessor}.',
      rotuloConfirmar: 'Trocar',
      corConfirmar: AppCores.acao,
    );
    if (!confirmou || !mounted) return;

    _concluir(await _viewModel.trocar(), 'Horário trocado.');
  }

  Future<void> _declinar() async {
    final confirmou = await confirmarAcao(
      context,
      titulo: 'Declinar a solicitação?',
      mensagem: 'A reserva de ${_viewModel.conflito.nomeDoAluno} será mantida.',
      rotuloConfirmar: 'Declinar',
    );
    if (!confirmou || !mounted) return;

    _concluir(await _viewModel.declinar(), 'Solicitação declinada.');
  }

  void _concluir(bool sucesso, String mensagemSucesso) {
    if (!mounted) return;

    if (!sucesso) {
      mostrarErro(context, _viewModel.mensagemErro!);
      return;
    }
    mostrarSucesso(context, mensagemSucesso);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarPadrao(titulo: 'Conflito'),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) => _CorpoDoConflito(
          conflito: _viewModel.conflito,
          decidindo: _viewModel.isLoading,
          aoTrocar: _trocar,
          aoDeclinar: _declinar,
        ),
      ),
    );
  }
}

class _CorpoDoConflito extends StatelessWidget {
  final ConflitoDeHorario conflito;
  final bool decidindo;
  final VoidCallback aoTrocar;
  final VoidCallback aoDeclinar;

  const _CorpoDoConflito({
    required this.conflito,
    required this.decidindo,
    required this.aoTrocar,
    required this.aoDeclinar,
  });

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(AppEstilos.espacoPagina),
      children: [
        _Bloco(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(conflito.salaComCapacidade, style: textos.titleMedium),
              const SizedBox(height: 4),
              Text(
                conflito.horarioComData,
                style: textos.bodyMedium?.copyWith(
                  color: AppCores.textoSecundario,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        tituloDeSecaoFormulario(
          context,
          'Primeira pessoa a realizar a reserva',
        ),
        CartaoPessoaDoConflito(
          nome: conflito.nomeDoAluno,
          rotulo: conflito.rotuloDoAluno,
        ),
        const SizedBox(height: 24),
        tituloDeSecaoFormulario(context, 'Solicitante da troca de horário'),
        CartaoPessoaDoConflito(
          nome: conflito.nomeDoProfessor,
          rotulo: conflito.rotuloDoProfessor,
        ),
        const SizedBox(height: 24),
        tituloDeSecaoFormulario(context, 'Justificativa'),
        _Bloco(child: Text(conflito.justificativa, style: textos.bodyLarge)),
        const SizedBox(height: 32),
        BotaoPadrao(
          texto: 'Trocar',
          icone: Icons.sync,
          carregando: decidindo,
          aoPressionar: aoTrocar,
        ),
        const SizedBox(height: 16),
        BotaoPadrao(
          texto: 'Declinar',
          icone: Icons.close,
          contornado: true,
          corDeFundo: AppCores.superficie,
          corDoConteudo: AppCores.erro,
          carregando: decidindo,
          aoPressionar: aoDeclinar,
        ),
      ],
    );
  }
}

class _Bloco extends StatelessWidget {
  final Widget child;

  const _Bloco({required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: AppEstilos.cartao(),
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    );
  }
}
