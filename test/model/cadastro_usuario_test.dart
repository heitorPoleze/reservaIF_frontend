import 'package:flutter_test/flutter_test.dart';
import 'package:reserva_if/model/usuario/cadastro_usuario.dart';
import 'package:reserva_if/model/usuario/credencial/tipo_entrada.dart';
import 'package:reserva_if/model/usuario/departamento_elegivel.dart';
import 'package:reserva_if/model/usuario/perfil.dart';
import 'package:reserva_if/model/usuario/tipo_credencial.dart';

CadastroUsuario _cadastro(Perfil perfil, {String? telefone}) =>
    CadastroUsuario(
      perfil: perfil,
      nome: '  Ana Souza ',
      email: ' Ana@IFES.edu.br ',
      telefone: telefone,
      identificador: ' 1234567 ',
      senha: 'SenhaSegura1',
      vinculoId: 'vinculo',
    );

void main() {
  group('TipoCredencial', () {
    test('espelha o Prisma e faz ida e volta', () {
      for (final tipo in TipoCredencial.values) {
        expect(TipoCredencial.fromJson(tipo.toJson()), tipo);
      }
      expect(TipoCredencial.values.map((tipo) => tipo.toJson()), [
        'MATRICULA_ALUNO',
        'SIAPE_DOCENTE',
        'SIAPE_TECNICO',
      ]);
    });

    test('falha alto em valor desconhecido', () {
      expect(() => TipoCredencial.fromJson('COORDENADOR'), throwsArgumentError);
      expect(() => TipoCredencial.fromJson(null), throwsArgumentError);
    });
  });

  group('Perfil no cadastro', () {
    test('aluno entra com matrícula e se vincula a curso', () {
      expect(Perfil.aluno.identificador, TipoEntrada.matricula);
      expect(Perfil.aluno.vinculaCurso, isTrue);
      expect(Perfil.aluno.exigeProvisionamento, isFalse);
      expect(Perfil.aluno.tipoCredencial, TipoCredencial.matriculaAluno);
    });

    test('servidores entram com SIAPE e exigem provisionamento', () {
      for (final perfil in [Perfil.professor, Perfil.tecnico]) {
        expect(perfil.identificador, TipoEntrada.siape);
        expect(perfil.vinculaCurso, isFalse);
        expect(perfil.exigeProvisionamento, isTrue);
        expect(perfil.cadastroDisponivel, isTrue);
      }
      expect(Perfil.professor.tipoCredencial, TipoCredencial.siapeDocente);
      expect(Perfil.tecnico.tipoCredencial, TipoCredencial.siapeTecnico);
    });

    test('coordenador ainda não tem cadastro aberto', () {
      expect(Perfil.coordenador.tipoCredencial, isNull);
      expect(Perfil.coordenador.cadastroDisponivel, isFalse);
      expect(Perfil.coordenador.identificador, TipoEntrada.siape);
    });
  });

  group('CadastroUsuario.toJson', () {
    test('aluno segue CadastroUsuarioInput com cursoId', () {
      expect(_cadastro(Perfil.aluno).toJson(), {
        'nome': 'Ana Souza',
        'email': 'ana@ifes.edu.br',
        'tipoCredencial': 'MATRICULA_ALUNO',
        'credencial': {
          'tipoEntrada': 0,
          'entrada': '1234567',
          'senha': 'SenhaSegura1',
        },
        'cursoId': 'vinculo',
      });
    });

    test('servidor manda departamentoId e telefone quando informado', () {
      final json =
          _cadastro(Perfil.tecnico, telefone: ' (27) 99999-0000 ').toJson();

      expect(json['tipoCredencial'], 'SIAPE_TECNICO');
      expect(json['departamentoId'], 'vinculo');
      expect(json['telefone'], '(27) 99999-0000');
      expect(json.containsKey('cursoId'), isFalse);
    });

    test('telefone em branco não vai no corpo', () {
      final json = _cadastro(Perfil.aluno, telefone: '   ').toJson();

      expect(json.containsKey('telefone'), isFalse);
    });

    test('coordenador não serializa', () {
      expect(() => _cadastro(Perfil.coordenador).toJson(), throwsStateError);
    });

    test('a credencial é a mesma do login, com matrícula normalizada', () {
      const cadastro = CadastroUsuario(
        perfil: Perfil.aluno,
        nome: 'Bia',
        email: 'bia@ifes.edu.br',
        identificador: '20241TSI0063',
        senha: 'SenhaSegura1',
        vinculoId: 'curso-si',
      );

      expect(cadastro.toJson()['credencial'], cadastro.credencial.toJson());
      expect(cadastro.toJson()['credencial']['entrada'], '20241tsi0063');
    });

    test('identificador inválido falha alto ao serializar', () {
      const cadastro = CadastroUsuario(
        perfil: Perfil.aluno,
        nome: 'Bia',
        email: 'bia@ifes.edu.br',
        identificador: 'abc',
        senha: 'SenhaSegura1',
        vinculoId: 'curso-si',
      );

      expect(cadastro.toJson, throwsArgumentError);
    });
  });

  group('DepartamentoElegivel', () {
    const curso = DepartamentoElegivel(
      id: 'curso-agronomia',
      nome: 'Coordenadoria do Curso Superior de Agronomia',
      diretoria: 'Diretoria de Ensino',
    );
    const setor = DepartamentoElegivel(
      id: 'tecnologia-informacao',
      nome: 'Coordenadoria de Tecnologia da Informação',
      diretoria: 'Diretoria Geral',
      sigla: 'CTI',
    );

    test('reconhece coordenadoria de curso pelo id', () {
      expect(curso.ehCoordenadoriaDeCurso, isTrue);
      expect(setor.ehCoordenadoriaDeCurso, isFalse);
    });

    test('rótulo de vínculo encurta curso e prefixa sigla', () {
      expect(curso.rotuloDeVinculo, 'Superior de Agronomia');
      expect(
        setor.rotuloDeVinculo,
        'CTI · Coordenadoria de Tecnologia da Informação',
      );
    });

    test('fromJson aceita sigla ausente', () {
      final lido = DepartamentoElegivel.fromJson({
        'id': 'biblioteca',
        'nome': 'Coordenadoria de Biblioteca',
        'diretoria': 'Assistência à Comunidade',
      });

      expect(lido.sigla, isNull);
      expect(lido.rotulo, 'Coordenadoria de Biblioteca');
    });
  });
}
