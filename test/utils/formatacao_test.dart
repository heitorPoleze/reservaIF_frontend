import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:reserva_if/utils/formatacao.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  test('formatarDiaDaSemana devolve só o dia, capitalizado', () {
    expect(formatarDiaDaSemana(DateTime(2026, 10, 19)), 'Segunda-feira');
    expect(formatarDiaDaSemana(DateTime(2026, 10, 24)), 'Sábado');
  });

  test('formatarDataComDiaDaSemana mantém a data', () {
    expect(
      formatarDataComDiaDaSemana(DateTime(2026, 10, 19)),
      'Segunda-feira, 19/10/2026',
    );
  });

  test('formatarFaixaDeHoras separa com travessão curto', () {
    expect(
      formatarFaixaDeHoras(
        DateTime(2026, 10, 19, 14),
        DateTime(2026, 10, 19, 14, 50),
      ),
      '14:00 – 14:50',
    );
  });

  test('formatarDiaDaSemanaEDiaDoMes omite o ano', () {
    expect(
      formatarDiaDaSemanaEDiaDoMes(DateTime(2026, 10, 19)),
      'Segunda-feira, 19 de outubro',
    );
  });

  test('formatarDiaDaSemanaAbreviado é a sigla em maiúsculas sem ponto', () {
    expect(formatarDiaDaSemanaAbreviado(DateTime(2026, 10, 19)), 'SEG');
    expect(formatarDiaDaSemanaAbreviado(DateTime(2026, 10, 24)), 'SÁB');
  });
}
