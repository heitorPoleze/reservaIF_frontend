import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:reserva_if/services/http/exceptions/api_exceptions.dart';
import 'package:reserva_if/services/http/requisicao_http.dart';
import 'package:reserva_if/services/services_base.dart';

import 'mock_http.dart';

class ItemDeTeste {
  final String id;
  final String nome;

  const ItemDeTeste({required this.id, required this.nome});

  factory ItemDeTeste.fromJson(Map<String, dynamic> json) => ItemDeTeste(
        id: json['id'] as String,
        nome: json['nome'] as String,
      );
}

class ServiceDeTeste extends BaseService {
  @override
  String get recurso => 'itens';

  Future<List<ItemDeTeste>> listar() {
    return executarRequisicao(
      requisicao: RequisicaoHttp.get(rota()),
      aoSucesso: (resposta) =>
          extrairLista(resposta.bodyBytes, ItemDeTeste.fromJson),
      aoListaVazia: () => const [],
      erroMsg: 'Erro ao buscar os itens.',
      acao: 'buscar os itens',
    );
  }

  Future<ItemDeTeste> buscarPorId(String id) {
    return executarRequisicao(
      requisicao: RequisicaoHttp.get(rota(id)),
      aoSucesso: (resposta) =>
          extrairObjeto(resposta.bodyBytes, ItemDeTeste.fromJson),
      errosPorStatus: {404: 'Item não encontrado.'},
      erroMsg: 'Erro ao buscar o item.',
      acao: 'buscar o item',
    );
  }

  Future<bool> cadastrar(String nome) {
    return executarRequisicao(
      requisicao: RequisicaoHttp.post(rota(), corpo: {'nome': nome}),
      aoSucesso: (_) => true,
      resultadosPorStatus: {409: () => false},
      erroMsg: 'Erro ao cadastrar o item.',
      acao: 'cadastrar o item',
    );
  }

  Future<void> excluir(String id) {
    return executarRequisicao<void>(
      requisicao: RequisicaoHttp.delete(rota(id)),
      aoSucesso: (_) {},
      erroMsg: 'Erro ao excluir o item.',
      acao: 'excluir o item',
    );
  }
}

class ServiceExternoDeTeste extends ServiceExterno {
  @override
  String get baseUrl => 'https://terceiro.exemplo';

  @override
  String get recurso => 'consulta';

  Future<Map<String, dynamic>> consultar() {
    return executarRequisicao(
      requisicao: RequisicaoHttp.get(rota()),
      aoSucesso: (resposta) =>
          extrairDadosResposta(resposta.bodyBytes) as Map<String, dynamic>,
      erroMsg: 'Erro ao consultar.',
      acao: 'consultar o terceiro',
    );
  }
}

void main() {
  setUp(() {
    BaseService.sessionCookie = null;
    BaseService.aoPerderConexao = null;
  });

  group('rota', () {
    test('monta a URL a partir do recurso e do caminho', () {
      final service = ServiceDeTeste();

      expect(service.rota().path, endsWith('/itens'));
      expect(service.rota('abc').path, endsWith('/itens/abc'));
      expect(
        service.rota('', {'pagina': '2'}).queryParameters['pagina'],
        '2',
      );
    });
  });

  group('sucesso', () {
    test('extrai lista do envelope data', () async {
      final itens = await comRespostaFixa(
        () => ServiceDeTeste().listar(),
        respostaJson({
          'data': [
            {'id': '1', 'nome': 'A'},
            {'id': '2', 'nome': 'B'},
          ]
        }, 200),
      );

      expect(itens.map((item) => item.nome), ['A', 'B']);
    });

    test('extrai lista de array cru', () async {
      final itens = await comRespostaFixa(
        () => ServiceDeTeste().listar(),
        respostaJson([
          {'id': '1', 'nome': 'A'},
        ], 200),
      );

      expect(itens.single.id, '1');
    });

    test('extrai objeto único', () async {
      final item = await comRespostaFixa(
        () => ServiceDeTeste().buscarPorId('1'),
        respostaJson({'id': '1', 'nome': 'Sala 101'}, 200),
      );

      expect(item.nome, 'Sala 101');
    });

    test('envia o corpo como JSON com os headers padrão', () async {
      late http.Request enviada;

      await comRespostaFixa(
        () => ServiceDeTeste().cadastrar('Novo'),
        respostaSemCorpo(201),
        capturar: (requisicao) => enviada = requisicao,
      );

      expect(enviada.method, 'POST');
      expect(enviada.body, '{"nome":"Novo"}');
      expect(enviada.headers['Content-Type'], contains('application/json'));
    });
  });

  group('sessão', () {
    test('o cookie guardado viaja em toda requisição', () async {
      BaseService.sessionCookie = 'sid=abc123';
      late http.Request enviada;

      await comRespostaFixa(
        () => ServiceDeTeste().listar(),
        respostaJson({'data': []}, 200),
        capturar: (requisicao) => enviada = requisicao,
      );

      expect(enviada.headers['Cookie'], 'sid=abc123');
    });

    test('atualizarCookie guarda só o par nome=valor', () {
      BaseService.atualizarCookie(
        http.Response('', 200, headers: {
          'set-cookie': 'sid=abc123; Path=/; HttpOnly',
        }),
      );

      expect(BaseService.sessionCookie, 'sid=abc123');
    });

    test('service externo não carrega o cookie', () async {
      BaseService.sessionCookie = 'sid=abc123';
      late http.Request enviada;

      await comRespostaFixa(
        () => ServiceExternoDeTeste().consultar(),
        respostaJson({'ok': true}, 200),
        capturar: (requisicao) => enviada = requisicao,
      );

      expect(enviada.headers.containsKey('Cookie'), isFalse);
      expect(enviada.url.host, 'terceiro.exemplo');
    });
  });

  group('erros', () {
    test('a mensagem do backend sobrevive ao rethrow', () async {
      final erro = await erroDe(
        () => comRespostaFixa(
          () => ServiceDeTeste().cadastrar('x'),
          respostaJson({'error': 'Nome já utilizado'}, 400),
        ),
      );

      expect(erro.mensagem, contains('Nome já utilizado'));
      expect(erro.mensagem, isNot(contains('Falha na comunicação')));
    });

    test('ErroPadrao mostra a mensagem, não o código', () async {
      final erro = await erroDe(
        () => comRespostaFixa(
          () => ServiceDeTeste().cadastrar('x'),
          respostaJson(
            {'erro': 'VALIDACAO', 'mensagem': 'Telefone invalido.'},
            400,
          ),
        ),
      );

      expect(erro.mensagem, contains('Telefone invalido.'));
      expect(erro.mensagem, isNot(contains('VALIDACAO')));
    });

    test('lista de erros de validação vira ApiValidationException', () async {
      final erro = await erroDe(
        () => comRespostaFixa(
          () => ServiceDeTeste().cadastrar(''),
          respostaJson({
            'erros': [
              {'msg': 'Nome é obrigatório'},
              {'msg': 'Nome muito curto'},
            ]
          }, 422),
        ),
      );

      expect(erro, isA<ApiValidationException>());
      expect(erro.mensagem, contains('Nome é obrigatório'));
      expect(erro.mensagem, contains('Nome muito curto'));
    });

    test('errosPorStatus vence o corpo do backend', () async {
      final erro = await erroDe(
        () => comRespostaFixa(
          () => ServiceDeTeste().buscarPorId('zzz'),
          respostaJson({'error': 'Not found'}, 404),
        ),
      );

      expect(erro.mensagem, 'Item não encontrado.');
    });

    test('resultadosPorStatus devolve valor em vez de lançar', () async {
      final cadastrou = await comRespostaFixa(
        () => ServiceDeTeste().cadastrar('Repetido'),
        respostaJson({'error': 'Conflito'}, 409),
      );

      expect(cadastrou, isFalse);
    });

    test('404 com corpo JSON é lista vazia quando aoListaVazia existe',
        () async {
      final itens = await comRespostaFixa(
        () => ServiceDeTeste().listar(),
        respostaJson({'error': 'Nenhum item encontrado'}, 404),
      );

      expect(itens, isEmpty);
    });

    test('404 sem aoListaVazia é erro', () async {
      final erro = await erroDe(
        () => comRespostaFixa(
          () => ServiceDeTeste().excluir('1'),
          respostaJson({'error': 'Item inexistente'}, 404),
        ),
      );

      expect(erro.mensagem, contains('Item inexistente'));
    });

    test('5xx vira ErroDoServidorException sem repassar o corpo', () async {
      final erro = await erroDe(
        () => comRespostaFixa(
          () => ServiceDeTeste().listar(),
          http.Response('<html>stack trace</html>', 500),
        ),
      );

      expect(erro, isA<ErroDoServidorException>());
      expect(erro.mensagem, isNot(contains('html')));
    });

    test('falha de rede vira SemConexaoException e aciona o gancho', () async {
      var avisou = false;
      BaseService.aoPerderConexao = () => avisou = true;

      final erro = await erroDe(
        () => comFalhaDeRede(() => ServiceDeTeste().listar()),
      );

      expect(erro, isA<SemConexaoException>());
      expect(erro.mensagem, contains('Falha na comunicação'));
      expect(avisou, isTrue);
    });

    test('defeito de parse não se disfarça de falha de rede', () async {
      final erro = await erroDe(
        () => comRespostaFixa(
          () => ServiceDeTeste().buscarPorId('1'),
          respostaJson({'id': 1, 'nome': 'tipo errado'}, 200),
        ),
      );

      expect(erro.mensagem, contains('Não foi possível buscar o item'));
      expect(erro, isNot(isA<SemConexaoException>()));
    });
  });
}
