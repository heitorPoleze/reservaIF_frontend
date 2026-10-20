import 'package:flutter_test/flutter_test.dart';
import 'package:reserva_if/model/predio/endereco.dart';
import 'package:reserva_if/model/predio/predio.dart';
import 'package:reserva_if/model/sala/sala.dart';

const _predioResumoJson = {
  'id': 'p1',
  'nome': 'Bloco A',
  'campusId': null,
  'setorId': null,
};

const _salaJson = {
  'id': 's1',
  'nome': 'Lab. 03 - Redes',
  'nomeSala': 'Lab. 03 - Redes',
  'capacidade': 30,
  'predioId': 'p1',
  'predio': _predioResumoJson,
  'ativa': true,
  'codigo': null,
  'numSala': 3,
  'andar': 1,
  'tipo': 'LABORATORIO',
};

const _enderecoJson = {
  'rua': 'Av. Vitória',
  'numero': 1729,
  'bairro': 'Jucutuquara',
  'cep': '29040-780',
};

const _predio = Predio(id: 'p1', nome: 'Bloco A');

void main() {
  group('Sala', () {
    test('fromJson lê nomeSala e o prédio embutido', () {
      final sala = Sala.fromJson(_salaJson);

      expect(sala.id, 's1');
      expect(sala.nome, 'Lab. 03 - Redes');
      expect(sala.capacidade, 30);
      expect(sala.predio.id, 'p1');
      expect(sala.predio.nome, 'Bloco A');
      expect(sala.predio.salas, isEmpty);
    });

    test('fromJson sem predio embutido lança', () {
      final semPredio = Map<String, dynamic>.from(_salaJson)..remove('predio');

      expect(() => Sala.fromJson(semPredio), throwsA(isA<TypeError>()));
    });

    test('fromJson aceita capacidade nula', () {
      final sala = Sala.fromJson({..._salaJson, 'capacidade': null});

      expect(sala.capacidade, isNull);
      expect(sala.capacidadeFormatada, 'Capacidade não informada');
    });

    test('toJson grava nomeSala e o predioId do objeto, omitindo id', () {
      expect(Sala.fromJson(_salaJson).toJson(), {
        'nomeSala': 'Lab. 03 - Redes',
        'predioId': 'p1',
        'capacidade': 30,
      });
      expect(
        const Sala(nome: 'Nova', predio: _predio).toJson().containsKey(
              'capacidade',
            ),
        isFalse,
      );
    });

    test('capacidadeFormatada respeita singular e plural', () {
      const base = Sala(nome: 'Sala', predio: _predio, capacidade: 1);

      expect(base.capacidadeFormatada, '1 lugar');
      expect(base.copyWith(capacidade: 40).capacidadeFormatada, '40 lugares');
    });
  });

  group('Predio', () {
    test('resumo lê endereco, nasce sem salas e grava endereco no toJson', () {
      final predio = Predio.fromJson({
        ..._predioResumoJson,
        'endereco': _enderecoJson,
      });

      expect(predio.id, 'p1');
      expect(predio.salas, isEmpty);
      expect(predio.endereco!.formatado, 'Av. Vitória, 1729 - Jucutuquara');
      expect(predio.toJson(), {'nome': 'Bloco A', 'endereco': _enderecoJson});
    });

    test('toJson omite endereco ausente e copyWith preserva o resto', () {
      final predio = Predio.fromJson(_predioResumoJson);

      expect(predio.endereco, isNull);
      expect(predio.toJson(), {'nome': 'Bloco A'});
      expect(predio.copyWith(nome: 'Bloco B').id, 'p1');
    });

    test('com salas, cada sala aponta para o prédio pai sem recursão', () {
      final predio = Predio.fromJson({
        ..._predioResumoJson,
        'endereco': null,
        'salas': [
          {
            'id': 's1',
            'nome': 'Lab. 03 - Redes',
            'nomeSala': 'Lab. 03 - Redes',
            'capacidade': 30,
            'predioId': 'p1',
            'ativa': true,
          },
          {
            'id': 's2',
            'nome': 'Sala 101',
            'nomeSala': 'Sala 101',
            'capacidade': null,
            'predioId': 'p1',
            'ativa': true,
          },
        ],
      });

      expect(predio.salas.map((sala) => sala.id), ['s1', 's2']);
      expect(predio.salas.first.predio.nome, 'Bloco A');
      expect(predio.salas.first.predio.salas, isEmpty);
      expect(predio.salas.last.capacidade, isNull);
      expect(() => predio.salas.add(predio.salas.first), throwsUnsupportedError);
    });
  });

  group('Endereco', () {
    test('ida e volta', () {
      final endereco = Endereco.fromJson(_enderecoJson);

      expect(endereco.cep, '29040-780');
      expect(endereco.toJson(), _enderecoJson);
      expect(Endereco.fromJsonOpcional(null), isNull);
    });
  });
}
