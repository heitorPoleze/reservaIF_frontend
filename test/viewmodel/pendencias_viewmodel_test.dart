import 'package:flutter_test/flutter_test.dart';
import 'package:reserva_if/model/predio/predio.dart';
import 'package:reserva_if/model/reserva/reserva.dart';
import 'package:reserva_if/model/reserva/status_reserva.dart';
import 'package:reserva_if/model/sala/sala.dart';
import 'package:reserva_if/model/usuario/perfil.dart';
import 'package:reserva_if/model/usuario/perfil_usuario.dart';
import 'package:reserva_if/model/usuario/tipo_credencial.dart';
import 'package:reserva_if/model/usuario/usuario_resumo.dart';
import 'package:reserva_if/services/services_reserva.dart';
import 'package:reserva_if/viewmodel/reserva/pendencias_viewmodel.dart';
import 'package:reserva_if/viewmodel/reserva/reservas_mudaram.dart';

const _eu = UsuarioResumo(id: 'u2', nome: 'Carlos Lima');
const _aluno = UsuarioResumo(id: 'u1', nome: 'Ana Souza');
const _outro = UsuarioResumo(id: 'u3', nome: 'Bia Rocha');

class _ServicesReservaFalso extends ServicesReserva {
  int chamadas = 0;
  final List<String> analises = [];
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
  Future<Reserva> aprovar(String idReserva) async {
    analises.add('aprovar|$idReserva');
    return _reserva(idReserva, status: StatusReserva.aprovada);
  }
}

PerfilUsuario _usuario() => const PerfilUsuario(
  uuid: 'u2',
  nome: 'Carlos Lima',
  email: 'carlos@ifes.edu.br',
  perfil: Perfil.professor,
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
  _ServicesReservaFalso service, [
  ReservasMudaram? canal,
]) => PendenciasViewModel(
  usuario: _usuario(),
  service: service,
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

  test('aprovar chama o service e invalida o canal', () async {
    final service = _ServicesReservaFalso();
    final canal = ReservasMudaram();
    final viewModel = _viewModel(service, canal);
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
