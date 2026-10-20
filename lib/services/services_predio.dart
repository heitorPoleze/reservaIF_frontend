import 'package:reserva_if/model/predio/predio.dart';
import 'package:reserva_if/model/sala/sala.dart';
import 'package:reserva_if/services/http/requisicao_http.dart';
import 'package:reserva_if/services/services_base.dart';

class ServicesPredio extends BaseService {
  @override
  String get recurso => 'predios';

  Future<List<Predio>> buscarTodos() {
    return executarRequisicao(
      requisicao: RequisicaoHttp.get(rota()),
      aoSucesso: (resposta) =>
          extrairLista(resposta.bodyBytes, Predio.fromJson),
      aoListaVazia: () => const <Predio>[],
      erroMsg: 'Erro ao buscar os prédios.',
      acao: 'buscar os prédios',
    );
  }

  Future<List<Sala>> buscarSalas(String idPredio) {
    return executarRequisicao(
      requisicao: RequisicaoHttp.get(rota('$idPredio/salas')),
      aoSucesso: (resposta) => extrairLista(resposta.bodyBytes, Sala.fromJson),
      aoListaVazia: () => const <Sala>[],
      erroMsg: 'Erro ao buscar as salas do prédio.',
      acao: 'buscar as salas do prédio',
    );
  }
}
