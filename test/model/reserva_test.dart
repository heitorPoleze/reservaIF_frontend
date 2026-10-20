import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:reserva_if/model/predio/predio.dart';
import 'package:reserva_if/model/reserva/dia_semana.dart';
import 'package:reserva_if/model/reserva/acao_sobre_reserva.dart';
import 'package:reserva_if/model/reserva/regra_recorrencia.dart';
import 'package:reserva_if/model/reserva/reserva.dart';
import 'package:reserva_if/model/reserva/reserva_coordenador.dart';
import 'package:reserva_if/model/reserva/resultado_criacao_reserva.dart';
import 'package:reserva_if/model/reserva/serie_recorrencia.dart';
import 'package:reserva_if/model/reserva/status_reserva.dart';
import 'package:reserva_if/model/reserva/tipo_recorrencia.dart';
import 'package:reserva_if/model/sala/sala.dart';
import 'package:reserva_if/model/usuario/perfil.dart';
import 'package:reserva_if/model/usuario/perfil_usuario.dart';
import 'package:reserva_if/model/usuario/tipo_credencial.dart';
import 'package:reserva_if/model/usuario/usuario_resumo.dart';

final _inicioUtc = DateTime.utc(2026, 10, 19, 17);

final _fimUtc = DateTime.utc(2026, 10, 19, 19);

const _predio = Predio(id: 'p1', nome: 'Bloco A');

const _sala = Sala(id: 's1', nome: 'Lab. 03', predio: _predio, capacidade: 30);

const _outraSala = Sala(id: 's2', nome: 'Sala 101', predio: _predio);

const _aluna = UsuarioResumo(
  id: 'u1',
  nome: 'Ana Souza',
  tipoCredencial: TipoCredencial.matriculaAluno,
);

const _professor = UsuarioResumo(
  id: 'u2',
  nome: 'Paulo Lima',
  tipoCredencial: TipoCredencial.siapeDocente,
);

const _coordenador = UsuarioResumo(id: 'c1', nome: 'Carla Dias');

const _predioJson = {'id': 'p1', 'nome': 'Bloco A'};

const _salaJson = {
  'id': 's1',
  'nome': 'Lab. 03',
  'nomeSala': 'Lab. 03',
  'capacidade': 30,
  'predioId': 'p1',
  'predio': _predioJson,
  'ativa': true,
};

const _alunaJson = {'id': 'u1', 'nome': 'Ana Souza'};

const _coordenadorJson = {'id': 'c1', 'nome': 'Carla Dias'};

const _serieJson = {
  'id': 'sr1',
  'criadoPorId': 'c1',
  'tipoRecorrencia': 'SEMANAL',
  'dataInicio': '2026-10-19T00:00:00.000Z',
  'dataFim': '2026-12-18T00:00:00.000Z',
  'diasSemana': ['SEGUNDA', 'QUARTA'],
  'criadoEm': '2026-10-18T12:00:00.000Z',
};

const _json = {
  'id': 'r1',
  'salaId': 's1',
  'sala': _salaJson,
  'solicitanteId': 'u1',
  'solicitante': _alunaJson,
  'responsavelId': 'u1',
  'responsavel': _alunaJson,
  'analisadoPorId': 'c1',
  'analisadoPor': _coordenadorJson,
  'serieRecorrenciaId': null,
  'serieRecorrencia': null,
  'tipoRecorrencia': 'UNICA',
  'dataHoraInicio': '2026-10-19T17:00:00.000Z',
  'dataHoraFim': '2026-10-19T19:00:00.000Z',
  'finalidade': 'Aula de Flutter',
  'observacoes': null,
  'status': 'APROVADA',
  'motivoRejeicao': null,
  'cancelamento': null,
  'criadoEm': '2026-10-18T12:00:00.000Z',
  'aceitoPeloResponsavelEm': null,
  'analisadoEm': '2026-10-18T15:00:00.000Z',
  'diaDaSemana': 'SEGUNDA',
};

Reserva _reserva({
  String? id,
  DateTime? inicio,
  DateTime? fim,
  Sala sala = _sala,
  UsuarioResumo solicitante = _aluna,
  UsuarioResumo responsavel = _aluna,
  StatusReserva status = StatusReserva.aprovada,
  String? observacoes,
  DateTime? aceitoPeloResponsavelEm,
}) => Reserva(
  id: id,
  sala: sala,
  solicitante: solicitante,
  responsavel: responsavel,
  inicio: inicio ?? _inicioUtc.toLocal(),
  fim: fim ?? _fimUtc.toLocal(),
  finalidade: 'Aula de Flutter',
  observacoes: observacoes,
  status: status,
  aceitoPeloResponsavelEm: aceitoPeloResponsavelEm,
);

PerfilUsuario _usuario(String uuid, Perfil perfil) => PerfilUsuario(
  uuid: uuid,
  nome: 'Usuário $uuid',
  email: '$uuid@ifes.edu.br',
  perfil: perfil,
  tipoCredencial: TipoCredencial.siapeDocente,
  identificador: '1234567',
  ativo: true,
);

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  group('serialização', () {
    test(
      'toJson manda só o payload de criação, com ids tirados dos objetos',
      () {
        final json = _reserva(id: 'r1').toJson();

        expect(json['salaId'], 's1');
        expect(json['responsavelId'], 'u1');
        expect(json['dataHoraInicio'], '2026-10-19T17:00:00.000Z');
        expect(json['dataHoraFim'], '2026-10-19T19:00:00.000Z');
        expect(
          json.keys,
          unorderedEquals([
            'salaId',
            'responsavelId',
            'dataHoraInicio',
            'dataHoraFim',
            'finalidade',
          ]),
        );
      },
    );

    test('toJson inclui observacoes só quando informadas', () {
      expect(_reserva().toJson().containsKey('observacoes'), isFalse);
      expect(
        _reserva(observacoes: 'Projetor').toJson()['observacoes'],
        'Projetor',
      );
    });

    test('fromJson lê as associações embutidas e instantes no fuso local', () {
      final lida = Reserva.fromJson(_json);

      expect(lida.inicio.isUtc, isFalse);
      expect(lida.inicio.toUtc(), _inicioUtc);
      expect(lida.fim.toUtc(), _fimUtc);
      expect(lida.sala.id, 's1');
      expect(lida.sala.nome, 'Lab. 03');
      expect(lida.sala.predio.nome, 'Bloco A');
      expect(lida.solicitante.nome, 'Ana Souza');
      expect(lida.responsavel.id, 'u1');
      expect(lida.analisadoPor!.id, 'c1');
      expect(lida.analisadoEm!.toUtc(), DateTime.utc(2026, 10, 18, 15));
      expect(lida.status, StatusReserva.aprovada);
      expect(lida.tipoRecorrencia, TipoRecorrencia.unica);
      expect(lida.serieRecorrencia, isNull);
      expect(lida.cancelamento, isNull);
      expect(lida.observacoes, isNull);
      expect(lida.motivoRejeicao, isNull);
    });

    test('fromJson sem objeto embutido lança em vez de cair no id', () {
      for (final chave in ['sala', 'solicitante', 'responsavel']) {
        final semObjeto = Map<String, dynamic>.from(_json)..remove(chave);

        expect(
          () => Reserva.fromJson(semObjeto),
          throwsA(isA<TypeError>()),
          reason: chave,
        );
      }
    });

    test('fromJson lê cancelamento embutido com o id de quem cancelou', () {
      final lida = Reserva.fromJson({
        ..._json,
        'status': 'CANCELADA',
        'cancelamento': {
          'canceladoPorId': 'u1',
          'justificativa': 'Feriado',
          'canceladoEm': '2026-10-19T10:00:00.000Z',
        },
      });

      expect(lida.status, StatusReserva.cancelada);
      expect(lida.cancelamento!.canceladoPorId, 'u1');
      expect(lida.cancelamento!.justificativa, 'Feriado');
      expect(
        lida.cancelamento!.canceladoEm.toUtc(),
        DateTime.utc(2026, 10, 19, 10),
      );
    });

    test('fromJson lê rejeição e série recorrente embutida', () {
      final lida = Reserva.fromJson({
        ..._json,
        'status': 'REJEITADA',
        'motivoRejeicao': 'Sala em manutenção',
        'tipoRecorrencia': 'SEMANAL',
        'serieRecorrenciaId': 'sr1',
        'serieRecorrencia': _serieJson,
      });

      expect(lida.motivoRejeicao, 'Sala em manutenção');
      expect(lida.recorrente, isTrue);
      expect(lida.serieRecorrencia!.id, 'sr1');
    });

    test('ida e volta preserva o período', () {
      final original = Reserva.fromJson(_json);
      final relida = Reserva.fromJson({..._json, ...original.toJson()});

      expect(relida.inicio, original.inicio);
      expect(relida.fim, original.fim);
      expect(relida.sala.id, original.sala.id);
    });

    test('status ou tipoRecorrencia desconhecidos lançam', () {
      expect(
        () => Reserva.fromJson({..._json, 'status': 'Aprovada'}),
        throwsArgumentError,
      );
      expect(
        () => Reserva.fromJson({..._json, 'tipoRecorrencia': 'QUINZENAL'}),
        throwsArgumentError,
      );
    });
  });

  group('regras de domínio', () {
    test('fim igual ou anterior ao início lança', () {
      final inicio = DateTime(2026, 10, 19, 14);

      expect(() => _reserva(inicio: inicio, fim: inicio), throwsArgumentError);
      expect(
        () => _reserva(
          inicio: inicio,
          fim: inicio.subtract(const Duration(hours: 1)),
        ),
        throwsArgumentError,
      );
    });

    test('sala sem id lança', () {
      expect(
        () => _reserva(
          sala: const Sala(nome: 'Nova', predio: _predio),
        ),
        throwsArgumentError,
      );
    });

    test('duracao é a diferença entre fim e início', () {
      expect(_reserva().duracao, const Duration(hours: 2));
    });

    test('diaDaSemana e periodoFormatado usam o horário local', () {
      final reserva = _reserva(
        inicio: DateTime(2026, 10, 19, 14),
        fim: DateTime(2026, 10, 19, 16),
      );

      expect(reserva.diaDaSemana, 'Segunda-feira');
      expect(reserva.periodoFormatado, '19/10/2026, 14:00 às 16:00');
    });

    test('delegada quando o responsável não é o solicitante', () {
      expect(_reserva().delegada, isFalse);
      expect(_reserva(responsavel: _professor).delegada, isTrue);
    });

    test(
      'aguardandoAceiteDoResponsavel só em análise, delegada e sem aceite',
      () {
        final delegada = _reserva(
          responsavel: _professor,
          status: StatusReserva.pendente,
        );

        expect(delegada.aguardandoAceiteDoResponsavel, isTrue);
        expect(
          delegada
              .copyWith(aceitoPeloResponsavelEm: DateTime.now())
              .aguardandoAceiteDoResponsavel,
          isFalse,
        );
        expect(
          delegada
              .copyWith(status: StatusReserva.aprovada)
              .aguardandoAceiteDoResponsavel,
          isFalse,
        );
        expect(
          _reserva(
            status: StatusReserva.pendente,
          ).aguardandoAceiteDoResponsavel,
          isFalse,
        );
      },
    );

    test('emAndamento vale para aprovada e agendada dentro da janela', () {
      final agora = DateTime.now();
      final inicio = agora.subtract(const Duration(hours: 1));
      final fim = agora.add(const Duration(hours: 1));

      expect(_reserva(inicio: inicio, fim: fim).emAndamento, isTrue);
      expect(
        _reserva(
          inicio: inicio,
          fim: fim,
          status: StatusReserva.agendada,
        ).emAndamento,
        isTrue,
      );
      expect(
        _reserva(
          inicio: inicio,
          fim: fim,
          status: StatusReserva.pendente,
        ).emAndamento,
        isFalse,
      );
      expect(
        _reserva(
          inicio: inicio,
          fim: fim,
          status: StatusReserva.concluida,
        ).emAndamento,
        isFalse,
      );
    });

    test('copyWith preserva o que não foi alterado', () {
      final copia = _reserva(id: 'r1').copyWith(finalidade: 'Reunião');

      expect(copia.id, 'r1');
      expect(copia.finalidade, 'Reunião');
      expect(copia.sala, same(_sala));
      expect(copia.inicio, _inicioUtc.toLocal());
    });
  });

  group('conflitaCom', () {
    final base = _reserva(
      inicio: DateTime(2026, 10, 19, 14),
      fim: DateTime(2026, 10, 19, 16),
    );

    test('sobreposição parcial conflita nos dois sentidos', () {
      final outra = _reserva(
        inicio: DateTime(2026, 10, 19, 15),
        fim: DateTime(2026, 10, 19, 17),
      );

      expect(base.conflitaCom(outra), isTrue);
      expect(outra.conflitaCom(base), isTrue);
    });

    test('reserva encostada não conflita', () {
      final seguinte = _reserva(
        inicio: DateTime(2026, 10, 19, 16),
        fim: DateTime(2026, 10, 19, 18),
      );

      expect(base.conflitaCom(seguinte), isFalse);
    });

    test('sala diferente não conflita', () {
      final outraSala = _reserva(
        inicio: DateTime(2026, 10, 19, 14),
        fim: DateTime(2026, 10, 19, 16),
        sala: _outraSala,
      );

      expect(base.conflitaCom(outraSala), isFalse);
    });

    test('reserva em análise não ocupa a sala', () {
      final pendente = _reserva(
        inicio: DateTime(2026, 10, 19, 14),
        fim: DateTime(2026, 10, 19, 16),
        status: StatusReserva.pendente,
      );

      expect(base.conflitaCom(pendente), isFalse);
      expect(pendente.conflitaCom(base), isFalse);
    });

    test('reserva agendada ocupa a sala', () {
      final agendada = _reserva(
        inicio: DateTime(2026, 10, 19, 15),
        fim: DateTime(2026, 10, 19, 17),
        status: StatusReserva.agendada,
      );

      expect(base.conflitaCom(agendada), isTrue);
    });

    test('reserva cancelada não ocupa a sala', () {
      final cancelada = _reserva(
        inicio: DateTime(2026, 10, 19, 14),
        fim: DateTime(2026, 10, 19, 16),
        status: StatusReserva.cancelada,
      );

      expect(base.conflitaCom(cancelada), isFalse);
      expect(cancelada.conflitaCom(base), isFalse);
    });
  });

  group('SerieRecorrencia', () {
    test('lê datas civis sem deslocar o dia e os dias da semana', () {
      final serie = SerieRecorrencia.fromJson(_serieJson);

      expect(serie.tipoRecorrencia, TipoRecorrencia.semanal);
      expect(serie.periodoFormatado, '19/10/2026 a 18/12/2026');
      expect(serie.diasSemana, [DiaSemana.segunda, DiaSemana.quarta]);
      expect(serie.criadoEm.toUtc(), DateTime.utc(2026, 10, 18, 12));
    });

    test('fromJsonOpcional devolve nulo para nulo', () {
      expect(SerieRecorrencia.fromJsonOpcional(null), isNull);
    });

    test('série embutida na reserva, sem criadoPorId, é lida', () {
      final embutida = Map<String, dynamic>.from(_serieJson)
        ..remove('criadoPorId');

      expect(SerieRecorrencia.fromJson(embutida).id, 'sr1');
    });
  });

  group('ResultadoCriacaoReserva', () {
    test('lê as reservas criadas sem série', () {
      final resultado = ResultadoCriacaoReserva.fromJson({
        'serieRecorrencia': null,
        'reservas': [_json],
      });

      expect(resultado.serieRecorrencia, isNull);
      expect(resultado.reservas.single.id, 'r1');
      expect(resultado.aguardaAprovacao, isFalse);
      expect(resultado.mensagem, 'Reserva confirmada.');
    });

    test('lê a série recorrente quando informada', () {
      final resultado = ResultadoCriacaoReserva.fromJson({
        'serieRecorrencia': _serieJson,
        'reservas': [_json],
      });

      expect(resultado.serieRecorrencia!.id, 'sr1');
    });

    test('série confirmada informa quantas reservas nasceram', () {
      final resultado = ResultadoCriacaoReserva.fromJson({
        'serieRecorrencia': _serieJson,
        'reservas': [
          {..._json, 'status': 'APROVADA'},
          {..._json, 'id': 'r2', 'status': 'APROVADA'},
        ],
      });

      expect(resultado.mensagem, '2 reservas confirmadas.');
    });

    test('reserva em análise aguarda aprovação', () {
      final resultado = ResultadoCriacaoReserva.fromJson({
        'serieRecorrencia': null,
        'reservas': [
          {..._json, 'status': 'PENDENTE_APROVACAO'},
        ],
      });

      expect(resultado.aguardaAprovacao, isTrue);
      expect(resultado.mensagem, 'Solicitação enviada para aprovação.');
    });

    test('reserva sem sala embutida lança', () {
      final semSala = Map<String, dynamic>.from(_json)..remove('sala');

      expect(
        () => ResultadoCriacaoReserva.fromJson({
          'serieRecorrencia': null,
          'reservas': [semSala],
        }),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('RegraRecorrencia', () {
    test('recusa tipo única', () {
      expect(
        () => RegraRecorrencia.criar(tipo: TipoRecorrencia.unica),
        throwsArgumentError,
      );
    });

    test('semanal exige dataFim e ao menos um dia', () {
      expect(
        () => RegraRecorrencia.criar(
          tipo: TipoRecorrencia.semanal,
          diasSemana: const [DiaSemana.segunda],
        ),
        throwsArgumentError,
      );
      expect(
        () => RegraRecorrencia.criar(
          tipo: TipoRecorrencia.semanal,
          dataFim: DateTime(2026, 12, 18),
        ),
        throwsArgumentError,
      );
    });

    test('semanal grava dataFim civil e dias sem repetição', () {
      final regra = RegraRecorrencia.criar(
        tipo: TipoRecorrencia.semanal,
        dataFim: DateTime(2026, 12, 18, 23, 30),
        diasSemana: const [
          DiaSemana.segunda,
          DiaSemana.quarta,
          DiaSemana.segunda,
        ],
      );

      expect(regra.toJson(), {
        'tipo': 'SEMANAL',
        'dataFim': '2026-12-18',
        'diasSemana': ['SEGUNDA', 'QUARTA'],
      });
    });

    test('mensal sem dataFim nem dias manda só o tipo', () {
      expect(RegraRecorrencia.criar(tipo: TipoRecorrencia.mensal).toJson(), {
        'tipo': 'MENSAL',
      });
    });
  });

  group('ReservaCoordenador', () {
    final regra = RegraRecorrencia.criar(
      tipo: TipoRecorrencia.semanal,
      dataFim: DateTime(2026, 12, 18),
      diasSemana: const [DiaSemana.segunda],
    );

    ReservaCoordenador reservaCoordenador() => ReservaCoordenador(
      sala: _sala,
      solicitante: _coordenador,
      responsavel: _coordenador,
      inicio: _inicioUtc.toLocal(),
      fim: _fimUtc.toLocal(),
      finalidade: 'Colegiado',
      recorrencia: regra,
    );

    test('deriva tipoRecorrencia da regra e manda recorrencia no toJson', () {
      final reserva = reservaCoordenador();

      expect(reserva.tipoRecorrencia, TipoRecorrencia.semanal);
      expect(reserva.recorrente, isTrue);
      expect(reserva.toJson()['recorrencia'], regra.toJson());
      expect(reserva.toJson()['salaId'], 's1');
      expect(reserva.toJson()['dataHoraInicio'], '2026-10-19T17:00:00.000Z');
    });

    test('copyWith preserva o tipo e a regra', () {
      final copia = reservaCoordenador().copyWith(finalidade: 'Reunião');

      expect(copia, isA<ReservaCoordenador>());
      expect(copia.recorrencia, same(regra));
      expect(copia.finalidade, 'Reunião');
    });
  });

  group('acaoDisponivelPara', () {
    final antes = _inicioUtc.toLocal().subtract(const Duration(hours: 1));

    AcaoSobreReserva? modo(
      Reserva reserva,
      PerfilUsuario usuario, {
      DateTime? agora,
    }) => reserva.acaoDisponivelPara(usuario, agora: agora ?? antes);

    test('o solicitante cancela a própria reserva futura', () {
      expect(
        modo(_reserva(), _usuario('u1', Perfil.aluno)),
        AcaoSobreReserva.cancelarReserva,
      );
    });

    test('o coordenador cancela reserva de outra pessoa', () {
      expect(
        modo(_reserva(), _usuario('c1', Perfil.coordenador)),
        AcaoSobreReserva.cancelarReserva,
      );
    });

    test('o professor cancela a própria reserva', () {
      expect(
        modo(
          _reserva(solicitante: _professor, responsavel: _professor),
          _usuario('u2', Perfil.professor),
        ),
        AcaoSobreReserva.cancelarReserva,
      );
    });

    test('o professor solicita o horário de reserva de aluno', () {
      expect(
        modo(_reserva(), _usuario('u9', Perfil.professor)),
        AcaoSobreReserva.solicitarHorario,
      );
    });

    test('o professor não age sobre reserva de outro servidor', () {
      expect(
        modo(
          _reserva(solicitante: _professor, responsavel: _professor),
          _usuario('u9', Perfil.professor),
        ),
        isNull,
      );
    });

    test('técnico e aluno não agem sobre reserva de outro aluno', () {
      expect(modo(_reserva(), _usuario('t1', Perfil.tecnico)), isNull);
      expect(modo(_reserva(), _usuario('u3', Perfil.aluno)), isNull);
    });

    test('reserva terminal não se cancela de novo', () {
      expect(
        modo(
          _reserva(status: StatusReserva.cancelada),
          _usuario('u9', Perfil.professor),
        ),
        isNull,
      );
    });

    test('reserva que já começou não se cancela nem se solicita', () {
      final inicio = _inicioUtc.toLocal();

      expect(
        modo(_reserva(), _usuario('c1', Perfil.coordenador), agora: inicio),
        isNull,
      );
      expect(
        modo(_reserva(), _usuario('u9', Perfil.professor), agora: inicio),
        isNull,
      );
    });
  });

  group('analisavelPor', () {
    test('o responsável designado analisa a reserva pendente delegada', () {
      expect(
        _reserva(
          responsavel: _professor,
          status: StatusReserva.pendente,
        ).analisavelPor(_usuario('u2', Perfil.professor)),
        isTrue,
      );
    });

    test('quem não é o responsável não analisa', () {
      expect(
        _reserva(
          responsavel: _professor,
          status: StatusReserva.pendente,
        ).analisavelPor(_usuario('c1', Perfil.coordenador)),
        isFalse,
      );
    });

    test('reserva fora de análise não se analisa', () {
      expect(
        _reserva(
          responsavel: _professor,
        ).analisavelPor(_usuario('u2', Perfil.professor)),
        isFalse,
      );
    });

    test('o próprio solicitante não analisa a reserva que pediu', () {
      expect(
        _reserva(
          status: StatusReserva.pendente,
        ).analisavelPor(_usuario('u1', Perfil.aluno)),
        isFalse,
      );
    });
  });
}
