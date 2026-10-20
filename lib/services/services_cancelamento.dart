import 'package:reserva_if/model/reserva/resultado_cancelamento.dart';
import 'package:reserva_if/model/reserva/solicitacao_cancelamento.dart';
import 'package:reserva_if/services/http/requisicao_http.dart';
import 'package:reserva_if/services/services_base.dart';

class ServicesCancelamento extends BaseService {
  @override
  String get recurso => 'cancelamentos';

  Future<ResultadoCancelamento> solicitarHorario(
    String idReserva,
    String justificativa,
  ) {
    return executarRequisicao(
      requisicao: RequisicaoHttp.post(
        rota('$idReserva/solicitar'),
        corpo: {'justificativa': justificativa},
      ),
      aoSucesso: (resposta) =>
          extrairObjeto(resposta.bodyBytes, ResultadoCancelamento.fromJson),
      erroMsg: 'Não foi possível solicitar o horário.',
      acao: 'solicitar o horário',
    );
  }

  Future<List<SolicitacaoCancelamento>> buscarSolicitacoesPendentes() {
    return executarRequisicao(
      requisicao: RequisicaoHttp.get(rota('solicitacoes')),
      aoSucesso: (resposta) =>
          extrairLista(resposta.bodyBytes, SolicitacaoCancelamento.fromJson),
      aoListaVazia: () => const <SolicitacaoCancelamento>[],
      erroMsg: 'Erro ao buscar os conflitos de horário.',
      acao: 'buscar os conflitos de horário',
    );
  }

  Future<SolicitacaoCancelamento> aprovarSolicitacao(String idSolicitacao) {
    return executarRequisicao(
      requisicao: RequisicaoHttp.post(
        rota('solicitacoes/$idSolicitacao/aprovar'),
      ),
      aoSucesso: (resposta) =>
          extrairObjeto(resposta.bodyBytes, _lerSolicitacaoDoResultado),
      erroMsg: 'Não foi possível trocar o horário.',
      acao: 'trocar o horário',
    );
  }

  Future<SolicitacaoCancelamento> rejeitarSolicitacao(String idSolicitacao) {
    return executarRequisicao(
      requisicao: RequisicaoHttp.post(
        rota('solicitacoes/$idSolicitacao/rejeitar'),
      ),
      aoSucesso: (resposta) =>
          extrairObjeto(resposta.bodyBytes, _lerSolicitacaoDoResultado),
      erroMsg: 'Não foi possível declinar a solicitação.',
      acao: 'declinar a solicitação',
    );
  }

  static SolicitacaoCancelamento _lerSolicitacaoDoResultado(
    Map<String, dynamic> json,
  ) => SolicitacaoCancelamento.fromJson(
    json['solicitacao'] as Map<String, dynamic>,
  );
}
