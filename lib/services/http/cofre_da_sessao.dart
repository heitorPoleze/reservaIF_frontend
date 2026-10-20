import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CofreDaSessao {
  static const _chaveDoToken = 'token_sessao';
  static const _cofre = FlutterSecureStorage();

  static Future<String?> lerToken() async {
    try {
      return await _cofre.read(key: _chaveDoToken);
    } on PlatformException catch (e) {
      debugPrint('Cofre da sessão ilegível, sessão descartada: ${e.code}');
      await apagarToken();
      return null;
    }
  }

  static Future<void> gravarToken(String token) =>
      _cofre.write(key: _chaveDoToken, value: token);

  static Future<void> apagarToken() async {
    try {
      await _cofre.delete(key: _chaveDoToken);
    } on PlatformException catch (e) {
      debugPrint('Falha ao apagar o token do cofre: ${e.code}');
    }
  }
}
