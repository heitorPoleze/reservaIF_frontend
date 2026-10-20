import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:reserva_if/services/http/ambiente.dart';
import 'package:reserva_if/services/services_autenticacao.dart';
import 'package:reserva_if/services/services_base.dart';
import 'package:reserva_if/services/services_usuario.dart';
import 'package:reserva_if/services/sessao/repositorio_de_sessao.dart';
import 'package:reserva_if/view/sessao/raiz_do_app.dart';
import 'package:reserva_if/view/theme/app_tema.dart';
import 'package:reserva_if/view/widgets/tela_sem_conexao.dart';
import 'package:reserva_if/viewmodel/sessao/sessao_viewmodel.dart';
import 'package:reserva_if/viewmodel/status_de_conexao.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);

  if (kDebugMode) {
    final urlBase = Ambiente.urlBase(
      isWeb: kIsWeb,
      platform: defaultTargetPlatform,
    );
    debugPrint('[API] alvo: ${Ambiente.alvoEfetivo.name} | base: $urlBase');
  }

  final statusDeConexao = StatusDeConexao();
  BaseService.aoPerderConexao = statusDeConexao.registrarFalha;

  final sessao = SessaoViewModel(
    autenticacao: ServicesAutenticacao(),
    usuarios: ServicesUsuario(),
    repositorio: RepositorioDeSessaoLocal(),
  );
  BaseService.aoSessaoExpirar = sessao.encerrarPorExpiracao;
  unawaited(sessao.restaurar());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<StatusDeConexao>.value(value: statusDeConexao),
        ChangeNotifierProvider<SessaoViewModel>.value(value: sessao),
      ],
      child: const ReservaIfApp(),
    ),
  );
}

class ReservaIfApp extends StatelessWidget {
  const ReservaIfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ReservaIF',
      theme: AppTema.claro,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
      builder: (context, child) => GuardaDeConexao(filho: child!),
      home: const RaizDoApp(),
    );
  }
}
