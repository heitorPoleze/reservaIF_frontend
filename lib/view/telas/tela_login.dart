import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reserva_if/utils/validator.dart';
import 'package:reserva_if/view/widgets/botao_padrao.dart';
import 'package:reserva_if/view/widgets/campo_texto.dart';
import 'package:reserva_if/view/widgets/feedback_usuario.dart';
import 'package:reserva_if/view/widgets/formulario/validacao_formulario.dart';
import 'package:reserva_if/view/widgets/reserva_if_logo.dart';
import 'package:reserva_if/view/widgets/scaffold_de_autenticacao.dart';
import 'package:reserva_if/viewmodel/sessao/sessao_viewmodel.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _chaveDoFormulario = GlobalKey<FormState>();
  final _entradaController = TextEditingController();
  final _senhaController = TextEditingController();

  @override
  void dispose() {
    _entradaController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!validarRevelandoCampoInvalido(_chaveDoFormulario)) return;

    final sessao = context.read<SessaoViewModel>();
    final entrou = await sessao.entrar(
      entrada: _entradaController.text,
      senha: _senhaController.text,
    );

    if (!mounted || entrou) return;

    final mensagemErro = sessao.mensagemErro;
    if (mensagemErro != null) mostrarErro(context, mensagemErro);
  }

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final ocupado = context.watch<SessaoViewModel>().isLoading;

    return ScaffoldDeAutenticacao(
      corpo: LayoutBuilder(
        builder: (context, restricoes) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: restricoes.maxHeight > 48
                  ? restricoes.maxHeight - 48
                  : 0,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 180,
                      height: 180,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: esquema.surface,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const ReservaIfLogo(width: 148, height: 148),
                    ),
                    const SizedBox(height: 40),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _chaveDoFormulario,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CampoTexto(
                                rotulo: 'Matrícula/SIAPE',
                                controller: _entradaController,
                                habilitado: !ocupado,
                                tipoDeTeclado: TextInputType.text,
                                acaoDoTeclado: TextInputAction.next,
                                validador: Validator.validarEntradaDeLogin,
                              ),
                              const SizedBox(height: 20),
                              CampoTexto(
                                rotulo: 'Senha',
                                controller: _senhaController,
                                ehSenha: true,
                                habilitado: !ocupado,
                                acaoDoTeclado: TextInputAction.done,
                                validador: Validator.validarSenhaLogin,
                                aoSubmeter: (_) => _entrar(),
                              ),
                              const SizedBox(height: 24),
                              BotaoPadrao(
                                texto: 'Entrar',
                                carregando: ocupado,
                                aoPressionar: _entrar,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
