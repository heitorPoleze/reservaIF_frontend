import 'package:flutter/material.dart';
import 'package:reserva_if/view/theme/app_cores.dart';
import 'package:reserva_if/view/theme/app_estilos.dart';

class CaixaAviso extends StatelessWidget {
  final String mensagem;
  final IconData icone;
  final Color cor;
  final Widget? acao;

  const CaixaAviso({
    super.key,
    required this.mensagem,
    this.icone = Icons.error_outline,
    this.cor = AppCores.erro,
    this.acao,
  });

  const CaixaAviso.atencao({
    super.key,
    required this.mensagem,
    this.acao,
  })  : icone = Icons.warning_amber_rounded,
        cor = AppCores.aviso;

  const CaixaAviso.informacao({
    super.key,
    required this.mensagem,
    this.acao,
  })  : icone = Icons.info_outline,
        cor = AppCores.link;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppEstilos.raioCampo),
        border: Border.all(color: cor.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icone, color: cor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  mensagem,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: cor),
                ),
              ),
            ],
          ),
          if (acao != null) ...[const SizedBox(height: 8), acao!],
        ],
      ),
    );
  }
}
