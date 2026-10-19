import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reserva_if/view/theme/app_cores.dart';
import 'package:reserva_if/view/widgets/botao_padrao.dart';
import 'package:reserva_if/viewmodel/status_de_conexao.dart';

class GuardaDeConexao extends StatelessWidget {
  final Widget filho;

  const GuardaDeConexao({super.key, required this.filho});

  @override
  Widget build(BuildContext context) {
    final semConexao = context.select<StatusDeConexao, bool>(
      (status) => status.semConexao,
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        filho,
        if (semConexao) const _TelaSemConexao(),
      ],
    );
  }
}

class _TelaSemConexao extends StatelessWidget {
  const _TelaSemConexao();

  @override
  Widget build(BuildContext context) {
    final status = context.watch<StatusDeConexao>();

    return Material(
      color: AppCores.fundo,
      child: Stack(
        children: [
          const ModalBarrier(dismissible: false, color: Colors.transparent),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.wifi_off_rounded,
                    size: 72,
                    color: AppCores.textoTerciario,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Sem conexão com o servidor',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'O aplicativo não conseguiu falar com o servidor. Confira '
                    'a sua internet e tente de novo.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: AppCores.textoSecundario),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: 260,
                    child: BotaoPadrao(
                      texto: 'Tentar novamente',
                      carregando: status.verificando,
                      aoPressionar: status.tentarNovamente,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
