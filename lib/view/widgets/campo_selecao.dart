import 'package:flutter/material.dart';
import 'package:reserva_if/view/theme/app_cores.dart';
import 'package:reserva_if/view/widgets/campos_formulario.dart';

class CampoSelecao<T> extends StatelessWidget {
  final String rotulo;
  final T? valor;
  final List<T> opcoes;
  final String Function(T) rotuloDe;
  final IconData Function(T)? iconeDe;
  final String Function(T)? grupoDe;
  final ValueChanged<T?> aoMudar;
  final String? dica;
  final String? Function(T?)? validador;
  final bool habilitado;
  final bool opcional;

  const CampoSelecao({
    super.key,
    required this.rotulo,
    required this.valor,
    required this.opcoes,
    required this.rotuloDe,
    required this.aoMudar,
    this.iconeDe,
    this.grupoDe,
    this.dica,
    this.validador,
    this.habilitado = true,
    this.opcional = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        rotuloDeCampo(context, rotulo, opcional: opcional),
        DropdownButtonFormField<T>(
          initialValue: valor,
          isExpanded: true,
          itemHeight: null,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: validador,
          style: estiloDeValorDeCampo(context),
          decoration: InputDecoration(
            hintText: dica,
            prefixIcon: _iconeSelecionado,
          ),
          selectedItemBuilder: (_) => [
            for (final entrada in _entradas)
              entrada.ehGrupo
                  ? const SizedBox.shrink()
                  : Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        rotuloDe(entrada.opcao as T),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
          ],
          items: [
            for (final entrada in _entradas)
              entrada.ehGrupo
                  ? DropdownMenuItem<T>(
                      enabled: false,
                      child: _CabecalhoDeGrupo(texto: entrada.grupo!),
                    )
                  : DropdownMenuItem<T>(
                      value: entrada.opcao,
                      child: _ItemDeSelecao(
                        texto: rotuloDe(entrada.opcao as T),
                        icone: iconeDe?.call(entrada.opcao as T),
                      ),
                    ),
          ],
          onChanged: habilitado ? aoMudar : null,
        ),
      ],
    );
  }

  List<_EntradaDeSelecao<T>> get _entradas {
    final agrupar = grupoDe;
    if (agrupar == null) {
      return [for (final opcao in opcoes) _EntradaDeSelecao.opcao(opcao)];
    }

    final entradas = <_EntradaDeSelecao<T>>[];
    String? grupoAtual;
    for (final opcao in opcoes) {
      final grupo = agrupar(opcao);
      if (grupo != grupoAtual) {
        entradas.add(_EntradaDeSelecao.grupo(grupo));
        grupoAtual = grupo;
      }
      entradas.add(_EntradaDeSelecao.opcao(opcao));
    }
    return entradas;
  }

  Widget? get _iconeSelecionado {
    final selecionado = valor;
    final icone = iconeDe;
    if (selecionado == null || icone == null) return null;
    return Icon(icone(selecionado));
  }
}

class _EntradaDeSelecao<T> {
  const _EntradaDeSelecao.opcao(this.opcao) : grupo = null;

  const _EntradaDeSelecao.grupo(this.grupo) : opcao = null;

  final T? opcao;
  final String? grupo;

  bool get ehGrupo => grupo != null;
}

class _CabecalhoDeGrupo extends StatelessWidget {
  final String texto;

  const _CabecalhoDeGrupo({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        texto,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(color: AppCores.acao),
      ),
    );
  }
}

class _ItemDeSelecao extends StatelessWidget {
  final String texto;
  final IconData? icone;

  const _ItemDeSelecao({required this.texto, this.icone});

  @override
  Widget build(BuildContext context) {
    final rotulo = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(texto, maxLines: 2, overflow: TextOverflow.ellipsis),
    );

    if (icone == null) return rotulo;

    return Row(
      children: [
        Icon(icone, size: 20),
        const SizedBox(width: 12),
        Expanded(child: rotulo),
      ],
    );
  }
}
