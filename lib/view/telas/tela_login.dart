import 'package:flutter/material.dart';
import 'package:reserva_if/utils/validator.dart';
import 'package:reserva_if/view/widgets/botao_padrao.dart';
import 'package:reserva_if/view/widgets/campo_texto.dart';
import 'package:reserva_if/view/widgets/reserva_if_logo.dart';
import 'package:reserva_if/view/widgets/scaffold_de_autenticacao.dart';

class TelaLogin extends StatefulWidget {
  final VoidCallback? aoEntrar;

  const TelaLogin({super.key, this.aoEntrar});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _chaveDoFormulario = GlobalKey<FormState>();

  void _entrar() {
    if (_chaveDoFormulario.currentState?.validate() ?? false) {
      widget.aoEntrar?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;

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
                                tipoDeTeclado: TextInputType.text,
                                acaoDoTeclado: TextInputAction.next,
                                validador: Validator.validarEntradaDeLogin,
                              ),
                              const SizedBox(height: 20),
                              CampoTexto(
                                rotulo: 'Senha',
                                ehSenha: true,
                                acaoDoTeclado: TextInputAction.done,
                                validador: Validator.validarSenhaLogin,
                                aoSubmeter: (_) => _entrar(),
                              ),
                              const SizedBox(height: 24),
                              BotaoPadrao(
                                texto: 'Entrar',
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
