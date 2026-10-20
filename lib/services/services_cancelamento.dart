import 'package:reserva_if/model/reserva/resultado_cancelamento.dart';
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
}
