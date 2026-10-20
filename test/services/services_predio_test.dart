import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:reserva_if/services/http/exceptions/api_exceptions.dart';
import 'package:reserva_if/services/services_base.dart';
import 'package:reserva_if/services/services_predio.dart';

import 'mock_http.dart';

void main() {
  final service = ServicesPredio();

  setUp(() {
    BaseService.tokenDeSessao = null;
    BaseService.aoSessaoExpirar = null;
  });

  group('buscarTodos', () {
    test('converte a lista da API, com e sem endereço', () async {
      http.Request? enviada;

      final predios = await comRespostaFixa(
        service.buscarTodos,
        respostaJson([
          {
            'id': '64b7f0c2a1b2c3d4e5f60011',
            'nome': 'Prédio Administrativo',
            'campusId': null,
            'endereco': {
              'rua': 'Rodovia ES-080, Km 93',
              'numero': 100,
              'bairro': 'São João de Petrópolis',
              'cep': '29660-000',
            },
          },
          {
            'id': '64b7f0c2a1b2c3d4e5f60012',
            'nome': 'Prédio Pedagógico',
            'campusId': null,
            'endereco': null,
          },
        ], 200),
        capturar: (requisicao) => enviada = requisicao,
      );

      expect(enviada!.method, 'GET');
      expect(enviada!.url.path, endsWith('/predios'));
      expect(predios.map((predio) => predio.nome), [
        'Prédio Administrativo',
        'Prédio Pedagógico',
      ]);
      expect(
        predios.first.endereco!.formatado,
        'Rodovia ES-080, Km 93, 100 - São João de Petrópolis',
      );
      expect(predios.last.endereco, isNull);
      expect(predios.last.salas, isEmpty);
    });

    test('array vazio é lista vazia', () async {
      final predios = await comRespostaFixa(
        service.buscarTodos,
        respostaJson([], 200),
      );

      expect(predios, isEmpty);
    });

    test('404 com corpo JSON é lista vazia', () async {
      final predios = await comRespostaFixa(
        service.buscarTodos,
        respostaJson({
          'erro': 'NAO_ENCONTRADO',
          'mensagem': 'Nenhum prédio encontrado.',
        }, 404),
      );

      expect(predios, isEmpty);
    });

    test('5xx vira ErroDoServidorException', () async {
      final erro = await erroDe(
        () => comRespostaFixa(service.buscarTodos, respostaSemCorpo(500)),
      );

      expect(erro, isA<ErroDoServidorException>());
    });
  });

  group('buscarSalas', () {
    test('lista as salas do prédio com o prédio embutido', () async {
      http.Request? enviada;

      final salas = await comRespostaFixa(
        () => service.buscarSalas('64b7f0c2a1b2c3d4e5f60015'),
        respostaJson([
          {
            'id': '64b7f0c2a1b2c3d4e5f60111',
            'nome': 'Laboratório de Informática 01',
            'nomeSala': 'Laboratório de Informática 01',
            'capacidade': 30,
            'predioId': '64b7f0c2a1b2c3d4e5f60015',
            'ativa': true,
            'codigo': null,
            'numSala': null,
            'andar': 1,
            'tipo': 'LABORATORIO',
            'predio': {
              'id': '64b7f0c2a1b2c3d4e5f60015',
              'nome': 'Prédio TI',
              'campusId': null,
            },
          },
        ], 200),
        capturar: (requisicao) => enviada = requisicao,
      );

      expect(enviada!.method, 'GET');
      expect(
        enviada!.url.path,
        endsWith('/predios/64b7f0c2a1b2c3d4e5f60015/salas'),
      );
      expect(salas.single.nome, 'Laboratório de Informática 01');
      expect(salas.single.predio.nome, 'Prédio TI');
      expect(salas.single.nomeComPredio, 'Laboratório de Informática 01 · Prédio TI');
    });

    test('404 com corpo JSON é lista vazia', () async {
      final salas = await comRespostaFixa(
        () => service.buscarSalas('p1'),
        respostaJson({
          'erro': 'NAO_ENCONTRADO',
          'mensagem': 'Nenhuma sala encontrada.',
        }, 404),
      );

      expect(salas, isEmpty);
    });
  });
}
