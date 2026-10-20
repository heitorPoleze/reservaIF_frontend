import 'package:flutter_test/flutter_test.dart';
import 'package:reserva_if/model/usuario/cadastro_usuario.dart';
import 'package:reserva_if/model/usuario/departamento_elegivel.dart';
import 'package:reserva_if/model/usuario/perfil.dart';
import 'package:reserva_if/services/http/exceptions/api_exceptions.dart';
import 'package:reserva_if/services/services_usuario.dart';
import 'package:reserva_if/viewmodel/usuario/cadastro_viewmodel.dart';

class ServicesUsuarioFalso extends ServicesUsuario {
  ServicesUsuarioFalso({this.falharCarga = false});

  final bool falharCarga;
  final List<CadastroUsuario> enviados = [];

  @override
  Future<List<DepartamentoElegivel>> buscarDepartamentosElegiveis() async {
    if (falharCarga) throw ApiException('Catálogo indisponível.');
    return const [
      DepartamentoElegivel(
        id: 'curso-agronomia',
        nome: 'Coordenadoria do Curso Superior de Agronomia',
        diretoria: 'Diretoria de Ensino',
      ),
      DepartamentoElegivel(
        id: 'biblioteca',
        nome: 'Coordenadoria de Biblioteca',
        diretoria: 'Assistência à Comunidade',
      ),
    ];
  }

  @override
  Future<String> cadastrar(CadastroUsuario cadastro) async {
    enviados.add(cadastro);
    return 'uuid';
  }
}

CadastroViewModel _viewModel({ServicesUsuarioFalso? service}) =>
    CadastroViewModel(service: service ?? ServicesUsuarioFalso());

Future<bool> _cadastrar(CadastroViewModel viewModel) => viewModel.cadastrar(
  nome: 'Ana Souza',
  email: 'ana@ifes.edu.br',
  telefone: '',
  identificador: '1234567',
  senha: 'SenhaSegura1',
);

void main() {
  test('opções de vínculo seguem o perfil', () async {
    final viewModel = _viewModel();
    await viewModel.carregarDepartamentos();

    expect(viewModel.opcoesDeVinculo.map((item) => item.id), ['biblioteca']);

    expect(
      viewModel.opcoesDeVinculo.map((item) => item.id),
      isNot(contains('curso-agronomia')),
    );
  });

  test('trocar para aluno limpa o vínculo de departamento', () {
    final viewModel = _viewModel()
      ..selecionarPerfil(Perfil.professor)
      ..selecionarVinculo('biblioteca')
      ..selecionarPerfil(Perfil.aluno);

    expect(viewModel.vinculoId, isNull);
  });

  test('trocar entre servidores mantém o departamento', () {
    final viewModel = _viewModel()
      ..selecionarPerfil(Perfil.professor)
      ..selecionarVinculo('biblioteca')
      ..selecionarPerfil(Perfil.tecnico);

    expect(viewModel.vinculoId, 'biblioteca');
  });

  test('coordenador sem departamento não dispara requisição', () async {
    final service = ServicesUsuarioFalso();
    final viewModel = _viewModel(service: service)
      ..selecionarPerfil(Perfil.coordenador);

    expect(await _cadastrar(viewModel), isFalse);
    expect(service.enviados, isEmpty);
  });

  test('cadastro de coordenador envia o departamento escolhido', () async {
    final service = ServicesUsuarioFalso();
    final viewModel = _viewModel(service: service)
      ..selecionarPerfil(Perfil.coordenador)
      ..selecionarVinculo('biblioteca');

    expect(await _cadastrar(viewModel), isTrue);

    final enviado = service.enviados.single;
    expect(enviado.perfil, Perfil.coordenador);
    expect(enviado.vinculoId, 'biblioteca');
  });

  test('trocar de professor para coordenador mantém o departamento', () {
    final viewModel = _viewModel()
      ..selecionarPerfil(Perfil.professor)
      ..selecionarVinculo('biblioteca')
      ..selecionarPerfil(Perfil.coordenador);

    expect(viewModel.vinculoId, 'biblioteca');
  });

  test('cadastro de aluno não exige nem envia vínculo de curso', () async {
    final service = ServicesUsuarioFalso();
    final viewModel = _viewModel(service: service);

    expect(await _cadastrar(viewModel), isTrue);
    expect(service.enviados.single.perfil, Perfil.aluno);
    expect(service.enviados.single.vinculoId, isNull);
    expect(service.enviados.single.toJson().containsKey('cursoId'), isFalse);
  });

  test('falha na carga do catálogo fica no erro dos vínculos', () async {
    final viewModel = _viewModel(
      service: ServicesUsuarioFalso(falharCarga: true),
    );

    await viewModel.carregarDepartamentos();

    expect(viewModel.mensagemErroVinculos, 'Catálogo indisponível.');
    expect(viewModel.mensagemErro, isNull);
    expect(viewModel.isCarregandoVinculos, isFalse);
  });
}
