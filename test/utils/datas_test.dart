import 'package:flutter_test/flutter_test.dart';
import 'package:reserva_if/utils/datas.dart';

void main() {
  test('dataParaJson grava meia-noite UTC do dia local', () {
    final dia = DateTime(2026, 10, 19, 23, 30);

    expect(dataParaJson(dia), '2026-10-19T00:00:00.000Z');
  });

  test('instanteParaJson converte o instante real para UTC', () {
    final instante = DateTime.utc(2026, 10, 19, 13, 0);

    expect(instanteParaJson(instante.toLocal()), '2026-10-19T13:00:00.000Z');
  });

  test('lerDataDoJson aceita ISO, epoch e DateTime', () {
    expect(lerDataDoJson('2026-10-19T13:00:00.000Z'), isA<DateTime>());
    expect(lerDataDoJson(1760000000000)!.isUtc, isTrue);
    expect(lerDataDoJson(DateTime(2026)), DateTime(2026));
    expect(lerDataDoJson(null), isNull);
  });

  test('lerInstanteDoJson devolve no fuso local', () {
    final lido = lerInstanteDoJson('2026-10-19T13:00:00.000Z');

    expect(lido!.isUtc, isFalse);
    expect(lido.toUtc(), DateTime.utc(2026, 10, 19, 13));
  });

  test('diasEntre faz conta de calendário', () {
    expect(diasEntre(DateTime(2026, 10, 19), DateTime(2026, 10, 21)), 2);
    expect(diasEntre(DateTime(2026, 10, 21), DateTime(2026, 10, 19)), -2);
  });

  test('menorData e maiorData tratam null como em aberto', () {
    final a = DateTime(2026, 1, 1);
    final b = DateTime(2026, 2, 1);

    expect(menorData(a, null), a);
    expect(menorData(a, b), a);
    expect(maiorData(a, null), isNull);
    expect(maiorData(a, b), b);
  });

  test('combinarDataEHora preserva o dia e aplica a hora', () {
    final resultado = combinarDataEHora(DateTime(2026, 10, 19, 5), 14, 30);

    expect(resultado, DateTime(2026, 10, 19, 14, 30));
  });
}
