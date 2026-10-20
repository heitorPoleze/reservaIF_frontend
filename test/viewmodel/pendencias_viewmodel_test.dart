import 'package:flutter_test/flutter_test.dart';
import 'package:reserva_if/model/predio/predio.dart';
import 'package:reserva_if/model/reserva/reserva.dart';
import 'package:reserva_if/model/reserva/solicitacao_cancelamento.dart';
import 'package:reserva_if/model/reserva/status_reserva.dart';
import 'package:reserva_if/model/reserva/status_solicitacao_cancelamento.dart';
import 'package:reserva_if/model/sala/sala.dart';
import 'package:reserva_if/model/usuario/perfil.dart';
import 'package:reserva_if/model/usuario/perfil_usuario.dart';
import 'package:reserva_if/model/usuario/servidor_resumo.dart';
import 'package:reserva_if/model/usuario/tipo_credencial.dart';
import 'package:reserva_if/model/usuario/usuario_resumo.dart';
import 'package:reserva_if/services/services_cancelamento.dart';
import 'package:reserva_if/services/services_reserva.dart';
import 'package:reserva_if/services/services_usuario.dart';
import 'package:reserva_if/viewmodel/reserva/pendencias_viewmodel.dart';
import 'package:reserva_if/viewmodel/reserva/reservas_mudaram.dart';

const _eu = UsuarioResumo(id: 'u2', nome: 'Carlos Lima');
const _aluno = UsuarioResumo(id: 'u1', nome: 'Ana Souza');
const _outro = UsuarioResumo(id: 'u3', nome: 'Bia Rocha');

class _ServicesReservaFalso extends ServicesReserva {
  int chamadas = 0;
  final List<String> analises = [];
  final List<String> buscasPorId = [];
  List<Reserva> resposta = [
    _reserva('convite'),
    _reserva('aprovada', status: StatusReserva.aprovada),
    _reserva('propria', solicitante: _eu),
    _reserva('de-outro', responsavel: _outro),
  ];

  @override
  Future<List<Reserva>> buscarSobMinhaResponsabilidade() async {
    chamadas++;
    return resposta;
  }

  @override
  Future<Reserva> buscarPorId(String idReserva) async {
    buscasPorId.add(idReserva);
    return _reserva(
      idReserva,
      status: StatusReserva.agendada,
      responsavel: _aluno,
    );
  }

  @override
  Future<Reserva> aprovar(String idReserva) async {
    analises.add('aprovar|$idReserva');
    return _reserva(idReserva, status: StatusReserva.aprovada);
  }
}

class _ServicesCancelamentoFalso extends ServicesCancelamento {
  int chamadas = 0;

  @override
  Future<List<SolicitacaoCancelamento>> buscarSolicitacoesPendentes() async {
    chamadas++;
    return [
      _solicitacao('sol1', 'r1', 'p1'),
      _solicitacao('sol2', 'r2', 'desconhecido'),
      _solicitacao(
        'sol3',
        'r3',
        'p1',
        status: StatusSolicitacaoCancelamento.aprovada,
      ),
    ];
  }
}

class _ServicesUsuarioFalso extends ServicesUsuario {
  int chamadas = 0;

  @override
  Future<List<ServidorResumo>> buscarServidores() async {
    chamadas++;
    return const [
      ServidorResumo(id: 'p1', nome: 'Bruno Ratto', perfil: Perfil.professor),
    ];
  }
}

SolicitacaoCancelamento _solicitacao(
  String id,
  String reservaId,
  String professorId, {
  StatusSolicitacaoCancelamento status = StatusSolicitacaoCancelamento.pendente,
}) => SolicitacaoCancelamento(
  id: id,
  reservaId: reservaId,
  solicitadoPorId: professorId,
  justificativa: 'Prova prática.',
  status: status,
  criadoEm: DateTime(2026, 10, 20),
);

PerfilUsuario _usuario([Perfil perfil = Perfil.professor]) => PerfilUsuario(
  uuid: 'u2',
  nome: 'Carlos Lima',
  email: 'carlos@ifes.edu.br',
  perfil: perfil,
  tipoCredencial: TipoCredencial.siapeDocente,
  identificador: '1234567',
  ativo: true,
);

Reserva _reserva(
  String id, {
  StatusReserva? status,
  UsuarioResumo solicitante = _aluno,
  UsuarioResumo responsavel = _eu,
}) => Reserva(
  id: id,
  sala: const Sala(
    id: 's1',
    nome: 'Sala 01',
    predio: Predio(id: 'p1', nome: 'Bloco A'),
  ),
  solicitante: solicitante,
  responsavel: responsavel,
  inicio: DateTime.now().add(const Duration(days: 1)),
  fim: DateTime.now().add(const Duration(days: 1, hours: 1)),
  finalidade: 'Atividade acadêmica',
  status: status ?? StatusReserva.pendente,
);

PendenciasViewModel _viewModel(
  _ServicesReservaFalso service, {
  ReservasMudaram? canal,
  Perfil perfil = Perfil.professor,
  _ServicesCancelamentoFalso? serviceCancelamento,
  _ServicesUsuarioFalso? serviceUsuario,
}) => PendenciasViewModel(
  usuario: _usuario(perfil),
  service: service,
  serviceCancelamento: serviceCancelamento ?? _ServicesCancelamentoFalso(),
  serviceUsuario: serviceUsuario ?? _ServicesUsuarioFalso(),
  reservasMudaram: canal ?? ReservasMudaram(),
);

void main() {
  test('carrega só os convites que o usuário pode analisar', () async {
    final viewModel = _viewModel(_ServicesReservaFalso());
    addTearDown(viewModel.dispose);

    await viewModel.carregar();

    expect(viewModel.convites.map((reserva) => reserva.id), ['convite']);
    expect(viewModel.rotuloDeConvites, '1 convite');
  });

  test('rótulo usa o plural com mais de um convite', () async {
    final service = _ServicesReservaFalso()
      ..resposta = [_reserva('a'), _reserva('b')];
    final viewModel = _viewModel(service);
    addTearDown(viewModel.dispose);

    await viewModel.carregar();

    expect(viewModel.rotuloDeConvites, '2 convites');
  });

  test('professor não busca conflitos de horário', () async {
    final cancelamento = _ServicesCancelamentoFalso();
    final usuarios = _ServicesUsuarioFalso();
    final viewModel = _viewModel(
      _ServicesReservaFalso(),
      serviceCancelamento: cancelamento,
      serviceUsuario: usuarios,
    );
    addTearDown(viewModel.dispose);

    await viewModel.carregar();

    expect(viewModel.conflitos, isEmpty);
    expect(cancelamento.chamadas, 0);
    expect(usuarios.chamadas, 0);
  });

  test(
    'coordenador monta os conflitos pendentes com reserva e professor',
    () async {
      final service = _ServicesReservaFalso()..resposta = const [];
      final viewModel = _viewModel(service, perfil: Perfil.coordenador);
      addTearDown(viewModel.dispose);

      await viewModel.carregar();

      expect(service.buscasPorId, ['r1', 'r2']);
      expect(viewModel.conflitos.map((conflito) => conflito.titulo), [
        'Ana Souza X Bruno Ratto',
        'Ana Souza X Professor',
      ]);
      expect(viewModel.rotuloDeConflitos, '2 solicitações');
      expect(viewModel.semPendencias, isFalse);
    },
  );

  test('semPendencias só sem convites e sem conflitos', () async {
    final service = _ServicesReservaFalso()..resposta = const [];
    final viewModel = _viewModel(service);
    addTearDown(viewModel.dispose);

    await viewModel.carregar();

    expect(viewModel.semPendencias, isTrue);
  });

  test('aprovar chama o service e invalida o canal', () async {
    final service = _ServicesReservaFalso();
    final canal = ReservasMudaram();
    final viewModel = _viewModel(service, canal: canal);
    addTearDown(viewModel.dispose);
    await viewModel.carregar();

    final aprovou = await viewModel.aprovar(viewModel.convites.single);

    expect(aprovou, isTrue);
    expect(service.analises, ['aprovar|convite']);
    expect(canal.geracao, 1);
  });

  test('sincronizarCom recarrega só quando a geração muda', () async {
    final service = _ServicesReservaFalso();
    final viewModel = _viewModel(service);
    addTearDown(viewModel.dispose);
    await viewModel.carregar();

    viewModel.sincronizarCom(0);
    viewModel.sincronizarCom(0);
    expect(service.chamadas, 1);

    viewModel.sincronizarCom(1);
    await Future<void>.delayed(Duration.zero);
    expect(service.chamadas, 2);
  });
}
