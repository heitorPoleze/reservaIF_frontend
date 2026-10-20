import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:reserva_if/services/http/ambiente.dart';
import 'package:reserva_if/services/services_base.dart';
import 'package:reserva_if/view/telas/tela_inicial.dart';
import 'package:reserva_if/view/telas/tela_login.dart';
import 'package:reserva_if/view/telas/tela_cadastro.dart';
import 'package:reserva_if/view/telas/tela_principal.dart';
import 'package:reserva_if/view/theme/app_tema.dart';
import 'package:reserva_if/view/widgets/tela_sem_conexao.dart';
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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<StatusDeConexao>.value(value: statusDeConexao),
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
      home: Builder(
        builder: (context) => TelaInicialDeslogada(
          aoEntrar: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => TelaLogin(
                  aoEntrar: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute<void>(
                        builder: (_) => const TelaPrincipal(),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ),
            );
          },
          aoCadastrar: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const TelaCadastro()),
            );
          },
        ),
      ),
    );
  }
}
