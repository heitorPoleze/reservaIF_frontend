import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:reserva_if/model/usuario/cadastro_usuario.dart';
import 'package:reserva_if/model/usuario/perfil.dart';
import 'package:reserva_if/services/services_usuario.dart';

import 'mock_http.dart';

CadastroUsuario _cadastro(Perfil perfil) => CadastroUsuario(
      perfil: perfil,
      nome: 'Ana Souza',
      email: 'ana@ifes.edu.br',
      identificador: '1234567',
      senha: 'SenhaSegura1',
      vinculoId: 'curso-agronomia',
    );

Map<String, dynamic> _corpo(http.Request requisicao) =>
    jsonDecode(requisicao.body) as Map<String, dynamic>;

void main() {
  final service = ServicesUsuario(chaveDeProvisionamento: 'chave-dev');

  group('buscarDepartamentosElegiveis', () {
    test('converte o catálogo da API', () async {
      http.Request? enviada;

      final lista = await comRespostaFixa(
        service.buscarDepartamentosElegiveis,
        respostaJson([
          {
            'id': 'curso-agronomia',
            'nome': 'Coordenadoria do Curso Superior de Agronomia',
            'diretoria': 'Diretoria de Ensino',
          },
          {
            'id': 'tecnologia-informacao',
            'nome': 'Coordenadoria de Tecnologia da Informação',
            'sigla': 'CTI',
            'diretoria': 'Diretoria Geral',
          },
        ], 200),
        capturar: (requisicao) => enviada = requisicao,
      );

      expect(enviada!.url.path, endsWith('/usuarios/departamentos-elegiveis'));
      expect(lista, hasLength(2));
      expect(lista.first.ehCoordenadoriaDeCurso, isTrue);
      expect(lista.last.sigla, 'CTI');
    });
  });

  group('cadastrar', () {
    test('aluno vai sem chave de provisionamento e com cursoId', () async {
      http.Request? enviada;

      final uuid = await comRespostaFixa(
        () => service.cadastrar(_cadastro(Perfil.aluno)),
        respostaJson(
          {'uuid': '64b7f0c2a1b2c3d4e5f60222', 'nivelAcesso': 0},
          201,
        ),
        capturar: (requisicao) => enviada = requisicao,
      );

      expect(uuid, '64b7f0c2a1b2c3d4e5f60222');
      expect(enviada!.method, 'POST');
      expect(enviada!.url.path, endsWith('/usuarios'));
      expect(
        enviada!.headers
            .containsKey(ServicesUsuario.cabecalhoDeProvisionamento),
        isFalse,
      );
      expect(_corpo(enviada!)['tipoCredencial'], 'MATRICULA_ALUNO');
      expect(_corpo(enviada!)['cursoId'], 'curso-agronomia');
    });

    test('professor leva a chave e o departamentoId', () async {
      http.Request? enviada;

      await comRespostaFixa(
        () => service.cadastrar(_cadastro(Perfil.professor)),
        respostaJson({'uuid': 'x', 'nivelAcesso': 1}, 201),
        capturar: (requisicao) => enviada = requisicao,
      );

      expect(
        enviada!.headers[ServicesUsuario.cabecalhoDeProvisionamento],
        'chave-dev',
      );
      expect(_corpo(enviada!)['tipoCredencial'], 'SIAPE_DOCENTE');
      expect(_corpo(enviada!)['departamentoId'], 'curso-agronomia');
      expect(_corpo(enviada!).containsKey('cursoId'), isFalse);
    });

    test('servidor sem chave configurada não envia o cabeçalho', () async {
      http.Request? enviada;

      await comRespostaFixa(
        () => ServicesUsuario(chaveDeProvisionamento: '')
            .cadastrar(_cadastro(Perfil.tecnico)),
        respostaJson({'uuid': 'x', 'nivelAcesso': 3}, 201),
        capturar: (requisicao) => enviada = requisicao,
      );

      expect(
        enviada!.headers
            .containsKey(ServicesUsuario.cabecalhoDeProvisionamento),
        isFalse,
      );
    });

    test('403 vira mensagem sobre a chave de provisionamento', () async {
      final erro = await erroDe(
        () => comRespostaFixa(
          () => service.cadastrar(_cadastro(Perfil.professor)),
          respostaJson({'erro': 'PERMISSAO_NEGADA', 'mensagem': 'x'}, 403),
        ),
      );

      expect(erro.mensagem, contains('chave de provisionamento'));
    });

    test('409 repassa a mensagem do backend, não o código', () async {
      final erro = await erroDe(
        () => comRespostaFixa(
          () => service.cadastrar(_cadastro(Perfil.aluno)),
          respostaJson({
            'erro': 'CONFLITO',
            'mensagem': 'UUID, email ou identificador de login ja cadastrado.',
          }, 409),
        ),
      );

      expect(erro.mensagem, contains('ja cadastrado'));
      expect(erro.mensagem, isNot(contains('CONFLITO')));
    });
  });
}
