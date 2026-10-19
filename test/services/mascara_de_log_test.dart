import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:reserva_if/services/http/mascara_de_log.dart';

void main() {
  Map<String, dynamic> mascarar(Map<String, dynamic> corpo) =>
      jsonDecode(MascaraDeLog.aplicar(jsonEncode(corpo))) as Map<String, dynamic>;

  test('senha e token são ocultados por inteiro', () {
    final resultado = mascarar({'senha': 'abc', 'token': 'xyz'});

    expect(resultado['senha'], '<oculto>');
    expect(resultado['token'], '<oculto>');
  });

  test('email e siape mantêm só o tamanho', () {
    final resultado = mascarar({'email': 'a@b.c', 'siape': '1234567'});

    expect(resultado['email'], '<oculto: 5 caracteres>');
    expect(resultado['siape'], '<oculto: 7 caracteres>');
  });

  test('campos comuns passam intactos e null não é ocultado', () {
    final resultado = mascarar({'nome': 'Sala', 'email': null});

    expect(resultado['nome'], 'Sala');
    expect(resultado['email'], isNull);
  });

  test('o value de um erro de validação sensível é ocultado', () {
    final resultado = mascarar({
      'erros': [
        {'path': 'senha', 'value': '123456', 'msg': 'curta'},
        {'path': 'nome', 'value': 'ab', 'msg': 'curto'},
      ]
    });

    final erros = resultado['erros'] as List;

    expect(erros[0]['value'], '<oculto: 6 caracteres>');
    expect(erros[1]['value'], 'ab');
  });

  test('corpo que não é JSON volta como veio', () {
    expect(MascaraDeLog.aplicar('<html>'), '<html>');
  });
}
