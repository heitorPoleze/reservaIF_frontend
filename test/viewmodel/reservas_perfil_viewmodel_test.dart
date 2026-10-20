import 'package:flutter_test/flutter_test.dart';
import 'package:reserva_if/model/predio/predio.dart';
import 'package:reserva_if/model/reserva/modo_cancelamento.dart';
import 'package:reserva_if/model/reserva/reserva.dart';
import 'package:reserva_if/model/reserva/resultado_cancelamento.dart';
import 'package:reserva_if/model/reserva/status_reserva.dart';
import 'package:reserva_if/model/sala/sala.dart';
import 'package:reserva_if/model/usuario/perfil.dart';
import 'package:reserva_if/model/usuario/perfil_usuario.dart';
import 'package:reserva_if/model/usuario/tipo_credencial.dart';
import 'package:reserva_if/model/usuario/usuario_resumo.dart';
import 'package:reserva_if/services/http/exceptions/api_exceptions.dart';
import 'package:reserva_if/services/services_cancelamento.dart';
import 'package:reserva_if/services/services_reserva.dart';
import 'package:reserva_if/viewmodel/reserva/reservas_mudaram.dart';
import 'package:reserva_if/viewmodel/reserva/reservas_perfil_viewmodel.dart';

class _ServicesReservaFalso extends ServicesReserva {
  int chamadasSolicitadas = 0;
  int chamadasResponsabilidade = 0;
  final List<String> cancelamentos = [];
  final List<String> analises = [];

  @override
  Future<List<Reserva>> buscarSolicitadas() async {
    chamadasSolicitadas++;
    return [_reserva('solicitada')];
  }

  @override
  Future<List<Reserva>> buscarSobMinhaResponsabilidade() async {
    chamadasResponsabilidade++;
    return [
      _reserva('responsavel'),
      _reserva('aprovada', status: StatusReserva.aprovada),
    ];
  }

  @override
  Future<ResultadoCancelamento> cancelar(
    String idReserva,
    String justificativa,
  ) async {
    cancelamentos.add('$idReserva|$justificativa');
    return const ResultadoCancelamento(
      solicitacaoEnviada: false,
      mensagem: 'Reserva cancelada com sucesso.',
    );
  }

  @override
  Future<Reserva> aprovar(String idReserva) async {
    analises.add('aprovar|$idReserva');
    return _reserva(idReserva, status: StatusReserva.aprovada);
  }

  @override
  Future<Reserva> rejeitar(String idReserva, String motivo) async {
    analises.add('rejeitar|$idReserva|$motivo');
    return _reserva(idReserva, status: StatusReserva.rejeitada);
  }
}

class _ServicesReservaQueRecusa extends ServicesReserva {
  @override
  Future<Reserva> aprovar(String idReserva) async =>
      throw ApiException('Conflito de horário na sala.');
}

PerfilUsuario _usuario(Perfil perfil, {String uuid = 'u1'}) => PerfilUsuario(
  uuid: uuid,
  nome: 'Ana Souza',
  email: 'ana@ifes.edu.br',
  perfil: perfil,
  tipoCredencial: perfil == Perfil.aluno
      ? TipoCredencial.matriculaAluno
      : TipoCredencial.siapeDocente,
  identificador: '1234567',
  ativo: true,
);

Reserva _reserva(String id, {StatusReserva? status}) => Reserva(
  id: id,
  sala: const Sala(
    id: 's1',
    nome: 'Sala 01',
    predio: Predio(id: 'p1', nome: 'Bloco A'),
  ),
  solicitante: const UsuarioResumo(id: 'u1', nome: 'Ana Souza'),
  responsavel: const UsuarioResumo(id: 'u2', nome: 'Carlos Lima'),
  inicio: DateTime.now().add(const Duration(days: 1)),
  fim: DateTime.now().add(const Duration(days: 1, hours: 1)),
  finalidade: 'Atividade acadêmica',
  status: status ?? StatusReserva.pendente,
);

void main() {
  test('aluno carrega apenas agendamentos solicitados', () async {
    final service = _ServicesReservaFalso();
    final viewModel = ReservasPerfilViewModel(
      usuario: _usuario(Perfil.aluno),
      service: service,
      serviceCancelamento: ServicesCancelamento(),
      reservasMudaram: ReservasMudaram(),
    );
    addTearDown(viewModel.dispose);

    await viewModel.carregar();

    expect(viewModel.podeVerResponsabilidades, isFalse);
    expect(viewModel.solicitadas.single.id, 'solicitada');
    expect(viewModel.sobMinhaResponsabilidade, isEmpty);
    expect(service.chamadasSolicitadas, 1);
    expect(service.chamadasResponsabilidade, 0);
  });

  test('servidor carrega solicitados e sob responsabilidade', () async {
    final service = _ServicesReservaFalso();
    final viewModel = ReservasPerfilViewModel(
      usuario: _usuario(Perfil.coordenador),
      service: service,
      serviceCancelamento: ServicesCancelamento(),
      reservasMudaram: ReservasMudaram(),
    );
    addTearDown(viewModel.dispose);

    await viewModel.carregar();

    expect(viewModel.podeVerResponsabilidades, isTrue);
    expect(viewModel.solicitadas.single.id, 'solicitada');
    expect(viewModel.sobMinhaResponsabilidade.first.id, 'responsavel');
    expect(service.chamadasSolicitadas, 1);
    expect(service.chamadasResponsabilidade, 1);
  });

  test('cancelar envia a justificativa limpa e invalida o canal', () async {
    final service = _ServicesReservaFalso();
    final canal = ReservasMudaram();
    final viewModel = ReservasPerfilViewModel(
      usuario: _usuario(Perfil.coordenador),
      service: service,
      serviceCancelamento: ServicesCancelamento(),
      reservasMudaram: canal,
    );
    addTearDown(viewModel.dispose);
    await viewModel.carregar();

    final resultado = await viewModel.cancelar(
      viewModel.solicitadas.single,
      ModoCancelamento.cancelar,
      '  Imprevisto  ',
    );

    expect(resultado!.mensagem, 'Reserva cancelada com sucesso.');
    expect(service.cancelamentos, ['solicitada|Imprevisto']);
    expect(canal.geracao, 1);
    expect(service.chamadasSolicitadas, 1);
    expect(viewModel.isCancelando, isFalse);
  });

  test('sincronizarCom recarrega as listas só quando a geração muda', () async {
    final service = _ServicesReservaFalso();
    final viewModel = ReservasPerfilViewModel(
      usuario: _usuario(Perfil.coordenador),
      service: service,
      serviceCancelamento: ServicesCancelamento(),
      reservasMudaram: ReservasMudaram(),
    );
    addTearDown(viewModel.dispose);
    await viewModel.carregar();

    viewModel.sincronizarCom(0);
    viewModel.sincronizarCom(0);
    expect(service.chamadasSolicitadas, 1);

    viewModel.sincronizarCom(1);
    await Future<void>.delayed(Duration.zero);
    expect(service.chamadasSolicitadas, 2);
    expect(service.chamadasResponsabilidade, 2);
  });

  test('modoDeCancelamento delega à regra da reserva com o usuário logado', () {
    final viewModel = ReservasPerfilViewModel(
      usuario: _usuario(Perfil.aluno),
      service: _ServicesReservaFalso(),
      serviceCancelamento: ServicesCancelamento(),
      reservasMudaram: ReservasMudaram(),
    );
    addTearDown(viewModel.dispose);

    expect(
      viewModel.modoDeCancelamento(_reserva('futura')),
      ModoCancelamento.cancelar,
    );
    expect(
      viewModel.modoDeCancelamento(
        _reserva('cancelada', status: StatusReserva.cancelada),
      ),
      isNull,
    );
  });

  test('separa cada lista por status', () async {
    final viewModel = ReservasPerfilViewModel(
      usuario: _usuario(Perfil.coordenador),
      service: _ServicesReservaFalso(),
      serviceCancelamento: ServicesCancelamento(),
      reservasMudaram: ReservasMudaram(),
    );
    addTearDown(viewModel.dispose);
    await viewModel.carregar();

    expect(viewModel.solicitadasCom(StatusReserva.pendente).map((r) => r.id), [
      'solicitada',
    ]);
    expect(viewModel.solicitadasCom(StatusReserva.aprovada), isEmpty);
    expect(
      viewModel
          .sobMinhaResponsabilidadeCom(StatusReserva.aprovada)
          .map((r) => r.id),
      ['aprovada'],
    );
    expect(
      viewModel
          .sobMinhaResponsabilidadeCom(StatusReserva.pendente)
          .map((r) => r.id),
      ['responsavel'],
    );
  });

  test('podeAnalisar só vale para o responsável designado', () {
    final viewModel = ReservasPerfilViewModel(
      usuario: _usuario(Perfil.professor, uuid: 'u2'),
      service: _ServicesReservaFalso(),
      serviceCancelamento: ServicesCancelamento(),
      reservasMudaram: ReservasMudaram(),
    );
    addTearDown(viewModel.dispose);

    expect(viewModel.podeAnalisar(_reserva('pendente')), isTrue);
    expect(
      viewModel.podeAnalisar(
        _reserva('aprovada', status: StatusReserva.aprovada),
      ),
      isFalse,
    );
  });

  test('aprovar chama o service e invalida o canal', () async {
    final service = _ServicesReservaFalso();
    final canal = ReservasMudaram();
    final viewModel = ReservasPerfilViewModel(
      usuario: _usuario(Perfil.professor),
      service: service,
      serviceCancelamento: ServicesCancelamento(),
      reservasMudaram: canal,
    );
    addTearDown(viewModel.dispose);

    final aprovou = await viewModel.aprovar(_reserva('r1'));

    expect(aprovou, isTrue);
    expect(service.analises, ['aprovar|r1']);
    expect(canal.geracao, 1);
    expect(viewModel.isAnalisando, isFalse);
  });

  test('rejeitar envia o motivo limpo e invalida o canal', () async {
    final service = _ServicesReservaFalso();
    final canal = ReservasMudaram();
    final viewModel = ReservasPerfilViewModel(
      usuario: _usuario(Perfil.professor),
      service: service,
      serviceCancelamento: ServicesCancelamento(),
      reservasMudaram: canal,
    );
    addTearDown(viewModel.dispose);

    final rejeitou = await viewModel.rejeitar(
      _reserva('r1'),
      '  Sala em obra  ',
    );

    expect(rejeitou, isTrue);
    expect(service.analises, ['rejeitar|r1|Sala em obra']);
    expect(canal.geracao, 1);
  });

  test('falha na análise devolve false e expõe a mensagem', () async {
    final canal = ReservasMudaram();
    final viewModel = ReservasPerfilViewModel(
      usuario: _usuario(Perfil.professor),
      service: _ServicesReservaQueRecusa(),
      serviceCancelamento: ServicesCancelamento(),
      reservasMudaram: canal,
    );
    addTearDown(viewModel.dispose);

    final aprovou = await viewModel.aprovar(_reserva('r1'));

    expect(aprovou, isFalse);
    expect(viewModel.mensagemErroAnalise, 'Conflito de horário na sala.');
    expect(canal.geracao, 0);
  });
}
