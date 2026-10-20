import 'package:flutter_test/flutter_test.dart';
import 'package:reserva_if/model/usuario/credencial/tipo_entrada.dart';
import 'package:reserva_if/model/reserva/frequencia.dart';
import 'package:reserva_if/model/reserva/status_reserva.dart';
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

  group('Frequencia e TipoEntrada', () {
    test('fazem ida e volta', () {
      for (final frequencia in Frequencia.values) {
        expect(Frequencia.fromJson(frequencia.toJson()), frequencia);
      }
      for (final tipo in TipoEntrada.values) {
        expect(TipoEntrada.fromJson(tipo.toJson()), tipo);
      }
    });

    test('falham alto em valor desconhecido', () {
      expect(() => Frequencia.fromJson('DIARIA'), throwsArgumentError);
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
