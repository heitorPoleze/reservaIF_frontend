import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CofreDaSessao {
  static const _chaveDoCookie = 'cookie_sessao';
  static const _cofre = FlutterSecureStorage();

  static Future<String?> lerCookie() async {
    try {
      return await _cofre.read(key: _chaveDoCookie);
    } on PlatformException catch (e) {
      debugPrint('Cofre da sessão ilegível, sessão descartada: ${e.code}');
      await apagarCookie();
      return null;
    }
  }

  static Future<void> gravarCookie(String cookie) =>
      _cofre.write(key: _chaveDoCookie, value: cookie);

  static Future<void> apagarCookie() async {
    try {
      await _cofre.delete(key: _chaveDoCookie);
    } on PlatformException catch (e) {
      debugPrint('Falha ao apagar o cookie do cofre: ${e.code}');
    }
  }
}
