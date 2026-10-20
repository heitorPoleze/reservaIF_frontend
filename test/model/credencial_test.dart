import 'package:flutter_test/flutter_test.dart';
import 'package:reserva_if/model/usuario/credencial/credencial.dart';
import 'package:reserva_if/model/usuario/credencial/tipo_entrada.dart';

void main() {
  group('criar infere o tipo de entrada', () {
    test('SIAPE pelos dígitos', () {
      final credencial = Credencial.criar(entrada: ' 1234567 ', senha: 's');

      expect(credencial.tipoEntrada, TipoEntrada.siape);
      expect(credencial.entrada, '1234567');
    });

    test('matrícula pelo formato, normalizada em minúsculas', () {
      final credencial = Credencial.criar(entrada: '20241TSI0063', senha: 's');

      expect(credencial.tipoEntrada, TipoEntrada.matricula);
      expect(credencial.entrada, '20241tsi0063');
    });

    test('lança quando não é matrícula nem SIAPE', () {
      expect(
        () => Credencial.criar(entrada: 'a@ifes.edu.br', senha: 's'),
        throwsArgumentError,
      );
      expect(
        () => Credencial.criar(entrada: '', senha: 's'),
        throwsArgumentError,
      );
    });
  });

  test('toJson manda a entrada normalizada e o tipo LOCAL da API', () {
    final credencial = Credencial.criar(
      entrada: '1234567',
      senha: 'segredo123',
    );

    expect(credencial.toJson(), {
      'tipoEntrada': Credencial.tipoEntradaLocal,
      'entrada': '1234567',
      'senha': 'segredo123',
    });
  });

  test('copyWith troca só o informado e reinfere o tipo', () {
    final credencial = Credencial.criar(
      entrada: '1234567',
      senha: 'segredo123',
    );

    final copia = credencial.copyWith(entrada: '20241tsi0063');

    expect(copia.tipoEntrada, TipoEntrada.matricula);
    expect(copia.entrada, '20241tsi0063');
    expect(copia.senha, 'segredo123');
    expect(credencial.copyWith(senha: 'nova').tipoEntrada, TipoEntrada.siape);
  });

  test('tipoEntrada LOCAL é 0, como no Swagger', () {
    expect(Credencial.tipoEntradaLocal, 0);
    expect(
      Credencial.criar(entrada: '20241TSI0063', senha: 's').toJson()['entrada'],
      '20241tsi0063',
    );
  });
}
