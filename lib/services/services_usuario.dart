import 'package:reserva_if/model/usuario/cadastro_usuario.dart';
import 'package:reserva_if/model/usuario/departamento_elegivel.dart';
import 'package:reserva_if/services/http/ambiente.dart';
import 'package:reserva_if/services/http/requisicao_http.dart';
import 'package:reserva_if/services/services_base.dart';

class ServicesUsuario extends BaseService {
  ServicesUsuario({
    this.chaveDeProvisionamento = Ambiente.chaveDeProvisionamento,
  });

  static const String cabecalhoDeProvisionamento = 'x-provision-key';

  final String chaveDeProvisionamento;

  @override
  String get recurso => 'usuarios';

  Future<List<DepartamentoElegivel>> buscarDepartamentosElegiveis() {
    return executarRequisicao(
      requisicao: RequisicaoHttp.get(rota('departamentos-elegiveis')),
      aoSucesso: (resposta) =>
          extrairLista(resposta.bodyBytes, DepartamentoElegivel.fromJson),
      erroMsg: 'Erro ao buscar os cursos e departamentos.',
      acao: 'buscar os cursos e departamentos',
    );
  }

  Future<String> cadastrar(CadastroUsuario cadastro) {
    return executarRequisicao(
      requisicao: RequisicaoHttp.post(
        rota(),
        corpo: cadastro.toJson(),
        cabecalhos: _cabecalhosDoCadastro(cadastro),
      ),
      aoSucesso: (resposta) =>
          extrairObjeto(resposta.bodyBytes, (json) => json['uuid'] as String),
      errosPorStatus: {
        403: 'Cadastro de servidor não autorizado: chave de '
            'provisionamento ausente ou inválida.',
      },
      erroMsg: 'Não foi possível concluir o cadastro.',
      acao: 'concluir o cadastro',
    );
  }

  Map<String, String> _cabecalhosDoCadastro(CadastroUsuario cadastro) {
    if (!cadastro.exigeProvisionamento || chaveDeProvisionamento.isEmpty) {
      return const {};
    }
    return {cabecalhoDeProvisionamento: chaveDeProvisionamento};
  }
}
