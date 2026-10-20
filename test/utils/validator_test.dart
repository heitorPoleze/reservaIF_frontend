import 'package:flutter_test/flutter_test.dart';
import 'package:reserva_if/model/usuario/credencial/tipo_entrada.dart';
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
    test('aceita vazio porque o e-mail é opcional', () {
      expect(Validator.validarEmail(null), isNull);
      expect(Validator.validarEmail('   '), isNull);
    });

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

  group('validarTelefone', () {
    test('aceita vazio e, quando informado, exige DDD', () {
      expect(Validator.validarTelefone(null), isNull);
      expect(Validator.validarTelefone('   '), isNull);
      expect(Validator.validarTelefone('(27) 99999-0000'), isNull);
      expect(Validator.validarTelefone('2733330000'), isNull);
      expect(Validator.validarTelefone('abc27999990000'), isNotNull);
      expect(Validator.validarTelefone('99999-0000'), isNotNull);
    });
  });

  group('validarSiape', () {
    test('aceita 6 ou 7 dígitos e rejeita o resto', () {
      expect(Validator.validarSiape('123456'), isNull);
      expect(Validator.validarSiape('1234567'), isNull);
      expect(Validator.validarSiape(''), 'O SIAPE é obrigatório');
      expect(Validator.validarSiape('12345'), 'Informe um SIAPE válido');
      expect(Validator.validarSiape('20241tsi0063'), 'Informe um SIAPE válido');
    });
  });

  group('validarMatricula', () {
    test('aceita o formato ano+semestre+curso+sequencial', () {
      expect(Validator.validarMatricula('20241tsi0063'), isNull);
      expect(Validator.validarMatricula('20241TSI0063'), isNull);
      expect(Validator.validarMatricula(null), 'A matrícula é obrigatória');
      expect(
        Validator.validarMatricula('1234567'),
        'Informe uma matrícula válida',
      );
    });
  });

  group('validarEntradaDeLogin', () {
    test('aceita matrícula ou SIAPE', () {
      expect(Validator.validarEntradaDeLogin('1234567'), isNull);
      expect(Validator.validarEntradaDeLogin(' 20241tsi0063 '), isNull);
    });

    test('rejeita em branco e formato desconhecido', () {
      expect(
        Validator.validarEntradaDeLogin('  '),
        'Informe sua matrícula ou SIAPE',
      );
      expect(
        Validator.validarEntradaDeLogin('a@ifes.edu.br'),
        'Informe uma matrícula ou um SIAPE válidos',
      );
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
  group('validarEmailObrigatorio', () {
    test('recusa vazio e e-mail malformado', () {
      expect(Validator.validarEmailObrigatorio(null), isNotNull);
      expect(Validator.validarEmailObrigatorio('  '), isNotNull);
      expect(Validator.validarEmailObrigatorio('ana@'), isNotNull);
      expect(Validator.validarEmailObrigatorio('ana@ifes.edu.br'), isNull);
    });
  });

  group('validarSenha no limite do bcrypt', () {
    test('aceita 72 bytes e recusa 73', () {
      expect(Validator.validarSenha('a' * 72), isNull);
      expect(Validator.validarSenha('a' * 73), isNotNull);
    });

    test('conta bytes, não caracteres', () {
      expect(Validator.validarSenha('ç' * 37), isNotNull);
    });
  });

  group('validarIdentificador', () {
    test('escolhe a regra pelo tipo de entrada', () {
      expect(
        Validator.validarIdentificador(TipoEntrada.siape)('1234567'),
        isNull,
      );
      expect(
        Validator.validarIdentificador(TipoEntrada.siape)('20241tsi0063'),
        isNotNull,
      );
      expect(
        Validator.validarIdentificador(TipoEntrada.matricula)('20241tsi0063'),
        isNull,
      );
    });
  });
}
