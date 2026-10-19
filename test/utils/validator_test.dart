import 'package:flutter_test/flutter_test.dart';
import 'package:reserva_if/utils/validator.dart';

void main() {
  group('obrigatorio', () {
    test('rejeita vazio e só espaços', () {
      expect(Validator.obrigatorio(null), 'Obrigatório');
      expect(Validator.obrigatorio('   '), 'Obrigatório');
      expect(Validator.obrigatorio('x'), isNull);
    });

    test('aceita mensagem própria', () {
      expect(Validator.obrigatorio('', 'Informe a sala'), 'Informe a sala');
    });
  });

  group('validarEmail', () {
    test('aceita e-mail institucional', () {
      expect(Validator.validarEmail('nome.sobrenome@ifes.edu.br'), isNull);
    });

    test('rejeita ponto solto na parte local', () {
      expect(Validator.validarEmail('.nome@ifes.edu.br'), isNotNull);
      expect(Validator.validarEmail('nome.@ifes.edu.br'), isNotNull);
      expect(Validator.validarEmail('nome..x@ifes.edu.br'), isNotNull);
    });

    test('rejeita sem domínio', () {
      expect(Validator.validarEmail('nome@'), isNotNull);
      expect(Validator.validarEmail('nome'), isNotNull);
    });
  });

  group('validarSenha', () {
    test('exige o mínimo de caracteres', () {
      expect(Validator.validarSenha('1234567'), isNotNull);
      expect(Validator.validarSenha('12345678'), isNull);
    });

    test('rejeita emoji', () {
      expect(Validator.validarSenha('senha😀forte'), isNotNull);
    });

    test('confirmação precisa bater', () {
      expect(Validator.validarConfirmacaoSenha('a', 'b'), isNotNull);
      expect(Validator.validarConfirmacaoSenha('a', 'a'), isNull);
    });
  });

  group('validarNome', () {
    test('aplica piso e teto', () {
      expect(Validator.validarNome('ab'), isNotNull);
      expect(Validator.validarNome('abc'), isNull);
      expect(Validator.validarNome('a' * 101), isNotNull);
    });

    test('não restringe caracteres', () {
      expect(Validator.validarNome('Lab. 03 - Redes'), isNull);
    });
  });

  group('inteiroPositivo', () {
    test('rejeita zero, negativo e texto', () {
      expect(Validator.inteiroPositivo('0'), isNotNull);
      expect(Validator.inteiroPositivo('-1'), isNotNull);
      expect(Validator.inteiroPositivo('abc'), isNotNull);
      expect(Validator.inteiroPositivo('40'), isNull);
    });
  });
}
