import 'package:flutter/material.dart';
import 'package:reserva_if/utils/datas.dart';
import 'package:reserva_if/utils/formatacao.dart';
import 'package:reserva_if/view/theme/app_cores.dart';
import 'package:reserva_if/view/theme/app_estilos.dart';
import 'package:reserva_if/view/widgets/seletor_mes_ano.dart';
import 'package:table_calendar/table_calendar.dart';

const _anosDeMargem = 5;

const _raioDoDia = 10.0;

class CalendarioMensal extends StatefulWidget {
  final Set<DateTime> diasMarcados;
  final DateTime diaSelecionado;
  final ValueChanged<DateTime> aoSelecionarDia;
  final String rotuloDaLegenda;
  final bool carregando;

  const CalendarioMensal({
    super.key,
    required this.diasMarcados,
    required this.diaSelecionado,
    required this.aoSelecionarDia,
    this.rotuloDaLegenda = 'Dias com reservas',
    this.carregando = false,
  });

  @override
  State<CalendarioMensal> createState() => _CalendarioMensalState();
}

class _CalendarioMensalState extends State<CalendarioMensal> {
  late DateTime _diaFocado = widget.diaSelecionado;

  DateTime get _primeiroDia => DateTime(hoje().year - _anosDeMargem, 1, 1);

  DateTime get _ultimoDia => DateTime(hoje().year + _anosDeMargem, 12, 31);

  void _focar(DateTime dia) {
    final limitado = dia.isBefore(_primeiroDia)
        ? _primeiroDia
        : (dia.isAfter(_ultimoDia) ? _ultimoDia : dia);

    setState(() => _diaFocado = limitado);
  }

  void _mudarMes(int deslocamento) =>
      _focar(DateTime(_diaFocado.year, _diaFocado.month + deslocamento));

  void _irParaHoje() {
    _focar(hoje());
    widget.aoSelecionarDia(hoje());
  }

  Future<void> _abrirSeletorDeMes() async {
    final escolhido = await selecionarMesAno(
      context: context,
      inicial: _diaFocado,
      minimo: _primeiroDia,
      maximo: _ultimoDia,
    );

    if (escolhido == null || !mounted) return;

    _focar(escolhido);
  }

  void _aoSelecionarDia(DateTime selecionado, DateTime focado) {
    _focar(focado);
    widget.aoSelecionarDia(apenasData(selecionado));
  }

  List<DateTime> _marcadoresDo(DateTime dia) =>
      widget.diasMarcados.contains(apenasData(dia)) ? [dia] : const [];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: AppEstilos.cartao(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CabecalhoDoMes(
              mes: _diaFocado,
              carregando: widget.carregando,
              aoTocarNoMes: _abrirSeletorDeMes,
              aoIrParaHoje: _irParaHoje,
              aoVoltar: () => _mudarMes(-1),
              aoAvancar: () => _mudarMes(1),
            ),
            const SizedBox(height: 8),
            _construirGrade(context),
            const SizedBox(height: 12),
            _LegendaDeMarcador(rotulo: widget.rotuloDaLegenda),
          ],
        ),
      ),
    );
  }

  Widget _construirGrade(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final estiloDoDia = textos.bodyLarge!.copyWith(
      color: AppCores.textoPrimario,
    );
    const formaDoDia = BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(_raioDoDia)),
    );

    return TableCalendar<DateTime>(
      locale: 'pt_BR',
      focusedDay: _diaFocado,
      firstDay: _primeiroDia,
      lastDay: _ultimoDia,
      headerVisible: false,
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {CalendarFormat.month: ''},
      availableGestures: AvailableGestures.horizontalSwipe,
      startingDayOfWeek: StartingDayOfWeek.monday,
      rowHeight: 46,
      daysOfWeekHeight: 32,
      eventLoader: _marcadoresDo,
      selectedDayPredicate: (dia) => isSameDay(widget.diaSelecionado, dia),
      onDaySelected: _aoSelecionarDia,
      onPageChanged: _focar,
      calendarBuilders: CalendarBuilders<DateTime>(
        dowBuilder: (context, dia) => Center(
          child: Text(
            formatarDiaDaSemanaAbreviado(dia),
            style: textos.labelSmall?.copyWith(
              color: AppCores.textoTerciario,
              letterSpacing: 0.4,
            ),
          ),
        ),
        markerBuilder: (context, dia, marcadores) => marcadores.isEmpty
            ? null
            : _MarcadorDoDia(
                sobreSelecionado: isSameDay(widget.diaSelecionado, dia),
              ),
      ),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: true,
        cellMargin: const EdgeInsets.all(5),
        defaultDecoration: formaDoDia,
        weekendDecoration: formaDoDia,
        outsideDecoration: formaDoDia,
        disabledDecoration: formaDoDia,
        holidayDecoration: formaDoDia,
        defaultTextStyle: estiloDoDia,
        weekendTextStyle: estiloDoDia,
        outsideTextStyle: estiloDoDia.copyWith(color: AppCores.textoInativo),
        todayDecoration: formaDoDia.copyWith(
          border: Border.all(color: AppCores.acao, width: 1.5),
        ),
        todayTextStyle: estiloDoDia.copyWith(
          color: AppCores.acao,
          fontWeight: FontWeight.w700,
        ),
        selectedDecoration: formaDoDia.copyWith(color: AppCores.acao),
        selectedTextStyle: estiloDoDia.copyWith(
          color: AppCores.sobreAcao,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CabecalhoDoMes extends StatelessWidget {
  final DateTime mes;
  final bool carregando;
  final VoidCallback aoTocarNoMes;
  final VoidCallback aoIrParaHoje;
  final VoidCallback aoVoltar;
  final VoidCallback aoAvancar;

  const _CabecalhoDoMes({
    required this.mes,
    required this.carregando,
    required this.aoTocarNoMes,
    required this.aoIrParaHoje,
    required this.aoVoltar,
    required this.aoAvancar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppEstilos.raioCampo),
              onTap: aoTocarNoMes,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        formatarMesAnoExtenso(mes),
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const Icon(Icons.expand_more, size: 20),
                    if (carregando) ...[
                      const SizedBox(width: 8),
                      const SizedBox.square(
                        dimension: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        _BotaoHoje(aoTocar: aoIrParaHoje),
        const SizedBox(width: 4),
        IconButton(
          tooltip: 'Mês anterior',
          visualDensity: VisualDensity.compact,
          onPressed: aoVoltar,
          icon: const Icon(Icons.chevron_left, color: AppCores.textoPrimario),
        ),
        IconButton(
          tooltip: 'Próximo mês',
          visualDensity: VisualDensity.compact,
          onPressed: aoAvancar,
          icon: const Icon(Icons.chevron_right, color: AppCores.textoPrimario),
        ),
      ],
    );
  }
}

class _BotaoHoje extends StatelessWidget {
  final VoidCallback aoTocar;

  const _BotaoHoje({required this.aoTocar});

  @override
  Widget build(BuildContext context) {
    final raio = BorderRadius.circular(999);

    return Material(
      color: AppCores.fundoIcone,
      borderRadius: raio,
      child: InkWell(
        borderRadius: raio,
        onTap: aoTocar,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          child: Text(
            'Hoje',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: AppCores.acao),
          ),
        ),
      ),
    );
  }
}

class _MarcadorDoDia extends StatelessWidget {
  final bool sobreSelecionado;

  const _MarcadorDoDia({required this.sobreSelecionado});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 9,
      child: _Ponto(cor: sobreSelecionado ? AppCores.sobreAcao : AppCores.acao),
    );
  }
}

class _LegendaDeMarcador extends StatelessWidget {
  final String rotulo;

  const _LegendaDeMarcador({required this.rotulo});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const _Ponto(cor: AppCores.acao),
        const SizedBox(width: 6),
        Text(
          rotulo,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppCores.textoTerciario),
        ),
      ],
    );
  }
}

class _Ponto extends StatelessWidget {
  final Color cor;

  const _Ponto({required this.cor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
    );
  }
}
