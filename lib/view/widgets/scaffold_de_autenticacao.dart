import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reserva_if/view/theme/app_cores.dart';
import 'package:reserva_if/view/theme/app_tema.dart';
import 'package:reserva_if/view/widgets/app_bar_padrao.dart';

class ScaffoldDeAutenticacao extends StatelessWidget {
  final Widget corpo;

  const ScaffoldDeAutenticacao({super.key, required this.corpo});

  @override
  Widget build(BuildContext context) {
    final podeVoltar = ModalRoute.of(context)?.canPop ?? false;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTema.barraDeStatusSobreClaro,
      child: Scaffold(
        backgroundColor: AppCores.fundoAuth,
        appBar: podeVoltar
            ? const AppBarPadrao(cor: AppCores.fundoAuth, elevacao: 0)
            : null,
        body: SafeArea(child: corpo),
      ),
    );
  }
}
