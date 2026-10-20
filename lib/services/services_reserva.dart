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

  Future<Reserva> buscarPorId(String idReserva) {
    return executarRequisicao(
      requisicao: RequisicaoHttp.get(rota(idReserva)),
      aoSucesso: (resposta) =>
          extrairObjeto(resposta.bodyBytes, Reserva.fromJson),
      errosPorStatus: {404: 'Reserva não encontrada.'},
      erroMsg: 'Erro ao buscar a reserva.',
      acao: 'buscar a reserva',
    );
  }

  Future<List<Reserva>> buscarSolicitadas() {
    return executarRequisicao(
      requisicao: RequisicaoHttp.get(rota('minhas')),
      aoSucesso: (resposta) =>
          extrairLista(resposta.bodyBytes, Reserva.fromJson),
      aoListaVazia: () => const <Reserva>[],
      erroMsg: 'Erro ao buscar os agendamentos solicitados.',
      acao: 'buscar os agendamentos solicitados',
    );
  }

  Future<List<Reserva>> buscarSobMinhaResponsabilidade() {
    return executarRequisicao(
      requisicao: RequisicaoHttp.get(rota('sob-minha-responsabilidade')),
      aoSucesso: (resposta) =>
          extrairLista(resposta.bodyBytes, Reserva.fromJson),
      aoListaVazia: () => const <Reserva>[],
      erroMsg: 'Erro ao buscar os agendamentos sob sua responsabilidade.',
      acao: 'buscar os agendamentos sob sua responsabilidade',
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

  Future<Reserva> aprovar(String idReserva) {
    return executarRequisicao(
      requisicao: RequisicaoHttp.patch(rota('$idReserva/aprovar')),
      aoSucesso: (resposta) =>
          extrairObjeto(resposta.bodyBytes, Reserva.fromJson),
      erroMsg: 'Não foi possível aprovar a reserva.',
      acao: 'aprovar a reserva',
    );
  }

  Future<Reserva> rejeitar(String idReserva, String motivo) {
    return executarRequisicao(
      requisicao: RequisicaoHttp.patch(
        rota('$idReserva/rejeitar'),
        corpo: {'motivo': motivo},
      ),
      aoSucesso: (resposta) =>
          extrairObjeto(resposta.bodyBytes, Reserva.fromJson),
      erroMsg: 'Não foi possível rejeitar a reserva.',
      acao: 'rejeitar a reserva',
    );
  }
}
