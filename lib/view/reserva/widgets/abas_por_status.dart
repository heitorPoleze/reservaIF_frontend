import 'package:flutter/material.dart';
import 'package:reserva_if/model/reserva/status_reserva.dart';

class AbasPorStatus extends StatefulWidget {
  final int Function(StatusReserva) contagemDe;
  final Widget Function(StatusReserva) construirColuna;

  const AbasPorStatus({
    super.key,
    required this.contagemDe,
    required this.construirColuna,
  });

  @override
  State<AbasPorStatus> createState() => _AbasPorStatusState();
}

class _AbasPorStatusState extends State<AbasPorStatus>
    with SingleTickerProviderStateMixin {
  static const _status = StatusReserva.values;
  static const _velocidadeMinimaDoDeslize = 300.0;

  late final TabController _abas = TabController(
    length: _status.length,
    vsync: this,
  )..addListener(_aoTrocarAba);

  @override
  void dispose() {
    _abas.dispose();
    super.dispose();
  }

  void _aoTrocarAba() => setState(() {});

  void _aoDeslizar(DragEndDetails detalhes) {
    final velocidade = detalhes.primaryVelocity ?? 0;
    if (velocidade.abs() < _velocidadeMinimaDoDeslize) return;

    final destino = (_abas.index + (velocidade < 0 ? 1 : -1)).clamp(
      0,
      _status.length - 1,
    );
    if (destino != _abas.index) _abas.animateTo(destino);
  }

  @override
  Widget build(BuildContext context) {
    final statusAtual = _status[_abas.index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TabBar(
          controller: _abas,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            for (final status in _status)
              Tab(text: '${status.rotulo} (${widget.contagemDe(status)})'),
          ],
        ),
        const SizedBox(height: 16),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragEnd: _aoDeslizar,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            layoutBuilder: (atual, anteriores) => Stack(
              alignment: Alignment.topCenter,
              children: [...anteriores, ?atual],
            ),
            child: KeyedSubtree(
              key: ValueKey(statusAtual),
              child: widget.construirColuna(statusAtual),
            ),
          ),
        ),
      ],
    );
  }
}
