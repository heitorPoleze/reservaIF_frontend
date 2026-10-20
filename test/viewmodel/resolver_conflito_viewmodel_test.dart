import 'package:flutter_test/flutter_test.dart';
import 'package:reserva_if/model/predio/predio.dart';
import 'package:reserva_if/model/reserva/conflito_de_horario.dart';
import 'package:reserva_if/model/reserva/reserva.dart';
import 'package:reserva_if/model/reserva/solicitacao_cancelamento.dart';
import 'package:reserva_if/model/sala/sala.dart';
import 'package:reserva_if/model/usuario/usuario_resumo.dart';
import 'package:reserva_if/services/http/exceptions/api_exceptions.dart';
import 'package:reserva_if/services/services_cancelamento.dart';
import 'package:reserva_if/viewmodel/reserva/reservas_mudaram.dart';
import 'package:reserva_if/viewmodel/reserva/resolver_conflito_viewmodel.dart';

const _aluno = UsuarioResumo(id: 'a1', nome: 'Raquel Souza');

final _solicitacao = SolicitacaoCancelamento(
  id: 'sol1',
  reservaId: 'r1',
  solicitadoPorId: 'p1',
  justificativa: 'Prova prática.',
  criadoEm: DateTime(2026, 10, 20),
);

class _ServicesCancelamentoFalso extends ServicesCancelamento {
  final List<String> decisoes = [];
  bool falhar = false;

  @override
  Future<SolicitacaoCancelamento> aprovarSolicitacao(
    String idSolicitacao,
  ) async {
    if (falhar) throw ApiException('Apenas coordenadores podem aprovar.');
    decisoes.add('aprovar|$idSolicitacao');
    return _solicitacao;
  }

  @override
  Future<SolicitacaoCancelamento> rejeitarSolicitacao(
    String idSolicitacao,
  ) async {
    decisoes.add('rejeitar|$idSolicitacao');
    return _solicitacao;
  }
}

ConflitoDeHorario _conflito() => ConflitoDeHorario(
  solicitacao: _solicitacao,
  reserva: Reserva(
    id: 'r1',
    sala: const Sala(
      id: 's1',
      nome: 'Sala 02',
      predio: Predio(id: 'p1', nome: 'PP'),
    ),
    solicitante: _aluno,
    responsavel: _aluno,
    inicio: DateTime(2026, 11, 1, 7, 20),
    fim: DateTime(2026, 11, 1, 9, 20),
    finalidade: 'Estudo',
  ),
);

void main() {
  late _ServicesCancelamentoFalso service;
  late ReservasMudaram canal;
  late ResolverConflitoViewModel viewModel;

  setUp(() {
    service = _ServicesCancelamentoFalso();
    canal = ReservasMudaram();
    viewModel = ResolverConflitoViewModel(
      conflito: _conflito(),
      service: service,
      reservasMudaram: canal,
    );
  });

  tearDown(() => viewModel.dispose());

  test('trocar aprova a solicitação e invalida o canal', () async {
    final trocou = await viewModel.trocar();

    expect(trocou, isTrue);
    expect(service.decisoes, ['aprovar|sol1']);
    expect(canal.geracao, 1);
  });

  test('declinar rejeita a solicitação e invalida o canal', () async {
    final declinou = await viewModel.declinar();

    expect(declinou, isTrue);
    expect(service.decisoes, ['rejeitar|sol1']);
    expect(canal.geracao, 1);
  });

  test('falha não invalida o canal e expõe a mensagem', () async {
    service.falhar = true;

    final trocou = await viewModel.trocar();

    expect(trocou, isFalse);
    expect(canal.geracao, 0);
    expect(viewModel.mensagemErro, 'Apenas coordenadores podem aprovar.');
  });
}
