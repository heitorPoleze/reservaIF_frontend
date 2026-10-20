import 'package:flutter_test/flutter_test.dart';
import 'package:reserva_if/model/usuario/matricula.dart';
import 'package:reserva_if/model/usuario/siape.dart';

void main() {
  group('Siape', () {
    test('aceita 6 ou 7 dígitos', () {
      expect(Siape.isValid('123456'), isTrue);
      expect(Siape.isValid('1234567'), isTrue);
      expect(Siape.isValid(' 1234567 '), isTrue);
    });

    test('rejeita tamanho fora da faixa, letra e espaço interno', () {
      expect(Siape.isValid('12345'), isFalse);
      expect(Siape.isValid('12345678'), isFalse);
      expect(Siape.isValid('12345a7'), isFalse);
      expect(Siape.isValid('123 4567'), isFalse);
      expect(Siape.isValid(''), isFalse);
    });

    test('criar remove espaços nas pontas e lança em valor inválido', () {
      expect(Siape.criar(' 1234567 ').valor, '1234567');
      expect(Siape.criar('123456').formatado, '123456');
      expect(() => Siape.criar('abc'), throwsArgumentError);
    });
  });

  group('Matricula', () {
    test('aceita ano, semestre, 2 a 6 letras e 3 a 6 dígitos', () {
      expect(Matricula.isValid('20241tsi0063'), isTrue);
      expect(Matricula.isValid('20262SI001'), isTrue);
      expect(Matricula.isValid('20241ABCDEF123456'), isTrue);
    });

    test('rejeita semestre, sigla ou sequencial fora do formato', () {
      expect(Matricula.isValid('20243tsi0063'), isFalse);
      expect(Matricula.isValid('20241t0063'), isFalse);
      expect(Matricula.isValid('20241abcdefg0063'), isFalse);
      expect(Matricula.isValid('20241tsi'), isFalse);
      expect(Matricula.isValid('20241tsi12'), isFalse);
      expect(Matricula.isValid('20241tsi1234567'), isFalse);
      expect(Matricula.isValid('1234567'), isFalse);
      expect(Matricula.isValid(''), isFalse);
    });

    test('criar normaliza para minúsculas e expõe as partes', () {
      final matricula = Matricula.criar(' 20241TSI0063 ');

      expect(matricula.valor, '20241tsi0063');
      expect(matricula.formatado, '20241tsi0063');
      expect(matricula.ano, 2024);
      expect(matricula.semestre, 1);
      expect(matricula.curso, 'tsi');
      expect(matricula.sequencial, '0063');
    });

    test('criar lança em valor inválido', () {
      expect(() => Matricula.criar('1234567'), throwsArgumentError);
    });
  });
}
