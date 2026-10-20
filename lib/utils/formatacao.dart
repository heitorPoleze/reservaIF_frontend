import 'package:intl/intl.dart';

final _dataCurta = DateFormat('dd/MM/yyyy');

final _hora = DateFormat('HH:mm');

final _dataEHora = DateFormat('dd/MM/yyyy HH:mm');

final _dataExtensa = DateFormat("d 'de' MMMM 'de' y", 'pt_BR');

final _dataComDiaDaSemana = DateFormat('EEEE, dd/MM/yyyy', 'pt_BR');

final _diaDaSemana = DateFormat.EEEE('pt_BR');

final _mesAno = DateFormat.yMMMM('pt_BR');

final _mesAbreviado = DateFormat.MMM('pt_BR');

String formatarDataBr(DateTime data) => _dataCurta.format(data);

String formatarHora(DateTime instante) => _hora.format(instante);

String formatarDataEHora(DateTime instante) => _dataEHora.format(instante);

String formatarIntervaloDeHoras(DateTime inicio, DateTime fim) =>
    '${formatarHora(inicio)} às ${formatarHora(fim)}';

String formatarDataExtensa(DateTime data) => _dataExtensa.format(data);

String formatarDataComDiaDaSemana(DateTime data) =>
    capitalizar(_dataComDiaDaSemana.format(data));

String formatarDiaDaSemana(DateTime data) =>
    capitalizar(_diaDaSemana.format(data));

String formatarMesAnoExtenso(DateTime data) =>
    capitalizar(_mesAno.format(data));

String formatarMesAbreviado(DateTime data) => _mesAbreviado.format(data);

String capitalizar(String texto) =>
    texto.isEmpty ? texto : texto[0].toUpperCase() + texto.substring(1);

final _inteiroBr = NumberFormat('#,##0', 'pt_BR');

final _decimalBr = NumberFormat('#,##0.##', 'pt_BR');

String formatarInteiro(num valor) => _inteiroBr.format(valor);

String formatarDecimal(num valor) => _decimalBr.format(valor);

String contarItens(int quantidade, String singular, String plural) =>
    '$quantidade ${quantidade == 1 ? singular : plural}';
