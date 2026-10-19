import 'package:flutter/material.dart';
import 'package:reserva_if/view/theme/app_cores.dart';

class BotaoPadrao extends StatelessWidget {
  final String texto;
  final VoidCallback? aoPressionar;
  final Color? corDeFundo;
  final Color? corDoConteudo;
  final bool contornado;
  final bool carregando;
  final IconData? icone;

  const BotaoPadrao({
    super.key,
    required this.texto,
    required this.aoPressionar,
    this.corDeFundo,
    this.corDoConteudo,
    this.contornado = false,
    this.carregando = false,
    this.icone,
  });

  @override
  Widget build(BuildContext context) {
    final acao = carregando ? null : aoPressionar;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: contornado
          ? OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: corDeFundo,
                foregroundColor: corDoConteudo,
                side: BorderSide(
                  color: corDoConteudo ?? AppCores.acao,
                  width: 1.5,
                ),
              ),
              onPressed: acao,
              child: _Conteudo(texto: texto, icone: icone, carregando: carregando),
            )
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: corDeFundo,
                foregroundColor: corDoConteudo,
              ),
              onPressed: acao,
              child: _Conteudo(texto: texto, icone: icone, carregando: carregando),
            ),
    );
  }
}

class _Conteudo extends StatelessWidget {
  final String texto;
  final IconData? icone;
  final bool carregando;

  const _Conteudo({
    required this.texto,
    required this.icone,
    required this.carregando,
  });

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const SizedBox.square(
        dimension: 22,
        child: CircularProgressIndicator(strokeWidth: 2.5),
      );
    }

    if (icone == null) return Text(texto);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, size: 20),
        const SizedBox(width: 8),
        Text(texto),
      ],
    );
  }
}

class BotaoDeTexto extends StatelessWidget {
  final String texto;
  final VoidCallback? aoPressionar;
  final Color? cor;

  const BotaoDeTexto({
    super.key,
    required this.texto,
    required this.aoPressionar,
    this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: cor == null ? null : TextButton.styleFrom(foregroundColor: cor),
      onPressed: aoPressionar,
      child: Text(texto),
    );
  }
}
