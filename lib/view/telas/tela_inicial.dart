import 'package:flutter/material.dart';
import 'package:reserva_if/view/theme/app_cores.dart';
import 'package:reserva_if/view/widgets/botao_padrao.dart';
import 'package:reserva_if/view/widgets/reserva_if_logo.dart';
import 'package:reserva_if/view/widgets/scaffold_de_autenticacao.dart';

class TelaInicialDeslogada extends StatelessWidget {
  final VoidCallback aoEntrar;
  final VoidCallback? aoCadastrar;

  const TelaInicialDeslogada({
    super.key,
    required this.aoEntrar,
    this.aoCadastrar,
  });

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;

    return ScaffoldDeAutenticacao(
      corpo: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
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
                const SizedBox(height: 80),
                BotaoPadrao(texto: 'Entrar', aoPressionar: aoEntrar),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: AppCores.sobreAcento,
                    ),
                    onPressed: aoCadastrar,
                    child: const Text('Cadastrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
