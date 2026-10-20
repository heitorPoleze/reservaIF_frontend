import 'package:flutter/foundation.dart';

enum AlvoDaApi { local, producao }

abstract final class Ambiente {
  static const AlvoDaApi alvo = AlvoDaApi.producao;

  static const String prefixoDaApi = '';

  static const String hostProducao = 'https://dev-hack.sysgrano.app';
  static const String hostLocalEmulador = 'http://10.0.2.2:3333';
  static const String hostLocal = 'http://localhost:3333';

  static const String caminhoDeSaude = '/health';

  static const String chaveDeProvisionamento =
      String.fromEnvironment('PROVISION_KEY');

  static AlvoDaApi get alvoEfetivo =>
      kReleaseMode ? AlvoDaApi.producao : alvo;

  static String host({
    required bool isWeb,
    required TargetPlatform platform,
  }) {
    return switch (alvoEfetivo) {
      AlvoDaApi.producao => hostProducao,
      AlvoDaApi.local => (!isWeb && platform == TargetPlatform.android)
          ? hostLocalEmulador
          : hostLocal,
    };
  }

  static String urlBase({
    required bool isWeb,
    required TargetPlatform platform,
  }) =>
      '${host(isWeb: isWeb, platform: platform)}$prefixoDaApi';

  static Uri urlDeSaude({
    required bool isWeb,
    required TargetPlatform platform,
  }) =>
      Uri.parse('${host(isWeb: isWeb, platform: platform)}$caminhoDeSaude');
}
