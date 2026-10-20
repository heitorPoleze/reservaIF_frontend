import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:reserva_if/model/predio/predio.dart';
import 'package:reserva_if/model/reserva/reserva.dart';
import 'package:reserva_if/model/reserva/resultado_cancelamento.dart';
import 'package:reserva_if/model/reserva/status_reserva.dart';
import 'package:reserva_if/model/sala/sala.dart';
import 'package:reserva_if/model/usuario/perfil.dart';
import 'package:reserva_if/model/usuario/perfil_usuario.dart';
import 'package:reserva_if/model/usuario/tipo_credencial.dart';
import 'package:reserva_if/model/usuario/usuario_resumo.dart';
import 'package:reserva_if/services/http/exceptions/api_exceptions.dart';
import 'package:reserva_if/services/services_predio.dart';
import 'package:reserva_if/services/services_reserva.dart';
import 'package:reserva_if/utils/datas.dart';
import 'package:reserva_if/viewmodel/reserva/agendamento_viewmodel.dart';

const _predio = Predio(id: 'p1', nome: 'Prédio TI');

const _labA = Sala(id: 'sA', nome: 'Lab. A', predio: _predio);

const _labB = Sala(id: 'sB', nome: 'Lab. B', predio: _predio);

const _aluna = UsuarioResumo(id: 'u1', nome: 'Ana Souza');

const _usuario = PerfilUsuario(
  uuid: 'u1',
  nome: 'Ana Souza',
  email: 'ana@ifes.edu.br',
  perfil: Perfil.aluno,
  tipoCredencial: TipoCredencial.matriculaAluno,
  identificador: '20241tsi0063',
  ativo: true,
);

Reserva _reservaAmanha(
  Sala sala, {
  StatusReserva status = StatusReserva.agendada,
}) {
  final amanha = diaSeguinte(hoje());

  return Reserva(
    id: 'r-${sala.id}',
    sala: sala,
    solicitante: _aluna,
    responsavel: _aluna,
    inicio: combinarDataEHora(amanha, 9, 0),
    fim: combinarDataEHora(amanha, 9, 50),
    finalidade: 'Monitoria',
    status: status,
  );
}

class ServicesPredioFalso extends ServicesPredio {
  ServicesPredioFalso({this.falhar = false});

  final bool falhar;

  @override
  Future<List<Sala>> buscarSalas(String idPredio) async {
    if (falhar) throw ApiException('Salas indisponíveis.');
    return const [_labA, _labB];
  }
}

class ServicesReservaFalso extends ServicesReserva {
  final Map<String, Completer<List<Reserva>>> pendentes = {};
  final List<String> cancelamentos = [];
  int buscas = 0;

  @override
  Future<List<Reserva>> buscarPorSala(String idSala) {
    buscas++;
    final pendente = pendentes[idSala];
    if (pendente != null) return pendente.future;
    return Future.value([_reservaAmanha(idSala == 'sA' ? _labA : _labB)]);
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
}

AgendamentoViewModel _viewModel({
  ServicesPredio? servicePredio,
  ServicesReserva? serviceReserva,
}) => AgendamentoViewModel(
  predio: _predio,
  usuario: _usuario,
  servicePredio: servicePredio ?? ServicesPredioFalso(),
  serviceReserva: serviceReserva ?? ServicesReservaFalso(),
);

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  test('carregarSalas popula as salas do prédio', () async {
    final viewModel = _viewModel();

    await viewModel.carregarSalas();

    expect(viewModel.salas.map((sala) => sala.id), ['sA', 'sB']);
    expect(viewModel.salaSelecionada, isNull);
    expect(viewModel.mensagemErro, isNull);
  });

  test('falha nas salas expõe a mensagem', () async {
    final viewModel = _viewModel(
      servicePredio: ServicesPredioFalso(falhar: true),
    );

    await viewModel.carregarSalas();

    expect(viewModel.salas, isEmpty);
    expect(viewModel.mensagemErro, 'Salas indisponíveis.');
  });

  test('escolher a sala carrega as reservas e marca os dias', () async {
    final viewModel = _viewModel();

    viewModel.selecionarSala(_labA);
    await viewModel.carregarReservas();

    expect(viewModel.reservas.single.sala.id, 'sA');
    expect(viewModel.diasComReserva, {diaSeguinte(hoje())});
  });

  test('reserva terminal não marca dia no calendário', () async {
    final service = ServicesReservaFalso()
      ..pendentes['sA'] = (Completer<List<Reserva>>()
        ..complete([_reservaAmanha(_labA, status: StatusReserva.cancelada)]));
    final viewModel = _viewModel(serviceReserva: service);

    viewModel.selecionarSala(_labA);
    await viewModel.carregarReservas();

    expect(viewModel.diasComReserva, isEmpty);
  });

  test('horários do dia refletem a reserva e contam os livres', () async {
    final viewModel = _viewModel();

    viewModel.selecionarSala(_labA);
    await viewModel.carregarReservas();
    viewModel.selecionarDia(diaSeguinte(hoje()));

    expect(viewModel.horariosDoDia, hasLength(15));
    expect(viewModel.horariosDoDia.where((h) => !h.livre), hasLength(1));
    expect(viewModel.quantidadeLivres, 14);
    expect(viewModel.rotuloLivres, '14 livres');
  });

  test('resposta da sala anterior é descartada após a troca', () async {
    final service = ServicesReservaFalso();
    final respostaDeA = Completer<List<Reserva>>();
    service.pendentes['sA'] = respostaDeA;
    final viewModel = _viewModel(serviceReserva: service);

    viewModel.selecionarSala(_labA);
    viewModel.selecionarSala(_labB);
    await Future<void>.delayed(Duration.zero);
    respostaDeA.complete([_reservaAmanha(_labA)]);
    await Future<void>.delayed(Duration.zero);

    expect(viewModel.salaSelecionada, _labB);
    expect(viewModel.reservas.single.sala.id, 'sB');
    expect(viewModel.isCarregandoReservas, isFalse);
  });

  test('cancelar envia a justificativa limpa e recarrega a sala', () async {
    final service = ServicesReservaFalso();
    final viewModel = _viewModel(serviceReserva: service);
    viewModel.selecionarSala(_labA);
    await viewModel.carregarReservas();
    final buscasAntes = service.buscas;

    final resultado = await viewModel.cancelar(
      viewModel.reservas.single,
      '  Imprevisto  ',
    );

    expect(resultado!.mensagem, 'Reserva cancelada com sucesso.');
    expect(service.cancelamentos, ['r-sA|Imprevisto']);
    expect(service.buscas, buscasAntes + 1);
    expect(viewModel.isCancelando, isFalse);
  });

  test('podeCancelar delega à regra da reserva com o usuário logado', () {
    final viewModel = _viewModel();

    expect(viewModel.podeCancelar(_reservaAmanha(_labA)), isTrue);
    expect(
      viewModel.podeCancelar(
        _reservaAmanha(_labA, status: StatusReserva.cancelada),
      ),
      isFalse,
    );
  });
}
