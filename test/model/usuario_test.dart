import 'package:flutter_test/flutter_test.dart';
import 'package:reserva_if/model/usuario/aluno.dart';
import 'package:reserva_if/model/usuario/coordenacao.dart';
import 'package:reserva_if/model/usuario/perfil.dart';
import 'package:reserva_if/model/usuario/professor.dart';
import 'package:reserva_if/model/usuario/tecnico.dart';
import 'package:reserva_if/model/usuario/usuario.dart';
import 'package:reserva_if/model/usuario/usuario_resumo.dart';

const _comum = {
  'id': 'u1',
  'nome': 'Ana Souza',
  'email': 'ana.souza@ifes.edu.br',
};

void main() {
  group('Usuario.fromJson despacha pelo perfil', () {
    test('ALUNO vira Aluno', () {
      final usuario = Usuario.fromJson({
        ..._comum,
        'perfil': 'ALUNO',
        'matricula': '20261SI001',
        'curso': 'Sistemas de Informação',
      });

      expect(usuario, isA<Aluno>());
      expect((usuario as Aluno).matricula, '20261SI001');
      expect(usuario.perfil, Perfil.aluno);
    });

    test('aceita JSON sem email', () {
      final usuario = Usuario.fromJson({
        'id': 'u2',
        'nome': 'Bia',
        'perfil': 'ALUNO',
        'matricula': '2026',
        'curso': 'SI',
      });

      expect(usuario.email, isNull);
    });

    test('TECNICO e PROFESSOR viram servidores distintos', () {
      final servidor = {..._comum, 'departamento': 'DCC', 'siape': '1234567'};

      expect(Usuario.fromJson({...servidor, 'perfil': 'TECNICO'}), isA<Tecnico>());
      expect(
        Usuario.fromJson({...servidor, 'perfil': 'PROFESSOR'}),
        isA<Professor>(),
      );
    });

    test('COORDENADOR vira Coordenacao sem coordenador quando ausente', () {
      final usuario = Usuario.fromJson({
        ..._comum,
        'perfil': 'COORDENADOR',
        'departamento': 'DCC',
      });

      expect(usuario, isA<Coordenacao>());
      expect((usuario as Coordenacao).coordenador, isNull);
      expect(usuario.toJson().containsKey('coordenadorId'), isFalse);
    });

    test('COORDENADOR lê o coordenador embutido e grava só o id dele', () {
      final usuario = Usuario.fromJson({
        ..._comum,
        'perfil': 'COORDENADOR',
        'departamento': 'DCC',
        'coordenadorId': 'u9',
        'coordenador': {'id': 'u9', 'nome': 'Carlos Lima'},
      }) as Coordenacao;

      expect(usuario.coordenador!.nome, 'Carlos Lima');
      expect(usuario.toJson()['coordenadorId'], 'u9');
      expect(usuario.toJson().containsKey('coordenador'), isFalse);
    });

    test('perfil desconhecido lança', () {
      expect(
        () => Usuario.fromJson({..._comum, 'perfil': 'VISITANTE'}),
        throwsArgumentError,
      );
    });
  });

  group('UsuarioResumo', () {
    test('lê id e nome e ignora o resto', () {
      final resumo = UsuarioResumo.fromJson({
        'id': 'u1',
        'nome': 'Ana Souza',
        'emailInstitucional': 'ana@ifes.edu.br',
      });

      expect(resumo.id, 'u1');
      expect(resumo.nome, 'Ana Souza');
    });

    test('fromJsonOpcional devolve nulo para nulo e lança sem nome', () {
      expect(UsuarioResumo.fromJsonOpcional(null), isNull);
      expect(
        () => UsuarioResumo.fromJsonOpcional({'id': 'u1'}),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('toJson', () {
    const professor = Professor(
      id: 'u1',
      nome: 'Ana Souza',
      email: 'ana.souza@ifes.edu.br',
      departamento: 'DCC',
      siape: '1234567',
    );

    test('omite id e inclui o perfil', () {
      final json = professor.toJson();

      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('telefone'), isFalse);
      expect(json['perfil'], 'PROFESSOR');
      expect(json['siape'], '1234567');
    });

    test('omite email quando ausente', () {
      const semEmail = Aluno(nome: 'Bia', matricula: '2026', curso: 'SI');

      expect(semEmail.toJson().containsKey('email'), isFalse);
    });

    test('inclui telefone quando informado', () {
      expect(professor.copyWith(telefone: '27999990000').toJson()['telefone'],
          '27999990000');
    });

    test('Aluno acrescenta matricula e curso', () {
      const aluno = Aluno(
        nome: 'Bia',
        email: 'bia@ifes.edu.br',
        matricula: '2026',
        curso: 'SI',
      );

      expect(aluno.toJson(), {
        'nome': 'Bia',
        'email': 'bia@ifes.edu.br',
        'perfil': 'ALUNO',
        'matricula': '2026',
        'curso': 'SI',
      });
    });
  });

  test('podeAprovar só para coordenação', () {
    const coordenacao = Coordenacao(
      nome: 'Coord',
      email: 'coord@ifes.edu.br',
      departamento: 'DCC',
    );
    const tecnico = Tecnico(
      nome: 'Téc',
      email: 'tec@ifes.edu.br',
      departamento: 'DCC',
      siape: '1',
    );

    expect(coordenacao.podeAprovar, isTrue);
    expect(tecnico.podeAprovar, isFalse);
  });

  test('copyWith preserva tipo, perfil e campos não alterados', () {
    const tecnico = Tecnico(
      id: 'u2',
      nome: 'Téc',
      email: 'tec@ifes.edu.br',
      departamento: 'DCC',
      siape: '7654321',
    );

    final copia = tecnico.copyWith(nome: 'Técnico Novo');

    expect(copia, isA<Tecnico>());
    expect(copia.perfil, Perfil.tecnico);
    expect(copia.nome, 'Técnico Novo');
    expect(copia.id, 'u2');
    expect(copia.siape, '7654321');
  });
}
