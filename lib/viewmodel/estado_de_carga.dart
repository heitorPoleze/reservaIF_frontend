import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:reserva_if/services/http/exceptions/api_exceptions.dart';
import 'package:reserva_if/viewmodel/notifica_se_vivo_mixin.dart';

const String mensagemErroInterno =
    'Ocorreu um erro inesperado no aplicativo. Tente novamente mais tarde.';

class EstadoDeCarga {
  EstadoDeCarga({required this.aoMudar, this.erroCompartilhadoCom});

  final VoidCallback aoMudar;
  final EstadoDeCarga? erroCompartilhadoCom;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _mensagemErro;

  String? get mensagemErro =>
      erroCompartilhadoCom?.mensagemErro ?? _mensagemErro;

  set mensagemErro(String? mensagem) {
    final dono = erroCompartilhadoCom;

    if (dono == null) {
      _mensagemErro = mensagem;
    } else {
      dono.mensagemErro = mensagem;
    }
  }

  void abandonar() {
    _isLoading = false;
    mensagemErro = null;
  }

  Future<T> executar<T>({
    required Future<T> Function() chamada,
    required T Function() aoFalhar,
    bool Function()? aindaVale,
    FutureOr<void> Function()? aoFinalizar,
  }) async {
    _isLoading = true;
    mensagemErro = null;
    aoMudar();

    String? erro;

    try {
      return await chamada();
    } on ApiException catch (e) {
      erro = e.mensagem;
      return aoFalhar();
    } catch (_) {
      erro = mensagemErroInterno;
      return aoFalhar();
    } finally {
      if (aoFinalizar != null) await aoFinalizar();

      if (aindaVale?.call() ?? true) {
        if (erro != null) mensagemErro = erro;

        _isLoading = false;
        aoMudar();
      }
    }
  }
}

mixin EstadoDeCarregamentoMixin on NotificaSeVivoMixin {
  @protected
  late final EstadoDeCarga cargaPrincipal = EstadoDeCarga(
    aoMudar: notificarSeVivo,
  );

  bool get isLoading => cargaPrincipal.isLoading;

  String? get mensagemErro => cargaPrincipal.mensagemErro;

  @protected
  set mensagemErro(String? mensagem) => cargaPrincipal.mensagemErro = mensagem;
}
