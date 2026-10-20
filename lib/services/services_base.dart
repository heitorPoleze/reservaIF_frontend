import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:reserva_if/services/http/ambiente.dart';
import 'package:reserva_if/services/http/exceptions/api_exceptions.dart';
import 'package:reserva_if/services/http/mascara_de_log.dart';
import 'package:reserva_if/services/http/requisicao_http.dart';

abstract class BaseService {
  String get baseUrl => Ambiente.urlBase(
        isWeb: kIsWeb,
        platform: defaultTargetPlatform,
      );

  String get recurso;

  Uri get url => rota();

  Uri rota([String caminho = '', Map<String, String>? query]) {
    final sufixo = caminho.isEmpty ? '' : '/$caminho';
    final uri = Uri.parse('$baseUrl/$recurso$sufixo');

    return query == null ? uri : uri.replace(queryParameters: query);
  }

  static String? sessionCookie;

  static void Function()? aoPerderConexao;

  static bool logarCorpoDeSucesso = false;

  static final RegExp _padraoDeFalhaDeRede = RegExp(
    'socketexception|handshakeexception|failed host lookup|'
    'connection refused|connection closed|connection timed out|'
    'network is unreachable|software caused connection abort',
    caseSensitive: false,
  );

  static bool ehFalhaDeConexao(Object erro) {
    if (erro is TimeoutException) return true;
    if (erro is http.ClientException) return true;

    return _padraoDeFalhaDeRede.hasMatch(erro.toString());
  }

  static Future<bool> servidorRespondeu() async {
    try {
      final saude = Ambiente.urlDeSaude(
        isWeb: kIsWeb,
        platform: defaultTargetPlatform,
      );

      await http.get(saude).timeout(const Duration(seconds: 6));

      return true;
    } catch (_) {
      return false;
    }
  }

  Map<String, String> get defaultHeaders {
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };

    if (sessionCookie != null) {
      headers['Cookie'] = sessionCookie!;
    }

    return headers;
  }

  static void atualizarCookie(http.Response response) {
    final rawCookie = response.headers['set-cookie'];

    if (rawCookie == null) {
      debugPrint('O back-end não enviou cookie de sessão nesta resposta.');
      return;
    }

    final fimDoValor = rawCookie.indexOf(';');
    sessionCookie =
        fimDoValor == -1 ? rawCookie : rawCookie.substring(0, fimDoValor);
  }

  bool sucesso(http.Response response) =>
      response.statusCode >= 200 && response.statusCode < 300;

  bool isEmptyList(http.Response response) {
    if (response.statusCode != 404) return false;

    try {
      return jsonDecode(utf8.decode(response.bodyBytes))
          is Map<String, dynamic>;
    } catch (_) {
      return false;
    }
  }

  @protected
  Future<R> executarRequisicao<R>({
    required RequisicaoHttp requisicao,
    required R Function(http.Response resposta) aoSucesso,
    R Function()? aoListaVazia,
    Map<int, R Function()>? resultadosPorStatus,
    Map<int, String>? errosPorStatus,
    required String erroMsg,
    required String acao,
  }) async {
    try {
      final response = await requisicao.enviar(defaultHeaders);

      if (sucesso(response)) {
        _logarSucesso(response, acao);
        return aoSucesso(response);
      }

      final resultadoDeStatus = resultadosPorStatus?[response.statusCode];
      if (resultadoDeStatus != null) return resultadoDeStatus();

      final erroDeStatus = errosPorStatus?[response.statusCode];
      if (erroDeStatus != null) {
        _logarResposta(response, acao);
        throw ApiException(erroDeStatus);
      }

      if (aoListaVazia != null && isEmptyList(response)) {
        _logarListaVazia(response, acao);
        return aoListaVazia();
      }

      _logarResposta(response, acao);

      if (response.statusCode >= 500) {
        throw ErroDoServidorException(
          'O servidor falhou ao $acao. Tente de novo em alguns instantes.',
        );
      }

      tratarErroRequisicao(
        response.bodyBytes,
        fallbackMsg: erroMsg,
        statusCode: response.statusCode,
      );
    } on ApiException catch (e) {
      if (aoListaVazia != null && e.indicaAusenciaDeRegistros) {
        return aoListaVazia();
      }
      rethrow;
    } catch (e, rastro) {
      _logarExcecao(requisicao, acao, e, rastro);

      if (!ehFalhaDeConexao(e)) {
        throw ApiException('Não foi possível $acao. Tente novamente.');
      }

      aoPerderConexao?.call();
      throw _falhaDeConexao(e, requisicao, acao);
    }
  }

  SemConexaoException _falhaDeConexao(
    Object erro,
    RequisicaoHttp requisicao,
    String acao,
  ) {
    if (erro is TimeoutException) return _tempoEsgotado(requisicao, acao);

    return SemConexaoException(
      'Falha na comunicação ao $acao. Tente novamente mais tarde.',
    );
  }

  TempoEsgotadoException _tempoEsgotado(
    RequisicaoHttp requisicao,
    String acao,
  ) {
    final orientacao = requisicao.alteraDados
        ? 'A operação pode ter sido concluída: confira antes de repetir.'
        : 'Tente novamente.';

    return TempoEsgotadoException(
      'O servidor demorou a responder ao $acao. $orientacao',
      podeTerSidoConcluida: requisicao.alteraDados,
    );
  }

  void _logarResposta(http.Response response, String acao) {
    if (!kDebugMode) return;

    final requisicao = response.request;
    final enviado = _corpoEnviado(requisicao);
    final corpo = utf8.decode(response.bodyBytes, allowMalformed: true);

    debugPrint('[API] ${requisicao?.method} ${requisicao?.url}');
    if (enviado != null) debugPrint('[API] enviado: $enviado');
    debugPrint('[API] falha ao $acao | status: ${response.statusCode}');
    debugPrint(
      '[API] corpo: ${corpo.isEmpty ? '<vazio>' : MascaraDeLog.aplicar(corpo)}',
    );
  }

  void _logarListaVazia(http.Response response, String acao) {
    if (!kDebugMode) return;

    final requisicao = response.request;

    debugPrint('[API] ${requisicao?.method} ${requisicao?.url} '
        '| $acao | sem registros (status ${response.statusCode})');
  }

  void _logarSucesso(http.Response response, String acao) {
    if (!kDebugMode || !logarCorpoDeSucesso) return;

    final requisicao = response.request;
    final enviado = _corpoEnviado(requisicao);

    debugPrint('[API] ${requisicao?.method} ${requisicao?.url} '
        '| $acao | status: ${response.statusCode}');
    if (enviado != null) debugPrint('[API] enviado: $enviado');
  }

  String? _corpoEnviado(http.BaseRequest? requisicao) {
    if (requisicao is! http.Request) return null;

    final corpo = requisicao.body;

    return corpo.isEmpty ? null : MascaraDeLog.aplicar(corpo);
  }

  void _logarExcecao(
    RequisicaoHttp requisicao,
    String acao,
    Object erro,
    StackTrace rastro,
  ) {
    if (!kDebugMode) return;

    debugPrint(
      '[API] ${requisicao.verbo.name.toUpperCase()} ${requisicao.rota}',
    );
    debugPrint('[API] exceção ao $acao | ${erro.runtimeType}: $erro');
    debugPrint('$rastro');
  }

  Never tratarErroRequisicao(
    List<int> bodyBytes, {
    String fallbackMsg = 'Erro na requisição.',
    int? statusCode,
  }) {
    try {
      final jsonResponse = jsonDecode(utf8.decode(bodyBytes));

      if (jsonResponse is Map<String, dynamic>) {
        final erros = jsonResponse['erros'] ?? jsonResponse['errors'];

        if (erros is List) {
          final mensagens = erros
              .map((erro) => erro is Map ? erro['msg'] ?? erro['message'] : erro)
              .whereType<Object>()
              .map((mensagem) => '• $mensagem')
              .toList();

          throw ApiValidationException([fallbackMsg, ...mensagens]);
        }

        final mensagemDoBackend = jsonResponse['mensagem'] ??
            jsonResponse['message'] ??
            jsonResponse['error'] ??
            jsonResponse['erro'];

        if (mensagemDoBackend != null) {
          throw ApiException('$fallbackMsg\n$mensagemDoBackend');
        }
      }

      _logarFalha(fallbackMsg, statusCode);
      throw ApiException(fallbackMsg);
    } on ApiException {
      rethrow;
    } catch (e) {
      _logarFalha(fallbackMsg, statusCode, e);
      throw ApiException(fallbackMsg);
    }
  }

  void _logarFalha(String fallbackMsg, int? statusCode, [Object? erro]) {
    debugPrint('[API] $fallbackMsg | status: ${statusCode ?? '-'}'
        '${erro == null ? '' : ' | $erro'}');
  }

  dynamic extrairDadosResposta(List<int> bodyBytes) {
    final jsonResponse = jsonDecode(utf8.decode(bodyBytes));

    if (jsonResponse is Map<String, dynamic> &&
        jsonResponse.containsKey('data')) {
      return jsonResponse['data'];
    }

    return jsonResponse;
  }

  T extrairObjeto<T>(
    List<int> bodyBytes,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final dados = extrairDadosResposta(bodyBytes);

    if (dados is! Map<String, dynamic>) {
      throw ApiException('Formato de resposta inválido.');
    }

    return fromJson(dados);
  }

  T? extrairObjetoOuNulo<T>(
    List<int> bodyBytes,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (bodyBytes.isEmpty) return null;

    final dados = extrairDadosResposta(bodyBytes);

    if (dados is Map<String, dynamic> && dados['id'] != null) {
      return fromJson(dados);
    }

    return null;
  }

  List<T> extrairLista<T>(
    List<int> bodyBytes,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final dados = extrairDadosResposta(bodyBytes);

    if (dados is! List) return const [];

    return dados.whereType<Map<String, dynamic>>().map(fromJson).toList();
  }

  List<T> extrairListaNomeada<T>(
    List<int> bodyBytes,
    String chave,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final jsonResponse = jsonDecode(utf8.decode(bodyBytes));

    if (jsonResponse is List) {
      return jsonResponse
          .whereType<Map<String, dynamic>>()
          .map(fromJson)
          .toList();
    }

    if (jsonResponse is! Map<String, dynamic>) return const [];

    for (final candidata in [chave, 'data']) {
      final lista = jsonResponse[candidata];

      if (lista is List) {
        return lista.whereType<Map<String, dynamic>>().map(fromJson).toList();
      }
    }

    _logarFalha(
      'Nenhuma lista encontrada sob "$chave" nem "data" no corpo da resposta',
      null,
    );

    return const [];
  }
}

abstract class ServiceExterno extends BaseService {
  @override
  String get baseUrl;

  @override
  Map<String, String> get defaultHeaders =>
      const {'Accept': 'application/json'};
}
