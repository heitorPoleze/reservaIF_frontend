import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:reserva_if/model/reserva/status_solicitacao_cancelamento.dart';
import 'package:reserva_if/services/http/exceptions/api_exceptions.dart';
import 'package:reserva_if/services/services_base.dart';
import 'package:reserva_if/services/services_cancelamento.dart';

import 'mock_http.dart';

const _solicitacaoJson = {
  'id': 'sol1',
  'tipo': 'SOLICITACAO_CANCELAMENTO',
  'reservaId': 'r1',
  'solicitadoPorId': 'p1',
  'departamentoId': null,
  'justificativa': 'Prova prática.',
  'finalidade': null,
  'status': 'PENDENTE',
  'motivoRejeicao': null,
  'analisadoPorId': null,
  'analisadoEm': null,
  'novaReservaId': null,
  'criadoEm': '2026-10-20T14:00:00.000Z',
};

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
      expect(
        erro.mensagem,
        contains('A reserva alvo não pertence a um aluno.'),
      );
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

  group('buscarSolicitacoesPendentes', () {
    test('lê a lista de solicitações', () async {
      http.Request? enviada;

      final solicitacoes = await comRespostaFixa(
        service.buscarSolicitacoesPendentes,
        respostaJson([_solicitacaoJson], 200),
        capturar: (requisicao) => enviada = requisicao,
      );

      expect(enviada!.method, 'GET');
      expect(enviada!.url.path, endsWith('/cancelamentos/solicitacoes'));
      expect(solicitacoes.single.idParaDecisao, 'sol1');
      expect(solicitacoes.single.reservaId, 'r1');
      expect(solicitacoes.single.solicitadoPorId, 'p1');
    });

    test('404 com corpo JSON é lista vazia', () async {
      final solicitacoes = await comRespostaFixa(
        service.buscarSolicitacoesPendentes,
        respostaJson({'mensagem': 'Nenhuma solicitação.'}, 404),
      );

      expect(solicitacoes, isEmpty);
    });
  });

  group('decisão do coordenador', () {
    test('aprovar envia o POST sem corpo e lê a solicitação', () async {
      http.Request? enviada;

      final solicitacao = await comRespostaFixa(
        () => service.aprovarSolicitacao('sol1'),
        respostaJson({
          'solicitacao': {..._solicitacaoJson, 'status': 'APROVADA'},
          'mensagem': 'Solicitação aprovada.',
        }, 200),
        capturar: (requisicao) => enviada = requisicao,
      );

      expect(enviada!.method, 'POST');
      expect(
        enviada!.url.path,
        endsWith('/cancelamentos/solicitacoes/sol1/aprovar'),
      );
      expect(enviada!.body, isEmpty);
      expect(solicitacao.status, StatusSolicitacaoCancelamento.aprovada);
    });

    test('rejeitar envia o POST na rota de rejeição', () async {
      http.Request? enviada;

      final solicitacao = await comRespostaFixa(
        () => service.rejeitarSolicitacao('sol1'),
        respostaJson({
          'solicitacao': {..._solicitacaoJson, 'status': 'REJEITADA'},
          'mensagem': 'Solicitação rejeitada.',
        }, 200),
        capturar: (requisicao) => enviada = requisicao,
      );

      expect(enviada!.method, 'POST');
      expect(
        enviada!.url.path,
        endsWith('/cancelamentos/solicitacoes/sol1/rejeitar'),
      );
      expect(solicitacao.status, StatusSolicitacaoCancelamento.rejeitada);
    });

    test('403 repassa a mensagem do backend', () async {
      final erro = await erroDe(
        () => comRespostaFixa(
          () => service.aprovarSolicitacao('sol1'),
          respostaJson({
            'erro': 'PERMISSAO_NEGADA',
            'mensagem': 'Apenas coordenadores podem aprovar solicitações.',
          }, 403),
        ),
      );

      expect(
        erro.mensagem,
        contains('Apenas coordenadores podem aprovar solicitações.'),
      );
    });
  });
}
