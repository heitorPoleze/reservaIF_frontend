import 'package:flutter/material.dart';
import 'package:reserva_if/utils/datas.dart';
import 'package:reserva_if/utils/formatacao.dart';
import 'package:reserva_if/view/theme/app_cores.dart';
import 'package:reserva_if/view/theme/app_estilos.dart';
import 'package:reserva_if/view/widgets/dialogos.dart';

Future<DateTime?> selecionarMesAno({
  required BuildContext context,
  required DateTime inicial,
  required DateTime minimo,
  required DateTime maximo,
  String titulo = 'Escolher mês',
}) {
  final primeiro = inicioDoMes(minimo);
  final ultimoInformado = inicioDoMes(maximo);
  final ultimo = ultimoInformado.isBefore(primeiro)
      ? primeiro
      : ultimoInformado;

  return showDialog<DateTime>(
    context: context,
    builder: (context) => _DialogoMesAno(
      inicial: inicioDoMes(inicial),
      primeiro: primeiro,
      ultimo: ultimo,
      titulo: titulo,
    ),
  );
}

class _DialogoMesAno extends StatefulWidget {
  final DateTime inicial;
  final DateTime primeiro;
  final DateTime ultimo;
  final String titulo;

  const _DialogoMesAno({
    required this.inicial,
    required this.primeiro,
    required this.ultimo,
    required this.titulo,
  });

  @override
  State<_DialogoMesAno> createState() => _DialogoMesAnoState();
}

class _DialogoMesAnoState extends State<_DialogoMesAno> {
  late DateTime _escolhido = widget.inicial;

  late int _ano = widget.inicial.year.clamp(
    widget.primeiro.year,
    widget.ultimo.year,
  );

  bool get _podeVoltarAno => _ano > widget.primeiro.year;

  bool get _podeAvancarAno => _ano < widget.ultimo.year;

  bool _disponivel(DateTime mes) =>
      !mes.isBefore(widget.primeiro) && !mes.isAfter(widget.ultimo);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo),
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _construirSeletorDeAno(context),
            const SizedBox(height: 16),
            _construirGradeDeMeses(),
          ],
        ),
      ),
      actions: acoesDeDialogo(
        context: context,
        rotuloConfirmar: 'Escolher',
        aoConfirmar: () => Navigator.pop(context, _escolhido),
      ),
    );
  }

  Widget _construirSeletorDeAno(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          tooltip: 'Ano anterior',
          onPressed: _podeVoltarAno ? () => setState(() => _ano--) : null,
          icon: const Icon(Icons.chevron_left),
        ),
        Text('$_ano', style: Theme.of(context).textTheme.titleMedium),
        IconButton(
          tooltip: 'Próximo ano',
          onPressed: _podeAvancarAno ? () => setState(() => _ano++) : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _construirGradeDeMeses() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      childAspectRatio: 2.1,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        for (var numero = 1; numero <= 12; numero++)
          _BotaoDeMes(
            mes: DateTime(_ano, numero),
            selecionado: DateTime(_ano, numero) == _escolhido,
            disponivel: _disponivel(DateTime(_ano, numero)),
            aoEscolher: (mes) => setState(() => _escolhido = mes),
          ),
      ],
    );
  }
}

class _BotaoDeMes extends StatelessWidget {
  final DateTime mes;
  final bool selecionado;
  final bool disponivel;
  final ValueChanged<DateTime> aoEscolher;

  const _BotaoDeMes({
    required this.mes,
    required this.selecionado,
    required this.disponivel,
    required this.aoEscolher,
  });

  @override
  Widget build(BuildContext context) {
    final raio = BorderRadius.circular(AppEstilos.raioCampo);

    return Material(
      color: selecionado ? AppCores.acao : AppCores.fundo,
      borderRadius: raio,
      child: InkWell(
        borderRadius: raio,
        onTap: disponivel ? () => aoEscolher(mes) : null,
        child: Center(
          child: Text(
            formatarMesAbreviado(mes),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: _corDoRotulo,
              fontWeight: selecionado ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Color get _corDoRotulo {
    if (selecionado) return AppCores.sobreAcao;
    if (!disponivel) return AppCores.textoInativo;
    return AppCores.textoPrimario;
  }
}
