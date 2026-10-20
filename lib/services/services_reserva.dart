import 'package:reserva_if/model/reserva/reserva.dart';
import 'package:reserva_if/model/reserva/resultado_cancelamento.dart';
import 'package:reserva_if/model/reserva/resultado_criacao_reserva.dart';
import 'package:reserva_if/services/http/requisicao_http.dart';
import 'package:reserva_if/services/services_base.dart';

class ServicesReserva extends BaseService {
  @override
  String get recurso => 'reservas';

  Future<List<Reserva>> buscarPorSala(String idSala) {
    return executarRequisicao(
      requisicao: RequisicaoHttp.get(rota('', {'salaId': idSala})),
      aoSucesso: (resposta) =>
          extrairLista(resposta.bodyBytes, Reserva.fromJson),
      aoListaVazia: () => const <Reserva>[],
      erroMsg: 'Erro ao buscar as reservas da sala.',
      acao: 'buscar as reservas da sala',
    );
  }

  Future<ResultadoCriacaoReserva> solicitar(Reserva reserva) {
    return executarRequisicao(
      requisicao: RequisicaoHttp.post(rota(''), corpo: reserva.toJson()),
      aoSucesso: (resposta) =>
          extrairObjeto(resposta.bodyBytes, ResultadoCriacaoReserva.fromJson),
      erroMsg: 'Não foi possível reservar o horário.',
      acao: 'reservar o horário',
    );
  }

  Future<ResultadoCancelamento> cancelar(
    String idReserva,
    String justificativa,
  ) {
    return executarRequisicao(
      requisicao: RequisicaoHttp.patch(
        rota('$idReserva/cancelar'),
        corpo: {'justificativa': justificativa},
      ),
      aoSucesso: (resposta) =>
          extrairObjeto(resposta.bodyBytes, ResultadoCancelamento.fromJson),
      erroMsg: 'Não foi possível cancelar a reserva.',
      acao: 'cancelar a reserva',
    );
  }
}
