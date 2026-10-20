import 'package:flutter/material.dart';
import 'package:reserva_if/view/theme/app_cores.dart';
import 'package:reserva_if/view/theme/app_estilos.dart';

class CartaoEntidade extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final Widget? acao;
  final List<Widget> corpo;
  final VoidCallback? aoTocar;

  const CartaoEntidade({
    super.key,
    required this.icone,
    required this.titulo,
    required this.corpo,
    this.acao,
    this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: AppEstilos.cartao(),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppEstilos.raioCartao),
          onTap: aoTocar,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icone, color: AppCores.acao, size: 28),
                    const SizedBox(width: 12),
                    Expanded(child: Text(titulo, style: textos.titleLarge)),
                    if (acao != null) ...[const SizedBox(width: 8), acao!],
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(),
                ),
                ..._espacados(corpo),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Iterable<Widget> _espacados(List<Widget> itens) sync* {
    for (var indice = 0; indice < itens.length; indice++) {
      if (indice > 0) yield const SizedBox(height: 14);
      yield itens[indice];
    }
  }
}

class LinhaCartao extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String valor;

  const LinhaCartao({
    super.key,
    required this.icone,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icone, color: AppCores.textoSecundario, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: textos.labelMedium?.copyWith(
                  color: AppCores.textoSecundario,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(valor, style: textos.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}
