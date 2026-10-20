import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:reserva_if/services/http/exceptions/api_exceptions.dart';
import 'package:reserva_if/services/services_base.dart';
import 'package:reserva_if/services/services_cancelamento.dart';

import 'mock_http.dart';

void main() {
  final service = ServicesCancelamento();

  setUp(() {
    BaseService.tokenDeSessao = null;
    BaseService.aoSessaoExpirar = null;
  });

  group('solicitarHorario', () {
    test('envia o POST com a justificativa e lê a solicitação', () async {
      http.Request? enviada;

      final resultado = await comRespostaFixa(
        () => service.solicitarHorario('r1', 'Prova prática.'),
        respostaJson({
          'reserva': null,
          'solicitacaoEnviada': true,
          'solicitacao': null,
          'mensagem': 'Solicitação enviada à coordenação.',
        }, 202),
        capturar: (requisicao) => enviada = requisicao,
      );

      expect(enviada!.method, 'POST');
      expect(enviada!.url.path, endsWith('/cancelamentos/r1/solicitar'));
      expect(jsonDecode(enviada!.body), {'justificativa': 'Prova prática.'});
      expect(resultado.solicitacaoEnviada, isTrue);
      expect(resultado.mensagem, 'Solicitação enviada à coordenação.');
    });

    test('403 repassa a mensagem do backend', () async {
      final erro = await erroDe(
        () => comRespostaFixa(
          () => service.solicitarHorario('r1', 'Motivo'),
          respostaJson({
            'erro': 'PERMISSAO_NEGADA',
            'mensagem': 'A reserva alvo não pertence a um aluno.',
          }, 403),
        ),
      );

      expect(erro, isA<ApiException>());
      expect(erro.mensagem, contains('A reserva alvo não pertence a um aluno.'));
    });

    test('422 de horário iniciado repassa a mensagem do backend', () async {
      final erro = await erroDe(
        () => comRespostaFixa(
          () => service.solicitarHorario('r1', 'Motivo'),
          respostaJson({
            'erro': 'REGRA_DE_NEGOCIO',
            'mensagem': 'O horário da reserva já iniciou.',
          }, 422),
        ),
      );

      expect(erro.mensagem, contains('O horário da reserva já iniciou.'));
    });
  });
}
