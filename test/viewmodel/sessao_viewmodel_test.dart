import 'package:flutter_test/flutter_test.dart';
import 'package:reserva_if/model/sessao/sessao_autenticada.dart';
import 'package:reserva_if/model/sessao/sessao_guardada.dart';
import 'package:reserva_if/model/usuario/credencial/credencial.dart';
import 'package:reserva_if/model/usuario/perfil.dart';
import 'package:reserva_if/model/usuario/perfil_usuario.dart';
import 'package:reserva_if/model/usuario/tipo_credencial.dart';
import 'package:reserva_if/services/http/exceptions/api_exceptions.dart';
import 'package:reserva_if/services/services_autenticacao.dart';
import 'package:reserva_if/services/services_base.dart';
import 'package:reserva_if/services/services_usuario.dart';
import 'package:reserva_if/services/sessao/repositorio_de_sessao.dart';
import 'package:reserva_if/viewmodel/estado_de_carga.dart';
import 'package:reserva_if/viewmodel/sessao/sessao_viewmodel.dart';

const _perfilDoServidor = PerfilUsuario(
  uuid: 'u1',
  nome: 'Ana Souza',
  email: 'ana@ifes.edu.br',
  perfil: Perfil.professor,
  tipoCredencial: TipoCredencial.siapeDocente,
  identificador: '1234567',
  ativo: true,
);

const _perfilGuardado = PerfilUsuario(
  uuid: 'u1',
  nome: 'Ana (nome antigo)',
  email: 'ana@ifes.edu.br',
  perfil: Perfil.professor,
  tipoCredencial: TipoCredencial.siapeDocente,
  identificador: '1234567',
  ativo: true,
);

class ServicesAutenticacaoFalso extends ServicesAutenticacao {
  ServicesAutenticacaoFalso({this.erro});

  final ApiException? erro;
  Credencial? recebida;

  @override
  Future<SessaoAutenticada> entrar(Credencial credencial) async {
    recebida = credencial;
    if (erro != null) throw erro!;
    return const SessaoAutenticada(
      uuid: 'u1',
      perfil: Perfil.professor,
      token: 'token-novo',
    );
  }
}

class ServicesUsuarioFalso extends ServicesUsuario {
  ServicesUsuarioFalso({this.erro});

  final Object? erro;
  int chamadas = 0;
  String? tokenVisto;

  @override
  Future<PerfilUsuario> buscarPerfil() async {
    chamadas++;
    tokenVisto = BaseService.tokenDeSessao;
    if (erro != null) throw erro!;
    return _perfilDoServidor;
  }
}

class RepositorioDeSessaoEmMemoria implements RepositorioDeSessao {
  RepositorioDeSessaoEmMemoria([this.guardada]);

  SessaoGuardada? guardada;
  int apagamentos = 0;

  @override
  Future<SessaoGuardada?> ler() async => guardada;

  @override
  Future<void> gravar(SessaoGuardada sessao) async => guardada = sessao;

  @override
  Future<void> apagar() async {
    apagamentos++;
    guardada = null;
  }
}

SessaoViewModel _viewModel({
  ServicesAutenticacaoFalso? autenticacao,
  ServicesUsuarioFalso? usuarios,
  RepositorioDeSessaoEmMemoria? repositorio,
}) => SessaoViewModel(
  autenticacao: autenticacao ?? ServicesAutenticacaoFalso(),
  usuarios: usuarios ?? ServicesUsuarioFalso(),
  repositorio: repositorio ?? RepositorioDeSessaoEmMemoria(),
);

const _sessaoGuardada = SessaoGuardada(
  token: 'token-guardado',
  usuario: _perfilGuardado,
);

void main() {
  setUp(() {
    BaseService.tokenDeSessao = null;
    BaseService.aoSessaoExpirar = null;
  });

  group('restaurar', () {
    test('sem sessão guardada fica deslogado sem chamar o servidor', () async {
      final usuarios = ServicesUsuarioFalso();
      final viewModel = _viewModel(usuarios: usuarios);

      expect(viewModel.estado, EstadoDaSessao.inicializando);

      await viewModel.restaurar();

      expect(viewModel.estado, EstadoDaSessao.deslogado);
      expect(viewModel.usuario, isNull);
      expect(usuarios.chamadas, 0);
      expect(BaseService.tokenDeSessao, isNull);
    });

    test('com token válido entra com o perfil atualizado do /me', () async {
      final usuarios = ServicesUsuarioFalso();
      final repositorio = RepositorioDeSessaoEmMemoria(_sessaoGuardada);
      final viewModel = _viewModel(
        usuarios: usuarios,
        repositorio: repositorio,
      );

      await viewModel.restaurar();

      expect(viewModel.estado, EstadoDaSessao.logado);
      expect(viewModel.usuario!.nome, 'Ana Souza');
      expect(usuarios.tokenVisto, 'token-guardado');
      expect(BaseService.tokenDeSessao, 'token-guardado');
      expect(repositorio.guardada!.usuario.nome, 'Ana Souza');
    });

    test('token expirado descarta a sessão guardada', () async {
      final repositorio = RepositorioDeSessaoEmMemoria(_sessaoGuardada);
      final viewModel = _viewModel(
        usuarios: ServicesUsuarioFalso(erro: SessaoExpiradaException()),
        repositorio: repositorio,
      );

      await viewModel.restaurar();

      expect(viewModel.estado, EstadoDaSessao.deslogado);
      expect(viewModel.usuario, isNull);
      expect(repositorio.guardada, isNull);
      expect(BaseService.tokenDeSessao, isNull);
    });

    test('sem rede entra com o usuário guardado e mantém o token', () async {
      final repositorio = RepositorioDeSessaoEmMemoria(_sessaoGuardada);
      final viewModel = _viewModel(
        usuarios: ServicesUsuarioFalso(erro: SemConexaoException('offline')),
        repositorio: repositorio,
      );

      await viewModel.restaurar();

      expect(viewModel.estado, EstadoDaSessao.logado);
      expect(viewModel.usuario!.nome, 'Ana (nome antigo)');
      expect(BaseService.tokenDeSessao, 'token-guardado');
      expect(repositorio.guardada, isNotNull);
    });

    test('servidor em 5xx também entra com o usuário guardado', () async {
      final viewModel = _viewModel(
        usuarios: ServicesUsuarioFalso(erro: ErroDoServidorException('500')),
        repositorio: RepositorioDeSessaoEmMemoria(_sessaoGuardada),
      );

      await viewModel.restaurar();

      expect(viewModel.estado, EstadoDaSessao.logado);
    });

    test(
      'defeito inesperado no boot descarta a sessão em vez de travar',
      () async {
        final repositorio = RepositorioDeSessaoEmMemoria(_sessaoGuardada);
        final viewModel = _viewModel(
          usuarios: ServicesUsuarioFalso(erro: TypeError()),
          repositorio: repositorio,
        );

        await viewModel.restaurar();

        expect(viewModel.estado, EstadoDaSessao.deslogado);
        expect(repositorio.guardada, isNull);
      },
    );
  });

  group('entrar', () {
    test('login válido grava token e perfil e fica logado', () async {
      final autenticacao = ServicesAutenticacaoFalso();
      final usuarios = ServicesUsuarioFalso();
      final repositorio = RepositorioDeSessaoEmMemoria();
      final viewModel = _viewModel(
        autenticacao: autenticacao,
        usuarios: usuarios,
        repositorio: repositorio,
      );
      await viewModel.restaurar();

      final entrou = await viewModel.entrar(
        entrada: ' 20241TSI0063 ',
        senha: 'Segredo@1',
      );

      expect(entrou, isTrue);
      expect(viewModel.estado, EstadoDaSessao.logado);
      expect(viewModel.usuario!.uuid, 'u1');
      expect(viewModel.mensagemErro, isNull);
      expect(viewModel.isLoading, isFalse);
      expect(autenticacao.recebida!.entrada, '20241tsi0063');
      expect(usuarios.tokenVisto, 'token-novo');
      expect(BaseService.tokenDeSessao, 'token-novo');
      expect(repositorio.guardada!.token, 'token-novo');
      expect(repositorio.guardada!.usuario.nome, 'Ana Souza');
    });

    test('credencial rejeitada expõe a mensagem e não grava nada', () async {
      final repositorio = RepositorioDeSessaoEmMemoria();
      final viewModel = _viewModel(
        autenticacao: ServicesAutenticacaoFalso(
          erro: ApiException('Matrícula/SIAPE ou senha inválidos.'),
        ),
        repositorio: repositorio,
      );
      await viewModel.restaurar();

      final entrou = await viewModel.entrar(
        entrada: '1234567',
        senha: 'errada123',
      );

      expect(entrou, isFalse);
      expect(viewModel.estado, EstadoDaSessao.deslogado);
      expect(viewModel.mensagemErro, 'Matrícula/SIAPE ou senha inválidos.');
      expect(repositorio.guardada, isNull);
      expect(BaseService.tokenDeSessao, isNull);
    });

    test('falha ao buscar o perfil desfaz o token já recebido', () async {
      final repositorio = RepositorioDeSessaoEmMemoria();
      final viewModel = _viewModel(
        usuarios: ServicesUsuarioFalso(
          erro: ApiException('Perfil indisponível.'),
        ),
        repositorio: repositorio,
      );
      await viewModel.restaurar();

      final entrou = await viewModel.entrar(entrada: '1234567', senha: 'x');

      expect(entrou, isFalse);
      expect(viewModel.estado, EstadoDaSessao.deslogado);
      expect(viewModel.mensagemErro, 'Perfil indisponível.');
      expect(BaseService.tokenDeSessao, isNull);
      expect(repositorio.guardada, isNull);
    });

    test('entrada que não é matrícula nem SIAPE cai no erro interno', () async {
      final viewModel = _viewModel();
      await viewModel.restaurar();

      final entrou = await viewModel.entrar(entrada: 'ana@ifes', senha: 'x');

      expect(entrou, isFalse);
      expect(viewModel.mensagemErro, mensagemErroInterno);
    });

    test('notifica ao ligar e desligar o indicador', () async {
      final viewModel = _viewModel();
      await viewModel.restaurar();
      final estados = <bool>[];
      viewModel.addListener(() => estados.add(viewModel.isLoading));

      await viewModel.entrar(entrada: '1234567', senha: 'x');

      expect(estados.first, isTrue);
      expect(estados.last, isFalse);
    });
  });

  group('sair e expiração', () {
    test('sair apaga a sessão e volta a deslogado', () async {
      final repositorio = RepositorioDeSessaoEmMemoria(_sessaoGuardada);
      final viewModel = _viewModel(repositorio: repositorio);
      await viewModel.restaurar();
      expect(viewModel.estado, EstadoDaSessao.logado);

      await viewModel.sair();

      expect(viewModel.estado, EstadoDaSessao.deslogado);
      expect(viewModel.usuario, isNull);
      expect(repositorio.guardada, isNull);
      expect(BaseService.tokenDeSessao, isNull);
    });

    test('encerrarPorExpiracao desloga uma vez só', () async {
      final repositorio = RepositorioDeSessaoEmMemoria(_sessaoGuardada);
      final viewModel = _viewModel(repositorio: repositorio);
      await viewModel.restaurar();

      viewModel.encerrarPorExpiracao();
      viewModel.encerrarPorExpiracao();
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.estado, EstadoDaSessao.deslogado);
      expect(repositorio.apagamentos, 1);
      expect(BaseService.tokenDeSessao, isNull);
    });

    test('encerrarPorExpiracao ignora quem não está logado', () async {
      final repositorio = RepositorioDeSessaoEmMemoria();
      final viewModel = _viewModel(repositorio: repositorio);
      await viewModel.restaurar();

      viewModel.encerrarPorExpiracao();
      await Future<void>.delayed(Duration.zero);

      expect(repositorio.apagamentos, 0);
    });
  });
}
