import 'package:flutter_test/flutter_test.dart';
import 'package:reserva_if/model/usuario/cadastro_usuario.dart';
import 'package:reserva_if/model/usuario/credencial/tipo_entrada.dart';
import 'package:reserva_if/model/usuario/departamento_elegivel.dart';
import 'package:reserva_if/model/usuario/perfil.dart';
import 'package:reserva_if/model/usuario/tipo_credencial.dart';

CadastroUsuario _cadastro(Perfil perfil, {String? telefone}) => CadastroUsuario(
  perfil: perfil,
  nome: '  Ana Souza ',
  email: ' Ana@IFES.edu.br ',
  telefone: telefone,
  identificador: ' 1234567 ',
  senha: 'SenhaSegura1',
  vinculoId: perfil.exigeDepartamento ? 'vinculo' : null,
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
    test('aluno entra com matrícula sem vínculo a curso', () {
      expect(Perfil.aluno.identificador, TipoEntrada.matricula);
      expect(Perfil.aluno.exigeProvisionamento, isFalse);
      expect(Perfil.aluno.tipoCredencial, TipoCredencial.matriculaAluno);
    });

    test('servidores entram com SIAPE e exigem provisionamento', () {
      for (final perfil in [
        Perfil.professor,
        Perfil.tecnico,
        Perfil.coordenador,
      ]) {
        expect(perfil.identificador, TipoEntrada.siape);
        expect(perfil.exigeProvisionamento, isTrue);
        expect(perfil.exigeDepartamento, isTrue);
      }
      expect(Perfil.professor.tipoCredencial, TipoCredencial.siapeDocente);
      expect(Perfil.tecnico.tipoCredencial, TipoCredencial.siapeTecnico);
    });

    test('coordenador entra com SIAPE docente e rota própria', () {
      expect(Perfil.coordenador.tipoCredencial, TipoCredencial.siapeDocente);
      expect(Perfil.coordenador.coordenaPredio, isTrue);
    });

    test('aluno não exige departamento', () {
      expect(Perfil.aluno.exigeDepartamento, isFalse);
    });
  });

  group('CadastroUsuario.toJson', () {
    test('aluno não envia cursoId', () {
      expect(_cadastro(Perfil.aluno).toJson(), {
        'nome': 'Ana Souza',
        'email': 'ana@ifes.edu.br',
        'tipoCredencial': 'MATRICULA_ALUNO',
        'credencial': {
          'tipoEntrada': 0,
          'entrada': '1234567',
          'senha': 'SenhaSegura1',
        },
      });
    });

    test('servidor manda departamentoId e telefone quando informado', () {
      final json = _cadastro(
        Perfil.tecnico,
        telefone: ' (27) 99999-0000 ',
      ).toJson();

      expect(json['tipoCredencial'], 'SIAPE_TECNICO');
      expect(json['departamentoId'], 'vinculo');
      expect(json['telefone'], '(27) 99999-0000');
      expect(json.containsKey('cursoId'), isFalse);
    });

    test('telefone em branco não vai no corpo', () {
      final json = _cadastro(Perfil.aluno, telefone: '   ').toJson();

      expect(json.containsKey('telefone'), isFalse);
    });

    test('coordenador segue o CadastroCoordenadorInput', () {
      const cadastro = CadastroUsuario(
        perfil: Perfil.coordenador,
        nome: ' Roberto Lima ',
        email: 'Roberto@IFES.edu.br',
        identificador: ' 1765432 ',
        senha: 'SenhaSegura1',
        telefone: ' (27) 98888-3333 ',
        vinculoId: '64b7f0c2a1b2c3d4e5f60103',
      );

      expect(cadastro.toJson(), {
        'nome': 'Roberto Lima',
        'email': 'roberto@ifes.edu.br',
        'telefone': '(27) 98888-3333',
        'siape': '1765432',
        'senha': 'SenhaSegura1',
        'departamentoId': '64b7f0c2a1b2c3d4e5f60103',
      });
    });

    test('coordenador não envia prédio, portaria nem credencial', () {
      final json = _cadastro(Perfil.coordenador).toJson();

      expect(json.containsKey('predioId'), isFalse);
      expect(json.containsKey('numeroPortaria'), isFalse);
      expect(json.containsKey('credencial'), isFalse);
      expect(json.containsKey('tipoCredencial'), isFalse);
    });

    test('coordenador sem departamento falha alto ao serializar', () {
      const cadastro = CadastroUsuario(
        perfil: Perfil.coordenador,
        nome: 'Roberto Lima',
        email: 'roberto@ifes.edu.br',
        identificador: '1765432',
        senha: 'SenhaSegura1',
      );

      expect(cadastro.toJson, throwsStateError);
    });

    test('a credencial é a mesma do login, com matrícula normalizada', () {
      const cadastro = CadastroUsuario(
        perfil: Perfil.aluno,
        nome: 'Bia',
        email: 'bia@ifes.edu.br',
        identificador: '20241TSI0063',
        senha: 'SenhaSegura1',
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
