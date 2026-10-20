import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:reserva_if/model/reserva/frequencia.dart';
import 'package:reserva_if/model/reserva/reserva.dart';
import 'package:reserva_if/model/reserva/reserva_coordenador.dart';
import 'package:reserva_if/model/reserva/status_reserva.dart';

final _inicioUtc = DateTime.utc(2026, 10, 19, 17);

final _fimUtc = DateTime.utc(2026, 10, 19, 19);

Reserva _reserva({
  String? id,
  DateTime? inicio,
  DateTime? fim,
  String salaId = 's1',
  StatusReserva status = StatusReserva.aprovada,
  String? aprovadoPorId,
  String? observacoes,
  DateTime? criadoEm,
  DateTime? aprovadoEm,
}) =>
    Reserva(
      id: id,
      inicio: inicio ?? _inicioUtc.toLocal(),
      fim: fim ?? _fimUtc.toLocal(),
      salaId: salaId,
      finalidade: 'Aula de Flutter',
      status: status,
      solicitanteId: 'u1',
      aprovadoPorId: aprovadoPorId,
      observacoes: observacoes,
      criadoEm: criadoEm,
      aprovadoEm: aprovadoEm,
    );

const _json = {
  'id': 'r1',
  'inicio': '2026-10-19T17:00:00.000Z',
  'fim': '2026-10-19T19:00:00.000Z',
  'salaId': 's1',
  'finalidade': 'Aula de Flutter',
  'status': 'APROVADA',
  'solicitanteId': 'u1',
  'aprovadoPorId': 'c1',
  'criadoEm': '2026-10-18T12:00:00.000Z',
  'aprovadoEm': '2026-10-18T15:00:00.000Z',
};

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  group('serialização', () {
    test('toJson grava instantes em UTC e omite campos carimbados', () {
      final json = _reserva(
        id: 'r1',
        status: StatusReserva.aprovada,
        aprovadoPorId: 'c1',
        criadoEm: DateTime.now(),
        aprovadoEm: DateTime.now(),
      ).toJson();

      expect(json['inicio'], '2026-10-19T17:00:00.000Z');
      expect(json['fim'], '2026-10-19T19:00:00.000Z');
      expect(
        json.keys,
        unorderedEquals(
          ['inicio', 'fim', 'salaId', 'finalidade', 'solicitanteId'],
        ),
      );
    });

    test('toJson inclui observacoes só quando informadas', () {
      expect(_reserva().toJson().containsKey('observacoes'), isFalse);
      expect(
        _reserva(observacoes: 'Projetor').toJson()['observacoes'],
        'Projetor',
      );
    });

    test('fromJson lê instantes no fuso local', () {
      final lida = Reserva.fromJson(_json);

      expect(lida.inicio.isUtc, isFalse);
      expect(lida.inicio.toUtc(), _inicioUtc);
      expect(lida.fim.toUtc(), _fimUtc);
      expect(lida.status, StatusReserva.aprovada);
      expect(lida.aprovadoPorId, 'c1');
      expect(lida.aprovadoEm!.toUtc(), DateTime.utc(2026, 10, 18, 15));
      expect(lida.observacoes, isNull);
    });

    test('ida e volta preserva o período', () {
      final original = Reserva.fromJson(_json);
      final relida = Reserva.fromJson({
        ...original.toJson(),
        'status': 'PENDENTE_APROVACAO',
      });

      expect(relida.inicio, original.inicio);
      expect(relida.fim, original.fim);
      expect(relida.salaId, original.salaId);
    });

    test('status desconhecido lança', () {
      expect(
        () => Reserva.fromJson({..._json, 'status': 'Aprovada'}),
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

    test('emAndamento vale para aprovada e agendada dentro da janela', () {
      final agora = DateTime.now();
      final inicio = agora.subtract(const Duration(hours: 1));
      final fim = agora.add(const Duration(hours: 1));

      expect(_reserva(inicio: inicio, fim: fim).emAndamento, isTrue);
      expect(
        _reserva(inicio: inicio, fim: fim, status: StatusReserva.agendada)
            .emAndamento,
        isTrue,
      );
      expect(
        _reserva(inicio: inicio, fim: fim, status: StatusReserva.pendente)
            .emAndamento,
        isFalse,
      );
      expect(
        _reserva(inicio: inicio, fim: fim, status: StatusReserva.concluida)
            .emAndamento,
        isFalse,
      );
    });

    test('copyWith preserva o que não foi alterado', () {
      final copia = _reserva(id: 'r1').copyWith(finalidade: 'Reunião');

      expect(copia.id, 'r1');
      expect(copia.finalidade, 'Reunião');
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
        salaId: 's2',
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

  group('ReservaCoordenador', () {
    test('ida e volta com frequencia', () {
      final lida = ReservaCoordenador.fromJson({
        ..._json,
        'frequencia': 'SEMANAL',
      });

      expect(lida.frequencia, Frequencia.semanal);
      expect(lida.inicio.toUtc(), _inicioUtc);
      expect(lida.toJson()['frequencia'], 'SEMANAL');
      expect(lida.toJson().containsKey('id'), isFalse);
    });

    test('copyWith preserva o tipo', () {
      final original = ReservaCoordenador.fromJson({
        ..._json,
        'frequencia': 'MENSAL',
      });
      final copia = original.copyWith(finalidade: 'Colegiado');

      expect(copia, isA<ReservaCoordenador>());
      expect(copia.frequencia, Frequencia.mensal);
      expect(copia.finalidade, 'Colegiado');
    });

    test('frequencia ausente lança', () {
      expect(() => ReservaCoordenador.fromJson(_json), throwsArgumentError);
    });
  });
}
