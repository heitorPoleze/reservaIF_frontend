import 'package:reserva_if/model/sessao/sessao_autenticada.dart';
import 'package:reserva_if/model/usuario/credencial/credencial.dart';
import 'package:reserva_if/services/http/requisicao_http.dart';
import 'package:reserva_if/services/services_base.dart';

class ServicesAutenticacao extends BaseService {
  @override
  String get recurso => 'autenticacao';

  Future<SessaoAutenticada> entrar(Credencial credencial) {
    return executarRequisicao(
      requisicao: RequisicaoHttp.post(rota('login'), corpo: credencial.toJson()),
      aoSucesso: (resposta) =>
          extrairObjeto(resposta.bodyBytes, SessaoAutenticada.fromJson),
      errosPorStatus: {401: 'Matrícula/SIAPE ou senha inválidos.'},
      erroMsg: 'Não foi possível entrar.',
      acao: 'entrar',
    );
  }
}
