import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:reserva_if/model/usuario/credencial/credencial.dart';
import 'package:reserva_if/model/usuario/perfil.dart';
import 'package:reserva_if/services/http/exceptions/api_exceptions.dart';
import 'package:reserva_if/services/services_autenticacao.dart';
import 'package:reserva_if/services/services_base.dart';

import 'mock_http.dart';

final _credencial = Credencial.criar(entrada: ' 1234567 ', senha: 'Segredo@1');

const _autenticada = {
  'uuid': '64b7f0c2a1b2c3d4e5f60222',
  'nivelAcesso': 1,
  'token': 'eyJ.token.assinado',
};

void main() {
  final service = ServicesAutenticacao();

  setUp(() {
    BaseService.tokenDeSessao = null;
    BaseService.aoSessaoExpirar = null;
  });

  test(
    'envia AutenticarCredencialInput para POST /autenticacao/login',
    () async {
      http.Request? enviada;

      final sessao = await comRespostaFixa(
        () => service.entrar(_credencial),
        respostaJson(_autenticada, 200),
        capturar: (requisicao) => enviada = requisicao,
      );

      expect(enviada!.method, 'POST');
      expect(enviada!.url.path, endsWith('/autenticacao/login'));
      expect(enviada!.headers.containsKey('Authorization'), isFalse);
      expect(jsonDecode(enviada!.body), {
        'tipoEntrada': 0,
        'entrada': '1234567',
        'senha': 'Segredo@1',
      });
      expect(sessao.uuid, '64b7f0c2a1b2c3d4e5f60222');
      expect(sessao.perfil, Perfil.professor);
      expect(sessao.token, 'eyJ.token.assinado');
    },
  );

  test(
    '401 vira mensagem de credencial inválida sem acionar expiração',
    () async {
      var expirou = false;
      BaseService.aoSessaoExpirar = () => expirou = true;
      BaseService.tokenDeSessao = 'token-antigo';

      final erro = await erroDe(
        () => comRespostaFixa(
          () => service.entrar(_credencial),
          respostaJson({
            'erro': 'NAO_AUTENTICADO',
            'mensagem': 'Credenciais invalidas.',
          }, 401),
        ),
      );

      expect(erro.mensagem, 'Matrícula/SIAPE ou senha inválidos.');
      expect(erro, isNot(isA<SessaoExpiradaException>()));
      expect(expirou, isFalse);
    },
  );

  test('400 repassa a mensagem do ErroPadrao', () async {
    final erro = await erroDe(
      () => comRespostaFixa(
        () => service.entrar(_credencial),
        respostaJson({
          'erro': 'VALIDACAO',
          'mensagem': 'Tipo de entrada invalido.',
        }, 400),
      ),
    );

    expect(erro.mensagem, contains('Tipo de entrada invalido.'));
    expect(erro.mensagem, isNot(contains('VALIDACAO')));
  });

  test('resposta sem token é defeito de contrato, não falha de rede', () async {
    final erro = await erroDe(
      () => comRespostaFixa(
        () => service.entrar(_credencial),
        respostaJson({'uuid': 'x', 'nivelAcesso': 0}, 200),
      ),
    );

    expect(erro.mensagem, contains('Não foi possível entrar'));
    expect(erro, isNot(isA<SemConexaoException>()));
  });
}
