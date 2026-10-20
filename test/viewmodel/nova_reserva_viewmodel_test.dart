import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:reserva_if/model/predio/predio.dart';
import 'package:reserva_if/model/reserva/horario_do_dia.dart';
import 'package:reserva_if/model/reserva/reserva.dart';
import 'package:reserva_if/model/reserva/resultado_criacao_reserva.dart';
import 'package:reserva_if/model/reserva/status_reserva.dart';
import 'package:reserva_if/model/sala/sala.dart';
import 'package:reserva_if/model/usuario/perfil.dart';
import 'package:reserva_if/model/usuario/perfil_usuario.dart';
import 'package:reserva_if/model/usuario/servidor_resumo.dart';
import 'package:reserva_if/model/usuario/tipo_credencial.dart';
import 'package:reserva_if/services/http/exceptions/api_exceptions.dart';
import 'package:reserva_if/services/services_reserva.dart';
import 'package:reserva_if/services/services_usuario.dart';
import 'package:reserva_if/utils/datas.dart';
import 'package:reserva_if/viewmodel/reserva/nova_reserva_viewmodel.dart';

const _predio = Predio(id: 'p1', nome: 'Prédio TI');

const _sala = Sala(id: 'sA', nome: 'Lab. A', predio: _predio);

const _usuario = PerfilUsuario(
  uuid: 'u1',
  nome: 'Paulo Lima',
  email: 'paulo@ifes.edu.br',
  perfil: Perfil.professor,
  tipoCredencial: TipoCredencial.siapeDocente,
  identificador: '1234567',
  ativo: true,
);

const _aluno = PerfilUsuario(
  uuid: 'a1',
  nome: 'Ana Souza',
  email: 'ana@aluno.ifes.edu.br',
  perfil: Perfil.aluno,
  tipoCredencial: TipoCredencial.matriculaAluno,
  identificador: '20231001',
  ativo: true,
);

const _coordenadorLogado = PerfilUsuario(
  uuid: 'c1',
  nome: 'Marta Reis',
  email: 'marta@ifes.edu.br',
  perfil: Perfil.coordenador,
  tipoCredencial: TipoCredencial.siapeDocente,
  identificador: '7654321',
  ativo: true,
);

const _professor = ServidorResumo(
  id: 's1',
  nome: 'Prof. Carlos Mendes',
  perfil: Perfil.professor,
);

const _tecnico = ServidorResumo(
  id: 's2',
  nome: 'João Silva',
  perfil: Perfil.tecnico,
);

const _coordenador = ServidorResumo(
  id: 's3',
  nome: 'Coord. Roberto Lima',
  perfil: Perfil.coordenador,
);

const _servidores = [_professor, _tecnico, _coordenador];

final _horario = HorarioDoDia(
  inicio: combinarDataEHora(diaSeguinte(hoje()), 9, 0),
  fim: combinarDataEHora(diaSeguinte(hoje()), 9, 50),
);

class ServicesReservaFalso extends ServicesReserva {
  ServicesReservaFalso({this.falhar = false});

  final bool falhar;
  final List<Reserva> enviadas = [];
  Completer<void>? pendente;

  @override
  Future<ResultadoCriacaoReserva> solicitar(Reserva reserva) async {
    enviadas.add(reserva);
    await pendente?.future;
    if (falhar) throw ApiException('Sala já reservada neste horário.');
    return ResultadoCriacaoReserva(
      reservas: [
        Reserva(
          id: 'r1',
          sala: reserva.sala,
          solicitante: reserva.solicitante,
          responsavel: reserva.responsavel,
          inicio: reserva.inicio,
          fim: reserva.fim,
          finalidade: reserva.finalidade,
          observacoes: reserva.observacoes,
          status: StatusReserva.agendada,
        ),
      ],
    );
  }
}

class ServicesUsuarioFalso extends ServicesUsuario {
  ServicesUsuarioFalso({this.falhar = false});

  final bool falhar;
  int buscas = 0;

  @override
  Future<List<ServidorResumo>> buscarServidores() async {
    buscas++;
    if (falhar) throw ApiException('Erro ao buscar os servidores.');
    return _servidores;
  }
}

NovaReservaViewModel _viewModel(
  ServicesReserva service, {
  PerfilUsuario usuario = _usuario,
  ServicesUsuario? serviceUsuario,
}) => NovaReservaViewModel(
  horario: _horario,
  sala: _sala,
  usuario: usuario,
  service: service,
  serviceUsuario: serviceUsuario ?? ServicesUsuarioFalso(),
);

void main() {
  test('monta a reserva do horário com o usuário da sessão', () async {
    final service = ServicesReservaFalso();

    final resultado = await _viewModel(service).reservar(
      justificativa: '  Aula prática  ',
      observacoes: ' Projetor ',
    );

    final enviada = service.enviadas.single;
    expect(resultado!.reservas.single.id, 'r1');
    expect(enviada.sala.id, 'sA');
    expect(enviada.solicitante.id, 'u1');
    expect(enviada.responsavel.id, 'u1');
    expect(enviada.inicio, _horario.inicio);
    expect(enviada.fim, _horario.fim);
    expect(enviada.finalidade, 'Aula prática');
    expect(enviada.observacoes, 'Projetor');
  });

  test('justificativa vazia manda finalidade padrão e omite observações', () async {
    final service = ServicesReservaFalso();

    await _viewModel(service).reservar(justificativa: '   ', observacoes: '');

    final corpo = service.enviadas.single.toJson();
    expect(corpo['finalidade'], Reserva.finalidadeNaoInformada);
    expect(corpo.containsKey('observacoes'), isFalse);
  });

  test('falha devolve nulo e expõe a mensagem do backend', () async {
    final viewModel = _viewModel(ServicesReservaFalso(falhar: true));

    final resultado = await viewModel.reservar(
      justificativa: '',
      observacoes: '',
    );

    expect(resultado, isNull);
    expect(viewModel.mensagemErro, 'Sala já reservada neste horário.');
    expect(viewModel.isLoading, isFalse);
  });

  test('segundo toque durante o envio é ignorado', () async {
    final service = ServicesReservaFalso()..pendente = Completer<void>();
    final viewModel = _viewModel(service);

    final primeira = viewModel.reservar(justificativa: '', observacoes: '');
    final segunda = await viewModel.reservar(
      justificativa: '',
      observacoes: '',
    );

    expect(segunda, isNull);
    expect(viewModel.isLoading, isTrue);

    service.pendente!.complete();
    await primeira;

    expect(service.enviadas, hasLength(1));
    expect(viewModel.isLoading, isFalse);
  });

  group('responsável', () {
    test('professor não busca servidores e é o próprio responsável', () async {
      final service = ServicesReservaFalso();
      final servicoUsuario = ServicesUsuarioFalso();
      final viewModel = _viewModel(service, serviceUsuario: servicoUsuario);

      await viewModel.carregarServidores();
      await viewModel.reservar(justificativa: 'Aula', observacoes: '');

      expect(viewModel.exigeResponsavel, isFalse);
      expect(servicoUsuario.buscas, 0);
      expect(service.enviadas.single.responsavel.id, 'u1');
    });

    test('aluno carrega os servidores e envia o escolhido', () async {
      final service = ServicesReservaFalso();
      final viewModel = _viewModel(service, usuario: _aluno);

      await viewModel.carregarServidores();
      viewModel.selecionarResponsavel(_tecnico);
      await viewModel.reservar(justificativa: 'Estudo', observacoes: '');

      final enviada = service.enviadas.single;
      expect(viewModel.exigeResponsavel, isTrue);
      expect(viewModel.servidoresDo(Perfil.coordenador), [_coordenador]);
      expect(viewModel.servidoresDo(Perfil.professor), [_professor]);
      expect(viewModel.servidoresDo(Perfil.tecnico), [_tecnico]);
      expect(enviada.solicitante.id, 'a1');
      expect(enviada.responsavel.id, 's2');
      expect(enviada.toJson()['responsavelId'], 's2');
    });

    test('perfis de responsável seguem o perfil logado', () {
      final aluno = _viewModel(ServicesReservaFalso(), usuario: _aluno);
      final coordenador = _viewModel(
        ServicesReservaFalso(),
        usuario: _coordenadorLogado,
      );

      expect(aluno.perfisDeResponsavel, [
        Perfil.coordenador,
        Perfil.professor,
        Perfil.tecnico,
      ]);
      expect(coordenador.perfisDeResponsavel, [
        Perfil.professor,
        Perfil.tecnico,
      ]);
    });

    test('coordenador designa um professor como responsável', () async {
      final service = ServicesReservaFalso();
      final servicoUsuario = ServicesUsuarioFalso();
      final viewModel = _viewModel(
        service,
        usuario: _coordenadorLogado,
        serviceUsuario: servicoUsuario,
      );

      await viewModel.carregarServidores();
      viewModel.selecionarResponsavel(_professor);
      await viewModel.reservar(justificativa: 'Aula', observacoes: '');

      final enviada = service.enviadas.single;
      expect(viewModel.escolheResponsavel, isTrue);
      expect(viewModel.exigeResponsavel, isFalse);
      expect(servicoUsuario.buscas, 1);
      expect(enviada.solicitante.id, 'c1');
      expect(enviada.toJson()['responsavelId'], 's1');
    });

    test('coordenador sem escolha fica como o próprio responsável', () async {
      final service = ServicesReservaFalso();
      final viewModel = _viewModel(service, usuario: _coordenadorLogado);

      await viewModel.carregarServidores();
      viewModel
        ..selecionarResponsavel(_tecnico)
        ..selecionarResponsavel(null);
      await viewModel.reservar(justificativa: 'Aula', observacoes: '');

      expect(service.enviadas.single.toJson()['responsavelId'], 'c1');
    });

    test('aluno sem responsável não chama o service', () async {
      final service = ServicesReservaFalso();
      final viewModel = _viewModel(service, usuario: _aluno);

      final resultado = await viewModel.reservar(
        justificativa: 'Estudo',
        observacoes: '',
      );

      expect(resultado, isNull);
      expect(service.enviadas, isEmpty);
    });

    test('falha na busca fica no erro dos servidores, não no da tela', () async {
      final viewModel = _viewModel(
        ServicesReservaFalso(),
        usuario: _aluno,
        serviceUsuario: ServicesUsuarioFalso(falhar: true),
      );

      await viewModel.carregarServidores();

      expect(viewModel.mensagemErroServidores, 'Erro ao buscar os servidores.');
      expect(viewModel.mensagemErro, isNull);
      expect(viewModel.isCarregandoServidores, isFalse);
    });
  });
}
