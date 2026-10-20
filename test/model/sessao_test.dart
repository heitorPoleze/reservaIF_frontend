import 'package:flutter_test/flutter_test.dart';
import 'package:reserva_if/model/sessao/sessao_autenticada.dart';
import 'package:reserva_if/model/usuario/perfil.dart';
import 'package:reserva_if/model/usuario/perfil_usuario.dart';
import 'package:reserva_if/model/usuario/tipo_credencial.dart';

const _credencialAutenticada = {
  'uuid': '64b7f0c2a1b2c3d4e5f60222',
  'nivelAcesso': 2,
  'token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.exemplo.assinatura',
};

const _perfilUsuario = {
  'uuid': '64b7f0c2a1b2c3d4e5f60333',
  'nome': 'Prof. Carlos Mendes',
  'email': 'carlos.mendes@ifes.edu.br',
  'telefone': '(27) 98888-1111',
  'nivelAcesso': 2,
  'role': 'COORDENADOR',
  'tipoCredencial': 'SIAPE_DOCENTE',
  'identificador': '1543210',
  'ativo': true,
  'criadoEm': '2026-10-20T12:00:00.000Z',
  'aluno': null,
  'servidor': {
    'siape': '1543210',
    'departamento': {'id': 'dcc', 'nome': 'DCC'},
  },
  'coordenacoes': [
    {'id': 'c1', 'predioId': 'p1', 'setorId': null, 'ativo': true},
  ],
};

void main() {
  group('SessaoAutenticada', () {
    test('lê uuid, token e o perfil pelo nivelAcesso', () {
      final sessao = SessaoAutenticada.fromJson(_credencialAutenticada);

      expect(sessao.uuid, '64b7f0c2a1b2c3d4e5f60222');
      expect(sessao.perfil, Perfil.coordenador);
      expect(sessao.token, startsWith('eyJ'));
    });

    test('falha alto sem token ou com nivelAcesso desconhecido', () {
      expect(
        () => SessaoAutenticada.fromJson({
          ..._credencialAutenticada,
          'token': null,
        }),
        throwsA(isA<TypeError>()),
      );
      expect(
        () => SessaoAutenticada.fromJson({
          ..._credencialAutenticada,
          'nivelAcesso': 9,
        }),
        throwsArgumentError,
      );
    });
  });

  group('PerfilUsuario', () {
    test('lê o PerfilUsuario do Swagger e ignora o que não usa', () {
      final usuario = PerfilUsuario.fromJson(_perfilUsuario);

      expect(usuario.uuid, '64b7f0c2a1b2c3d4e5f60333');
      expect(usuario.nome, 'Prof. Carlos Mendes');
      expect(usuario.email, 'carlos.mendes@ifes.edu.br');
      expect(usuario.telefone, '(27) 98888-1111');
      expect(usuario.perfil, Perfil.coordenador);
      expect(usuario.tipoCredencial, TipoCredencial.siapeDocente);
      expect(usuario.identificador, '1543210');
      expect(usuario.ativo, isTrue);
      expect(usuario.podeAprovar, isTrue);
    });

    test('aceita telefone ausente', () {
      final json = Map<String, dynamic>.from(_perfilUsuario)
        ..remove('telefone');

      expect(PerfilUsuario.fromJson(json).telefone, isNull);
    });

    test('falha alto sem role, identificador, ativo ou nome', () {
      for (final chave in ['role', 'identificador', 'ativo', 'nome']) {
        final json = Map<String, dynamic>.from(_perfilUsuario)..remove(chave);

        expect(
          () => PerfilUsuario.fromJson(json),
          anyOf(throwsArgumentError, throwsA(isA<TypeError>())),
          reason: chave,
        );
      }
    });

    test('formata o identificador pelo tipo do perfil', () {
      final coordenador = PerfilUsuario.fromJson(_perfilUsuario);
      final aluno = PerfilUsuario.fromJson({
        ..._perfilUsuario,
        'role': 'ALUNO',
        'tipoCredencial': 'MATRICULA_ALUNO',
        'identificador': '20241tsi0063',
      });

      expect(coordenador.identificadorFormatado, 'SIAPE 1543210');
      expect(aluno.identificadorFormatado, 'Matrícula 20241tsi0063');
      expect(aluno.podeAprovar, isFalse);
    });

    test('resumo é o UsuarioResumo embutido nas entidades', () {
      final resumo = PerfilUsuario.fromJson(_perfilUsuario).resumo;

      expect(resumo.id, '64b7f0c2a1b2c3d4e5f60333');
      expect(resumo.nome, 'Prof. Carlos Mendes');
    });

    test('toJson faz ida e volta com fromJson para a persistência local', () {
      final usuario = PerfilUsuario.fromJson(_perfilUsuario);
      final relido = PerfilUsuario.fromJson(usuario.toJson());

      expect(relido.uuid, usuario.uuid);
      expect(relido.perfil, usuario.perfil);
      expect(relido.tipoCredencial, usuario.tipoCredencial);
      expect(relido.identificador, usuario.identificador);
      expect(relido.telefone, usuario.telefone);
      expect(usuario.toJson().containsKey('token'), isFalse);
    });
  });
}
