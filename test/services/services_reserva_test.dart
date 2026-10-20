import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:reserva_if/model/predio/predio.dart';
import 'package:reserva_if/model/reserva/reserva.dart';
import 'package:reserva_if/model/sala/sala.dart';
import 'package:reserva_if/model/usuario/usuario_resumo.dart';
import 'package:reserva_if/services/http/exceptions/api_exceptions.dart';
import 'package:reserva_if/services/services_base.dart';
import 'package:reserva_if/services/services_reserva.dart';

import 'mock_http.dart';

const _reservaJson = {
  'id': '64b7f0c2a1b2c3d4e5f60718',
  'salaId': '64b7f0c2a1b2c3d4e5f60111',
  'solicitanteId': '64b7f0c2a1b2c3d4e5f60222',
  'responsavelId': '64b7f0c2a1b2c3d4e5f60222',
  'analisadoPorId': null,
  'serieRecorrenciaId': null,
  'tipoRecorrencia': 'UNICA',
  'dataHoraInicio': '2026-10-21T13:00:00.000Z',
  'dataHoraFim': '2026-10-21T13:50:00.000Z',
  'finalidade': 'Monitoria de Algoritmos',
  'observacoes': 'Necessário projetor',
  'status': 'AGENDADO',
  'motivoRejeicao': null,
  'cancelamento': null,
  'criadoEm': '2026-10-20T12:00:00.000Z',
  'aceitoPeloResponsavelEm': null,
  'analisadoEm': null,
  'diaDaSemana': 'QUARTA',
  'sala': {
    'id': '64b7f0c2a1b2c3d4e5f60111',
    'predioId': '64b7f0c2a1b2c3d4e5f60015',
    'codigo': null,
    'numSala': null,
    'nomeSala': 'Laboratório de Informática 01',
    'andar': 1,
    'capacidade': 30,
    'tipo': 'LABORATORIO',
    'ativa': true,
    'predio': {
      'id': '64b7f0c2a1b2c3d4e5f60015',
      'nome': 'Prédio TI',
      'campusId': null,
    },
    'recursos': [],
  },
  'solicitante': {
    'id': '64b7f0c2a1b2c3d4e5f60222',
    'nome': 'Ana Clara Souza',
    'tipoCredencial': 'MATRICULA_ALUNO',
  },
  'responsavel': {
    'id': '64b7f0c2a1b2c3d4e5f60222',
    'nome': 'Ana Clara Souza',
    'tipoCredencial': 'MATRICULA_ALUNO',
  },
  'analisadoPor': null,
  'serieRecorrencia': null,
};

const _predio = Predio(id: '64b7f0c2a1b2c3d4e5f60015', nome: 'Prédio TI');

const _sala = Sala(
  id: '64b7f0c2a1b2c3d4e5f60111',
  nome: 'Laboratório de Informática 01',
  predio: _predio,
);

const _professor = UsuarioResumo(
  id: '64b7f0c2a1b2c3d4e5f60222',
  nome: 'Carlos Lima',
);

Reserva _novaReserva({String finalidade = '', String? observacoes}) => Reserva(
  sala: _sala,
  solicitante: _professor,
  responsavel: _professor,
  inicio: DateTime.utc(2026, 11, 10, 13),
  fim: DateTime.utc(2026, 11, 10, 13, 50),
  finalidade: finalidade,
  observacoes: observacoes,
);

void main() {
  final service = ServicesReserva();

  setUp(() {
    BaseService.tokenDeSessao = null;
    BaseService.aoSessaoExpirar = null;
  });

  group('buscarPorSala', () {
    test('filtra pela sala e converte a lista detalhada', () async {
      http.Request? enviada;

      final reservas = await comRespostaFixa(
        () => service.buscarPorSala('64b7f0c2a1b2c3d4e5f60111'),
        respostaJson([_reservaJson], 200),
        capturar: (requisicao) => enviada = requisicao,
      );

      expect(enviada!.method, 'GET');
      expect(enviada!.url.path, endsWith('/reservas'));
      expect(enviada!.url.queryParameters, {
        'salaId': '64b7f0c2a1b2c3d4e5f60111',
      });
      expect(reservas.single.finalidade, 'Monitoria de Algoritmos');
      expect(reservas.single.sala.predio.nome, 'Prédio TI');
    });

    test('404 com corpo JSON é lista vazia', () async {
      final reservas = await comRespostaFixa(
        () => service.buscarPorSala('s1'),
        respostaJson({
          'erro': 'NAO_ENCONTRADO',
          'mensagem': 'Nenhuma reserva encontrada.',
        }, 404),
      );

      expect(reservas, isEmpty);
    });
  });

  group('solicitar', () {
    test('envia o POST com finalidade vazia e lê as reservas criadas', () async {
      http.Request? enviada;

      final resultado = await comRespostaFixa(
        () => service.solicitar(_novaReserva()),
        respostaJson({
          'serieRecorrencia': null,
          'reservas': [_reservaJson],
        }, 201),
        capturar: (requisicao) => enviada = requisicao,
      );

      expect(enviada!.method, 'POST');
      expect(enviada!.url.path, endsWith('/reservas'));
      expect(jsonDecode(enviada!.body), {
        'salaId': '64b7f0c2a1b2c3d4e5f60111',
        'responsavelId': '64b7f0c2a1b2c3d4e5f60222',
        'dataHoraInicio': '2026-11-10T13:00:00.000Z',
        'dataHoraFim': '2026-11-10T13:50:00.000Z',
        'finalidade': '',
      });
      expect(resultado.serieRecorrencia, isNull);
      expect(resultado.reservas.single.id, '64b7f0c2a1b2c3d4e5f60718');
      expect(resultado.aguardaAprovacao, isFalse);
    });

    test('envia as observações quando informadas', () async {
      http.Request? enviada;

      await comRespostaFixa(
        () => service.solicitar(
          _novaReserva(finalidade: 'Aula prática', observacoes: 'Projetor'),
        ),
        respostaJson({
          'serieRecorrencia': null,
          'reservas': [_reservaJson],
        }, 201),
        capturar: (requisicao) => enviada = requisicao,
      );

      final corpo = jsonDecode(enviada!.body) as Map<String, dynamic>;
      expect(corpo['finalidade'], 'Aula prática');
      expect(corpo['observacoes'], 'Projetor');
    });

    test('409 repassa a mensagem do backend', () async {
      final erro = await erroDe(
        () => comRespostaFixa(
          () => service.solicitar(_novaReserva()),
          respostaJson({
            'erro': 'CONFLITO',
            'mensagem': 'Sala já reservada neste horário.',
          }, 409),
        ),
      );

      expect(erro, isA<ApiException>());
      expect(erro.mensagem, contains('Sala já reservada neste horário.'));
    });
  });

  group('cancelar', () {
    test('envia a justificativa e lê o cancelamento imediato', () async {
      http.Request? enviada;

      final resultado = await comRespostaFixa(
        () => service.cancelar('r1', 'Imprevisto acadêmico.'),
        respostaJson({
          'reserva': {
            ..._reservaJson,
            'status': 'CANCELADA',
            'cancelamento': {
              'canceladoPorId': '64b7f0c2a1b2c3d4e5f60222',
              'justificativa': 'Imprevisto acadêmico.',
              'canceladoEm': '2026-10-20T14:00:00.000Z',
            },
          },
          'solicitacaoEnviada': false,
          'mensagem': 'Reserva cancelada com sucesso.',
        }, 200),
        capturar: (requisicao) => enviada = requisicao,
      );

      expect(enviada!.method, 'PATCH');
      expect(enviada!.url.path, endsWith('/reservas/r1/cancelar'));
      expect(jsonDecode(enviada!.body), {
        'justificativa': 'Imprevisto acadêmico.',
      });
      expect(resultado.solicitacaoEnviada, isFalse);
      expect(resultado.mensagem, 'Reserva cancelada com sucesso.');
      expect(
        resultado.reserva!.cancelamento!.canceladoPorId,
        '64b7f0c2a1b2c3d4e5f60222',
      );
    });

    test('202 é solicitação enviada à coordenação', () async {
      final resultado = await comRespostaFixa(
        () => service.cancelar('r1', 'Turma remanejada.'),
        respostaJson({
          'reserva': null,
          'solicitacaoEnviada': true,
          'mensagem': 'Solicitação de cancelamento enviada ao coordenador.',
        }, 202),
      );

      expect(resultado.solicitacaoEnviada, isTrue);
      expect(resultado.reserva, isNull);
    });

    test('403 repassa a mensagem do backend', () async {
      final erro = await erroDe(
        () => comRespostaFixa(
          () => service.cancelar('r1', 'Motivo'),
          respostaJson({
            'erro': 'PERMISSAO_NEGADA',
            'mensagem': 'Você não pode cancelar esta reserva.',
          }, 403),
        ),
      );

      expect(erro, isA<ApiException>());
      expect(erro.mensagem, contains('Você não pode cancelar esta reserva.'));
    });
  });
}
