import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reserva_if/model/usuario/credencial/tipo_entrada.dart';
import 'package:reserva_if/model/usuario/departamento_elegivel.dart';
import 'package:reserva_if/model/usuario/perfil.dart';
import 'package:reserva_if/services/services_usuario.dart';
import 'package:reserva_if/utils/validator.dart';
import 'package:reserva_if/view/telas/tela_login.dart';
import 'package:reserva_if/view/theme/app_estilos.dart';
import 'package:reserva_if/view/widgets/botao_padrao.dart';
import 'package:reserva_if/view/widgets/caixa_aviso.dart';
import 'package:reserva_if/view/widgets/campo_selecao.dart';
import 'package:reserva_if/view/widgets/campo_texto.dart';
import 'package:reserva_if/view/widgets/campos_formulario.dart';
import 'package:reserva_if/view/widgets/feedback_usuario.dart';
import 'package:reserva_if/view/widgets/formulario/validacao_formulario.dart';
import 'package:reserva_if/view/widgets/reserva_if_logo.dart';
import 'package:reserva_if/view/widgets/scaffold_de_autenticacao.dart';
import 'package:reserva_if/viewmodel/sessao/sessao_viewmodel.dart';
import 'package:reserva_if/viewmodel/usuario/cadastro_viewmodel.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _chaveDoFormulario = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _identificadorController = TextEditingController();
  final _senhaController = TextEditingController();
  late final _viewModel = CadastroViewModel(service: ServicesUsuario());

  @override
  void initState() {
    super.initState();
    _viewModel.carregarDepartamentos();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _identificadorController.dispose();
    _senhaController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _selecionarPerfil(Perfil? perfil) {
    if (perfil == null) return;
    if (perfil.identificador != _viewModel.perfil.identificador) {
      _identificadorController.clear();
    }
    _viewModel.selecionarPerfil(perfil);
  }

  Future<void> _cadastrar() async {
    if (!validarRevelandoCampoInvalido(_chaveDoFormulario)) return;

    final cadastrou = await _viewModel.cadastrar(
      nome: _nomeController.text,
      email: _emailController.text,
      telefone: _telefoneController.text,
      identificador: _identificadorController.text,
      senha: _senhaController.text,
    );

    if (!mounted) return;

    if (!cadastrou) {
      final mensagemErro = _viewModel.mensagemErro;
      if (mensagemErro != null) mostrarErro(context, mensagemErro);
      return;
    }

    final entrou = await context.read<SessaoViewModel>().entrar(
      entrada: _identificadorController.text,
      senha: _senhaController.text,
    );

    if (!mounted || entrou) return;

    mostrarInfo(context, 'Conta criada. Entre com seus dados.');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const TelaLogin()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entrando = context.watch<SessaoViewModel>().isLoading;

    return ScaffoldDeAutenticacao(
      corpo: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppEstilos.espacoPagina,
            8,
            AppEstilos.espacoPagina,
            32,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) {
                final ocupado = _viewModel.isLoading || entrando;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _CabecalhoDoCadastro(),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _chaveDoFormulario,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _SecaoConta(
                                perfil: _viewModel.perfil,
                                habilitado: !ocupado,
                                aoSelecionar: _selecionarPerfil,
                              ),
                              const _DivisorDeSecao(),
                              _SecaoDadosPessoais(
                                nomeController: _nomeController,
                                emailController: _emailController,
                                telefoneController: _telefoneController,
                                habilitado: !ocupado,
                              ),
                              const _DivisorDeSecao(),
                              _SecaoVinculo(
                                viewModel: _viewModel,
                                identificadorController:
                                    _identificadorController,
                                habilitado: !ocupado,
                              ),
                              const _DivisorDeSecao(),
                              _SecaoAcesso(
                                senhaController: _senhaController,
                                habilitado: !ocupado,
                                aoConcluir: _cadastrar,
                              ),
                              const SizedBox(height: 28),
                              BotaoPadrao(
                                texto: 'Criar conta',
                                carregando: ocupado,
                                aoPressionar: _cadastrar,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _CabecalhoDoCadastro extends StatelessWidget {
  const _CabecalhoDoCadastro();

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: tema.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppEstilos.raioCartao),
          ),
          child: const ReservaIfLogo(width: 68, height: 68),
        ),
        const SizedBox(height: 16),
        Text('Criar conta', style: tema.textTheme.headlineSmall),
      ],
    );
  }
}

class _DivisorDeSecao extends StatelessWidget {
  const _DivisorDeSecao();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Divider(height: 1),
    );
  }
}

class _SecaoConta extends StatelessWidget {
  final Perfil perfil;
  final bool habilitado;
  final ValueChanged<Perfil?> aoSelecionar;

  const _SecaoConta({
    required this.perfil,
    required this.habilitado,
    required this.aoSelecionar,
  });

  static IconData _iconeDe(Perfil perfil) => switch (perfil) {
    Perfil.aluno => Icons.school_outlined,
    Perfil.professor => Icons.co_present_outlined,
    Perfil.tecnico => Icons.badge_outlined,
    Perfil.coordenador => Icons.verified_user_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CampoSelecao<Perfil>(
          rotulo: 'Conta',
          valor: perfil,
          opcoes: Perfil.values,
          rotuloDe: (opcao) => opcao.rotulo,
          iconeDe: _iconeDe,
          habilitado: habilitado,
          validador: Validator.selecaoObrigatoria,
          aoMudar: aoSelecionar,
        ),
        const SizedBox(height: 8),
        dicaDeSeletor(
          context,
          'Você vai entrar com seu ${perfil.identificador.rotulo}.',
        ),
      ],
    );
  }
}

class _SecaoDadosPessoais extends StatelessWidget {
  final TextEditingController nomeController;
  final TextEditingController emailController;
  final TextEditingController telefoneController;
  final bool habilitado;

  const _SecaoDadosPessoais({
    required this.nomeController,
    required this.emailController,
    required this.telefoneController,
    required this.habilitado,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        tituloDeSecaoFormulario(context, 'Seus dados'),
        CampoTexto(
          rotulo: 'Nome completo',
          controller: nomeController,
          habilitado: habilitado,
          capitalizacao: TextCapitalization.words,
          acaoDoTeclado: TextInputAction.next,
          validador: Validator.validarNome,
        ),
        const SizedBox(height: AppEstilos.espacoEntreCampos),
        CampoTexto(
          rotulo: 'E-mail',
          controller: emailController,
          dica: 'nome@ifes.edu.br',
          habilitado: habilitado,
          tipoDeTeclado: TextInputType.emailAddress,
          acaoDoTeclado: TextInputAction.next,
          validador: Validator.validarEmailObrigatorio,
        ),
        const SizedBox(height: AppEstilos.espacoEntreCampos),
        CampoTexto(
          rotulo: 'Telefone',
          controller: telefoneController,
          dica: '(27) 99999-0000',
          opcional: true,
          habilitado: habilitado,
          tipoDeTeclado: TextInputType.phone,
          acaoDoTeclado: TextInputAction.next,
          validador: Validator.validarTelefone,
        ),
      ],
    );
  }
}

class _SecaoVinculo extends StatelessWidget {
  final CadastroViewModel viewModel;
  final TextEditingController identificadorController;
  final bool habilitado;

  const _SecaoVinculo({
    required this.viewModel,
    required this.identificadorController,
    required this.habilitado,
  });

  static const _duracaoDaTroca = Duration(milliseconds: 200);

  String get _titulo =>
      viewModel.perfil == Perfil.aluno ? 'Matrícula' : 'Vínculo com o Ifes';

  @override
  Widget build(BuildContext context) {
    final duracao = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : _duracaoDaTroca;
    final perfil = viewModel.perfil;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        tituloDeSecaoFormulario(context, _titulo),
        AnimatedSize(
          duration: duracao,
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(
            duration: duracao,
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            layoutBuilder: (atual, anteriores) => Stack(
              alignment: Alignment.topCenter,
              children: [...anteriores, ?atual],
            ),
            child: _CamposDoVinculo(
              key: ValueKey(perfil.identificador),
              viewModel: viewModel,
              identificadorController: identificadorController,
              habilitado: habilitado,
            ),
          ),
        ),
      ],
    );
  }
}

class _CamposDoVinculo extends StatelessWidget {
  final CadastroViewModel viewModel;
  final TextEditingController identificadorController;
  final bool habilitado;

  const _CamposDoVinculo({
    super.key,
    required this.viewModel,
    required this.identificadorController,
    required this.habilitado,
  });

  @override
  Widget build(BuildContext context) {
    final perfil = viewModel.perfil;
    final identificador = perfil.identificador;
    final ehMatricula = identificador == TipoEntrada.matricula;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CampoTexto(
          rotulo: identificador.rotulo,
          controller: identificadorController,
          dica: ehMatricula
              ? 'Como aparece no seu comprovante'
              : 'Somente números',
          habilitado: habilitado,
          tipoDeTeclado: ehMatricula
              ? TextInputType.text
              : TextInputType.number,
          acaoDoTeclado: TextInputAction.next,
          validador: Validator.validarIdentificador(identificador),
        ),
        if (perfil.exigeDepartamento) ...[
          const SizedBox(height: AppEstilos.espacoEntreCampos),
          _SeletorDeDepartamento(viewModel: viewModel, habilitado: habilitado),
        ],
      ],
    );
  }
}

class _SeletorDeDepartamento extends StatelessWidget {
  final CadastroViewModel viewModel;
  final bool habilitado;

  const _SeletorDeDepartamento({
    required this.viewModel,
    required this.habilitado,
  });

  @override
  Widget build(BuildContext context) {
    final opcoes = viewModel.opcoesDeVinculo;

    return _SeletorComCarga<DepartamentoElegivel>(
      rotulo: 'Departamento',
      carregando: viewModel.isCarregandoVinculos,
      mensagemErro: viewModel.mensagemErroVinculos,
      aoTentarDeNovo: viewModel.carregarDepartamentos,
      opcoes: opcoes,
      selecionado: _opcaoComId(
        opcoes,
        (opcao) => opcao.id,
        viewModel.vinculoId,
      ),
      rotuloDe: (opcao) => opcao.rotuloDeVinculo,
      habilitado: habilitado,
      aoMudar: (opcao) => viewModel.selecionarVinculo(opcao?.id),
    );
  }
}

T? _opcaoComId<T>(List<T> opcoes, String? Function(T) idDe, String? id) {
  for (final opcao in opcoes) {
    if (idDe(opcao) == id) return opcao;
  }
  return null;
}

class _SeletorComCarga<T> extends StatelessWidget {
  final String rotulo;
  final bool carregando;
  final String? mensagemErro;
  final VoidCallback aoTentarDeNovo;
  final List<T> opcoes;
  final T? selecionado;
  final String Function(T) rotuloDe;
  final bool habilitado;
  final ValueChanged<T?> aoMudar;

  const _SeletorComCarga({
    required this.rotulo,
    required this.carregando,
    required this.mensagemErro,
    required this.aoTentarDeNovo,
    required this.opcoes,
    required this.selecionado,
    required this.rotuloDe,
    required this.habilitado,
    required this.aoMudar,
  });

  @override
  Widget build(BuildContext context) {
    final erro = mensagemErro;

    if (erro != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          rotuloDeCampo(context, rotulo),
          CaixaAviso(
            mensagem: erro,
            acao: BotaoDeTexto(
              texto: 'Tentar de novo',
              aoPressionar: aoTentarDeNovo,
            ),
          ),
        ],
      );
    }

    return CampoSelecao<T>(
      key: ValueKey(carregando),
      rotulo: rotulo,
      valor: selecionado,
      opcoes: opcoes,
      rotuloDe: rotuloDe,
      dica: carregando ? 'Carregando…' : 'Selecione',
      habilitado: habilitado && !carregando,
      validador: Validator.selecaoObrigatoria,
      aoMudar: aoMudar,
    );
  }
}

class _SecaoAcesso extends StatelessWidget {
  final TextEditingController senhaController;
  final bool habilitado;
  final VoidCallback aoConcluir;

  const _SecaoAcesso({
    required this.senhaController,
    required this.habilitado,
    required this.aoConcluir,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        tituloDeSecaoFormulario(context, 'Acesso'),
        CampoTexto(
          rotulo: 'Senha',
          controller: senhaController,
          dica: 'Mínimo de ${Validator.minimoCaracteresSenha} caracteres',
          ehSenha: true,
          habilitado: habilitado,
          acaoDoTeclado: TextInputAction.next,
          validador: Validator.validarSenha,
        ),
        const SizedBox(height: AppEstilos.espacoEntreCampos),
        CampoTexto(
          rotulo: 'Confirmar senha',
          ehSenha: true,
          habilitado: habilitado,
          acaoDoTeclado: TextInputAction.done,
          validador: (valor) =>
              Validator.validarConfirmacaoSenha(valor, senhaController.text),
          aoSubmeter: (_) => aoConcluir(),
        ),
      ],
    );
  }
}
