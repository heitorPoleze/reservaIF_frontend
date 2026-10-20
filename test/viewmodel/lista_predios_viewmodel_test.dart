import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:reserva_if/model/predio/predio.dart';
import 'package:reserva_if/services/http/exceptions/api_exceptions.dart';
import 'package:reserva_if/services/services_predio.dart';
import 'package:reserva_if/viewmodel/predio/lista_predios_viewmodel.dart';

class ServicesPredioFalso extends ServicesPredio {
  ServicesPredioFalso({this.falhar = false, this.resposta});

  final bool falhar;
  final Completer<List<Predio>>? resposta;
  int chamadas = 0;

  @override
  Future<List<Predio>> buscarTodos() async {
    chamadas++;
    if (falhar) throw ApiException('Prédios indisponíveis.');
    final pendente = resposta;
    if (pendente != null) return pendente.future;
    return const [
      Predio(id: 'p1', nome: 'Prédio Administrativo'),
      Predio(id: 'p2', nome: 'Prédio Pedagógico'),
    ];
  }
}

void main() {
  test('carregar popula os prédios', () async {
    final viewModel = ListaPrediosViewModel(service: ServicesPredioFalso());

    await viewModel.carregar();

    expect(viewModel.predios.map((predio) => predio.id), ['p1', 'p2']);
    expect(viewModel.mensagemErro, isNull);
    expect(viewModel.isLoading, isFalse);
  });

  test('falha expõe a mensagem e mantém a lista vazia', () async {
    final viewModel = ListaPrediosViewModel(
      service: ServicesPredioFalso(falhar: true),
    );

    await viewModel.carregar();

    expect(viewModel.predios, isEmpty);
    expect(viewModel.mensagemErro, 'Prédios indisponíveis.');
  });

  test('carregar durante uma carga em voo não repete a requisição', () async {
    final resposta = Completer<List<Predio>>();
    final service = ServicesPredioFalso(resposta: resposta);
    final viewModel = ListaPrediosViewModel(service: service);

    final primeira = viewModel.carregar();
    await viewModel.carregar();
    resposta.complete(const [Predio(id: 'p1', nome: 'Prédio Administrativo')]);
    await primeira;

    expect(service.chamadas, 1);
    expect(viewModel.predios, hasLength(1));
  });
}
