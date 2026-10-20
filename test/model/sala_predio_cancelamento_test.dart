import 'package:flutter_test/flutter_test.dart';
import 'package:reserva_if/model/cancelamento/cancelamento.dart';
import 'package:reserva_if/model/predio/predio.dart';
import 'package:reserva_if/model/sala/sala.dart';

void main() {
  group('Sala', () {
    const json = {
      'id': 's1',
      'predioId': 'p1',
      'numSala': 3,
      'nomeSala': 'Lab. 03 - Redes',
      'andar': 1,
      'capacidade': 30,
      'tipo': 'LABORATORIO',
      'ativa': true,
      'recursoIds': <String>[],
    };

    test('fromJson lê nomeSala e ignora o que não modela', () {
      final sala = Sala.fromJson(json);

      expect(sala.id, 's1');
      expect(sala.nome, 'Lab. 03 - Redes');
      expect(sala.predioId, 'p1');
      expect(sala.capacidade, 30);
    });

    test('toJson grava nomeSala e omite id', () {
      expect(Sala.fromJson(json).toJson(), {
        'nomeSala': 'Lab. 03 - Redes',
        'predioId': 'p1',
        'capacidade': 30,
      });
    });

    test('capacidadeFormatada respeita singular e plural', () {
      const base = Sala(nome: 'Sala', predioId: 'p1', capacidade: 1);

      expect(base.capacidadeFormatada, '1 lugar');
      expect(base.copyWith(capacidade: 40).capacidadeFormatada, '40 lugares');
    });
  });

  group('Predio', () {
    test('ida e volta omite id e ignora endereco', () {
      final predio = Predio.fromJson({
        'id': 'p1',
        'nome': 'Bloco A',
        'endereco': {'rua': 'Av. Vitória', 'numero': 1729},
      });

      expect(predio.id, 'p1');
      expect(predio.toJson(), {'nome': 'Bloco A'});
      expect(predio.copyWith(nome: 'Bloco B').nome, 'Bloco B');
    });
  });

  group('Cancelamento', () {
    test('ida e volta omite id', () {
      final cancelamento = Cancelamento.fromJson({
        'id': 'c1',
        'reservaId': 'r1',
        'canceladorId': 'u1',
        'justificativa': 'Aula cancelada',
      });

      expect(cancelamento.id, 'c1');
      expect(cancelamento.toJson(), {
        'reservaId': 'r1',
        'canceladorId': 'u1',
        'justificativa': 'Aula cancelada',
      });
      expect(cancelamento.copyWith(justificativa: 'Feriado').reservaId, 'r1');
    });
  });
}
