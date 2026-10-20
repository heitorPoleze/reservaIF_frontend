import 'package:flutter_test/flutter_test.dart';
import 'package:reserva_if/model/usuario/credencial/tipo_entrada.dart';
import 'package:reserva_if/model/reserva/dia_semana.dart';
import 'package:reserva_if/model/reserva/status_reserva.dart';
import 'package:reserva_if/model/reserva/tipo_recorrencia.dart';
import 'package:reserva_if/model/usuario/perfil.dart';

void main() {
  group('StatusReserva', () {
    test('espelha o Prisma e faz ida e volta', () {
      for (final status in StatusReserva.values) {
        expect(StatusReserva.fromJson(status.toJson()), status);
      }
      expect(StatusReserva.values, hasLength(6));
      expect(StatusReserva.pendente.toJson(), 'PENDENTE_APROVACAO');
      expect(StatusReserva.aprovada.toJson(), 'APROVADA');
      expect(StatusReserva.agendada.toJson(), 'AGENDADO');
      expect(StatusReserva.concluida.toJson(), 'CONCLUIDA');
    });

    test('rotulo em pt-BR concorda com reserva', () {
      expect(StatusReserva.pendente.rotulo, 'Em Análise');
      expect(StatusReserva.aprovada.rotulo, 'Aprovada');
      expect(StatusReserva.agendada.rotulo, 'Agendada');
      expect(StatusReserva.concluida.rotulo, 'Concluída');
    });

    test('falha alto em valor desconhecido', () {
      expect(() => StatusReserva.fromJson('Aprovada'), throwsArgumentError);
      expect(() => StatusReserva.fromJson('PENDENTE'), throwsArgumentError);
      expect(() => StatusReserva.fromJson(null), throwsArgumentError);
    });

    test('ocupaSala só para aprovada e agendada, como o backend', () {
      expect(StatusReserva.aprovada.ocupaSala, isTrue);
      expect(StatusReserva.agendada.ocupaSala, isTrue);
      expect(StatusReserva.pendente.ocupaSala, isFalse);
      expect(StatusReserva.rejeitada.ocupaSala, isFalse);
      expect(StatusReserva.cancelada.ocupaSala, isFalse);
      expect(StatusReserva.concluida.ocupaSala, isFalse);
    });

    test('terminal para rejeitada, cancelada e concluida', () {
      expect(StatusReserva.rejeitada.terminal, isTrue);
      expect(StatusReserva.cancelada.terminal, isTrue);
      expect(StatusReserva.concluida.terminal, isTrue);
      expect(StatusReserva.pendente.terminal, isFalse);
      expect(StatusReserva.aprovada.terminal, isFalse);
      expect(StatusReserva.agendada.terminal, isFalse);
    });
  });

  group('Perfil', () {
    test('espelha o Prisma e faz ida e volta', () {
      for (final perfil in Perfil.values) {
        expect(Perfil.fromJson(perfil.toJson()), perfil);
      }
      expect(Perfil.coordenador.toJson(), 'COORDENADOR');
      expect(Perfil.tecnico.rotulo, 'Técnico');
    });

    test('falha alto em valor desconhecido', () {
      expect(() => Perfil.fromJson('professor'), throwsArgumentError);
    });
  });

  group('TipoRecorrencia e DiaSemana', () {
    test('espelham o Prisma e fazem ida e volta', () {
      for (final tipo in TipoRecorrencia.values) {
        expect(TipoRecorrencia.fromJson(tipo.toJson()), tipo);
      }
      for (final dia in DiaSemana.values) {
        expect(DiaSemana.fromJson(dia.toJson()), dia);
      }
      expect(TipoRecorrencia.values, hasLength(5));
      expect(TipoRecorrencia.semestral.toJson(), 'SEMESTRAL');
      expect(DiaSemana.terca.toJson(), 'TERCA');
    });

    test('falham alto em valor desconhecido', () {
      expect(
        () => TipoRecorrencia.fromJson('QUINZENAL'),
        throwsArgumentError,
      );
      expect(() => DiaSemana.fromJson('SEGUNDA_FEIRA'), throwsArgumentError);
    });

    test('só semanal exige dataFim', () {
      expect(TipoRecorrencia.semanal.exigeDataFim, isTrue);
      expect(TipoRecorrencia.mensal.exigeDataFim, isFalse);
      expect(TipoRecorrencia.anual.exigeDataFim, isFalse);
    });

    test('DiaSemana.de mapeia o weekday do Dart', () {
      expect(DiaSemana.de(DateTime(2026, 10, 19)), DiaSemana.segunda);
      expect(DiaSemana.de(DateTime(2026, 10, 18)), DiaSemana.domingo);
      expect(DiaSemana.de(DateTime(2026, 10, 24)), DiaSemana.sabado);
    });
  });

  group('TipoEntrada', () {
    test('faz ida e volta', () {
      for (final tipo in TipoEntrada.values) {
        expect(TipoEntrada.fromJson(tipo.toJson()), tipo);
      }
    });

    test('falha alto em valor desconhecido', () {
      expect(() => TipoEntrada.fromJson('CPF'), throwsArgumentError);
      expect(() => TipoEntrada.fromJson('EMAIL'), throwsArgumentError);
    });

    test('TipoEntrada.inferir distingue SIAPE de matrícula', () {
      expect(TipoEntrada.inferir('1234567'), TipoEntrada.siape);
      expect(TipoEntrada.inferir('20241tsi0063'), TipoEntrada.matricula);
      expect(TipoEntrada.inferir('a@ifes.edu.br'), isNull);
    });
  });
}
