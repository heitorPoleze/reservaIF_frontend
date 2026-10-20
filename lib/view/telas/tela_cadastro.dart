import 'package:flutter/material.dart';
import 'package:reserva_if/utils/validator.dart';
import 'package:reserva_if/view/widgets/botao_padrao.dart';
import 'package:reserva_if/view/widgets/reserva_if_logo.dart';

enum NivelAcesso { aluno, professor, coordenador }

class TelaCadastro extends StatefulWidget {
  final VoidCallback? aoCadastrar;

  const TelaCadastro({super.key, this.aoCadastrar});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _chaveDoFormulario = GlobalKey<FormState>();
  final _matriculaController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();

  String? _departamento;

  static const List<String> _departamentos = [
    'Informática',
    'Administração',
    'Agropecuária',
    'Biologia',
    'Matemática',
  ];

  @override
  void dispose() {
    _matriculaController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  void _cadastrar() {
    if (_chaveDoFormulario.currentState?.validate() ?? false) {
      if (widget.aoCadastrar != null) {
        widget.aoCadastrar!.call();
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Cadastro realizado com sucesso.')),
        );
    }
  }

  InputDecoration _decoracao({String? hint}) {
    return InputDecoration(hintText: hint);
  }

  Widget _rotulo(BuildContext context, String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(texto, style: Theme.of(context).textTheme.titleSmall),
    );
  }

  Widget _campo({
    required BuildContext context,
    required String rotulo,
    required TextEditingController controller,
    TextInputType teclado = TextInputType.text,
    String? Function(String?)? validador,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _rotulo(context, rotulo),
        TextFormField(
          controller: controller,
          keyboardType: teclado,
          textInputAction: TextInputAction.next,
          decoration: _decoracao(),
          validator:
              validador ??
              (v) =>
                  (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null,
        ),
      ],
    );
  }

  Widget _opcaoNivel(
    String texto,
    NivelAcesso valor,
    VoidCallback aoSelecionar,
  ) {
    return InkWell(
      onTap: aoSelecionar,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Radio<NivelAcesso>(
              value: valor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 4),
          Text(texto),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: esquema.surfaceContainerLow,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: esquema.surface,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const ReservaIfLogo(width: 122, height: 122),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: esquema.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _chaveDoFormulario,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _campo(
                              context: context,
                              rotulo: 'Matrícula/SIAPE',
                              controller: _matriculaController,
                              validador: Validator.validarEntradaDeLogin,
                            ),
                            const SizedBox(height: 20),
                            _campo(
                              context: context,
                              rotulo: 'Email',
                              controller: _emailController,
                              teclado: TextInputType.emailAddress,
                              validador: Validator.validarEmail,
                            ),
                            const SizedBox(height: 20),
                            _campo(
                              context: context,
                              rotulo: 'Telefone',
                              controller: _telefoneController,
                              teclado: TextInputType.phone,
                              validador: Validator.validarTelefone,
                            ),
                            const SizedBox(height: 20),
                            FormField<NivelAcesso>(
                              validator: (value) =>
                                  Validator.selecaoObrigatoria(value),
                              builder: (campo) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _rotulo(context, 'Nível de Acesso'),
                                  RadioGroup<NivelAcesso>(
                                    groupValue: campo.value,
                                    onChanged: (value) {
                                      if (value != null) campo.didChange(value);
                                    },
                                    child: Wrap(
                                      spacing: 12,
                                      runSpacing: 8,
                                      children: [
                                        _opcaoNivel(
                                          'Aluno',
                                          NivelAcesso.aluno,
                                          () => campo.didChange(
                                            NivelAcesso.aluno,
                                          ),
                                        ),
                                        _opcaoNivel(
                                          'Professor',
                                          NivelAcesso.professor,
                                          () => campo.didChange(
                                            NivelAcesso.professor,
                                          ),
                                        ),
                                        _opcaoNivel(
                                          'Coordenador',
                                          NivelAcesso.coordenador,
                                          () => campo.didChange(
                                            NivelAcesso.coordenador,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (campo.hasError)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        campo.errorText!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: esquema.error),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            _rotulo(context, 'Departamento'),
                            DropdownButtonFormField<String>(
                              initialValue: _departamento,
                              isExpanded: true,
                              validator: Validator.selecaoObrigatoria,
                              decoration: _decoracao(hint: 'Selecionar'),
                              items: _departamentos
                                  .map(
                                    (departamento) => DropdownMenuItem(
                                      value: departamento,
                                      child: Text(departamento),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() => _departamento = value);
                              },
                            ),
                            const SizedBox(height: 32),
                            BotaoPadrao(
                              texto: 'Cadastrar',
                              aoPressionar: _cadastrar,
                              corDeFundo: esquema.primary,
                              corDoConteudo: esquema.onPrimary,
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
    );
  }

}
