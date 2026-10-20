import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:reserva_if/model/sessao/sessao_guardada.dart';
import 'package:reserva_if/model/usuario/credencial/credencial.dart';
import 'package:reserva_if/model/usuario/perfil_usuario.dart';
import 'package:reserva_if/services/http/exceptions/api_exceptions.dart';
import 'package:reserva_if/services/services_autenticacao.dart';
import 'package:reserva_if/services/services_base.dart';
import 'package:reserva_if/services/services_usuario.dart';
import 'package:reserva_if/services/sessao/repositorio_de_sessao.dart';
import 'package:reserva_if/viewmodel/estado_de_carga.dart';
import 'package:reserva_if/viewmodel/notifica_se_vivo_mixin.dart';

enum EstadoDaSessao { inicializando, deslogado, logado }

class SessaoViewModel extends ChangeNotifier
    with NotificaSeVivoMixin, EstadoDeCarregamentoMixin {
  SessaoViewModel({
    required this._autenticacao,
    required this._usuarios,
    required this._repositorio,
  });

  final ServicesAutenticacao _autenticacao;
  final ServicesUsuario _usuarios;
  final RepositorioDeSessao _repositorio;

  EstadoDaSessao _estado = EstadoDaSessao.inicializando;
  PerfilUsuario? _usuario;

  EstadoDaSessao get estado => _estado;

  PerfilUsuario? get usuario => _usuario;

  bool get estaLogado => _estado == EstadoDaSessao.logado;

  Future<void> restaurar() async {
    final guardada = await _repositorio.ler();

    if (guardada == null) {
      _mudarPara(EstadoDaSessao.deslogado);
      return;
    }

    BaseService.tokenDeSessao = guardada.token;

    try {
      final perfil = await _usuarios.buscarPerfil();
      await _abrir(guardada.token, perfil);
    } on SemConexaoException {
      _entrarSemServidor(guardada);
    } on ErroDoServidorException {
      _entrarSemServidor(guardada);
    } catch (e) {
      debugPrint('Sessão guardada descartada: $e');
      await _limpar();
    }
  }

  Future<bool> entrar({required String entrada, required String senha}) {
    if (isLoading) return Future.value(false);

    return cargaPrincipal.executar(
      chamada: () async {
        final credencial = Credencial.criar(entrada: entrada, senha: senha);
        final sessao = await _autenticacao.entrar(credencial);

        BaseService.tokenDeSessao = sessao.token;

        final perfil = await _usuarios.buscarPerfil();
        await _abrir(sessao.token, perfil);

        return true;
      },
      aoFalhar: () => false,
      aoFinalizar: () {
        if (!estaLogado) BaseService.tokenDeSessao = null;
      },
    );
  }

  Future<void> sair() => _limpar();

  void encerrarPorExpiracao() {
    if (!estaLogado) return;

    unawaited(_limpar());
  }

  Future<void> _abrir(String token, PerfilUsuario perfil) async {
    _usuario = perfil;
    await _repositorio.gravar(SessaoGuardada(token: token, usuario: perfil));
    _mudarPara(EstadoDaSessao.logado);
  }

  void _entrarSemServidor(SessaoGuardada guardada) {
    _usuario = guardada.usuario;
    _mudarPara(EstadoDaSessao.logado);
  }

  Future<void> _limpar() async {
    BaseService.tokenDeSessao = null;
    _usuario = null;
    _mudarPara(EstadoDaSessao.deslogado);
    await _repositorio.apagar();
  }

  void _mudarPara(EstadoDaSessao novo) {
    _estado = novo;
    notificarSeVivo();
  }
}
