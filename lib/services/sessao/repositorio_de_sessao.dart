import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:reserva_if/model/sessao/sessao_guardada.dart';
import 'package:reserva_if/model/usuario/perfil_usuario.dart';
import 'package:reserva_if/services/http/cofre_da_sessao.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class RepositorioDeSessao {
  Future<SessaoGuardada?> ler();

  Future<void> gravar(SessaoGuardada sessao);

  Future<void> apagar();
}

class RepositorioDeSessaoLocal implements RepositorioDeSessao {
  static const String chaveDoUsuario = 'usuario_sessao';

  @override
  Future<SessaoGuardada?> ler() async {
    final token = await CofreDaSessao.lerToken();
    final preferencias = await SharedPreferences.getInstance();
    final usuario = _lerUsuario(preferencias.getString(chaveDoUsuario));

    if (token == null || usuario == null) {
      await apagar();
      return null;
    }

    return SessaoGuardada(token: token, usuario: usuario);
  }

  @override
  Future<void> gravar(SessaoGuardada sessao) async {
    final preferencias = await SharedPreferences.getInstance();

    await CofreDaSessao.gravarToken(sessao.token);
    await preferencias.setString(
      chaveDoUsuario,
      jsonEncode(sessao.usuario.toJson()),
    );
  }

  @override
  Future<void> apagar() async {
    final preferencias = await SharedPreferences.getInstance();

    await CofreDaSessao.apagarToken();
    await preferencias.remove(chaveDoUsuario);
  }

  PerfilUsuario? _lerUsuario(String? gravado) {
    if (gravado == null) return null;

    try {
      return PerfilUsuario.fromJson(
        jsonDecode(gravado) as Map<String, dynamic>,
      );
    } catch (e) {
      debugPrint('Usuário da sessão ilegível, sessão descartada: $e');
      return null;
    }
  }
}
