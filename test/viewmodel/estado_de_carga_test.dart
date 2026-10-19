import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reserva_if/services/http/exceptions/api_exceptions.dart';
import 'package:reserva_if/viewmodel/estado_de_carga.dart';
import 'package:reserva_if/viewmodel/notifica_se_vivo_mixin.dart';

class ViewModelDeTeste extends ChangeNotifier
    with NotificaSeVivoMixin, EstadoDeCarregamentoMixin {
  late final EstadoDeCarga cargaSecundaria = EstadoDeCarga(
    aoMudar: notificarSeVivo,
    erroCompartilhadoCom: cargaPrincipal,
  );

  Future<int> carregar(Future<int> Function() chamada) {
    return cargaPrincipal.executar(chamada: chamada, aoFalhar: () => -1);
  }

  Future<int> carregarSecundario(Future<int> Function() chamada) {
    return cargaSecundaria.executar(chamada: chamada, aoFalhar: () => -1);
  }

  Future<int> carregarComGuardas(
    Future<int> Function() chamada, {
    bool Function()? aindaVale,
    void Function()? aoFinalizar,
  }) {
    return cargaPrincipal.executar(
      chamada: chamada,
      aoFalhar: () => -1,
      aindaVale: aindaVale,
      aoFinalizar: aoFinalizar,
    );
  }

  void abandonarCargaPrincipal() => cargaPrincipal.abandonar();
}

void main() {
  group('EstadoDeCarga.executar', () {
    test('liga e desliga o indicador e notifica nas duas pontas', () async {
      final viewModel = ViewModelDeTeste();
      final estadosVistos = <bool>[];
      viewModel.addListener(() => estadosVistos.add(viewModel.isLoading));

      final resultado = await viewModel.carregar(() async => 42);

      expect(resultado, 42);
      expect(estadosVistos, [true, false]);
      expect(viewModel.mensagemErro, isNull);
    });

    test('ApiException vira mensagemErro e devolve aoFalhar', () async {
      final viewModel = ViewModelDeTeste();

      final resultado = await viewModel.carregar(
        () async => throw ApiException('Sala indisponível'),
      );

      expect(resultado, -1);
      expect(viewModel.mensagemErro, 'Sala indisponível');
      expect(viewModel.isLoading, isFalse);
    });

    test('erro inesperado vira mensagemErroInterno', () async {
      final viewModel = ViewModelDeTeste();

      await viewModel.carregar(() async => throw StateError('bug'));

      expect(viewModel.mensagemErro, mensagemErroInterno);
    });

    test('nova execução limpa o erro anterior', () async {
      final viewModel = ViewModelDeTeste();

      await viewModel.carregar(() async => throw ApiException('falhou'));
      await viewModel.carregar(() async => 1);

      expect(viewModel.mensagemErro, isNull);
    });

    test('cargas com erro compartilhado escrevem no mesmo campo', () async {
      final viewModel = ViewModelDeTeste();

      await viewModel.carregarSecundario(
        () async => throw ApiException('erro da secundária'),
      );

      expect(viewModel.mensagemErro, 'erro da secundária');
      expect(viewModel.cargaSecundaria.mensagemErro, 'erro da secundária');
      expect(viewModel.isLoading, isFalse);
    });

    test('aindaVale false não escreve erro nem derruba o indicador',
        () async {
      final viewModel = ViewModelDeTeste();

      await viewModel.carregarComGuardas(
        () async => throw ApiException('resposta velha'),
        aindaVale: () => false,
      );

      expect(viewModel.mensagemErro, isNull);
      expect(viewModel.isLoading, isTrue);

      viewModel.abandonarCargaPrincipal();

      expect(viewModel.isLoading, isFalse);
    });

    test('aoFinalizar roda antes de o indicador cair', () async {
      final viewModel = ViewModelDeTeste();
      bool? carregandoDuranteFinalizar;

      await viewModel.carregarComGuardas(
        () async => 1,
        aoFinalizar: () => carregandoDuranteFinalizar = viewModel.isLoading,
      );

      expect(carregandoDuranteFinalizar, isTrue);
      expect(viewModel.isLoading, isFalse);
    });
  });

  group('NotificaSeVivoMixin', () {
    test('não notifica depois do dispose', () async {
      final viewModel = ViewModelDeTeste();
      final futuro = viewModel.carregar(
        () => Future.delayed(const Duration(milliseconds: 10), () => 1),
      );

      viewModel.dispose();

      await expectLater(futuro, completes);
      expect(viewModel.descartado, isTrue);
    });
  });
}
