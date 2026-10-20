import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reserva_if/view/telas/tela_cadastro.dart';
import 'package:reserva_if/view/telas/tela_inicial.dart';
import 'package:reserva_if/view/telas/tela_login.dart';
import 'package:reserva_if/view/telas/tela_principal.dart';
import 'package:reserva_if/view/widgets/tela_de_abertura.dart';
import 'package:reserva_if/viewmodel/sessao/sessao_viewmodel.dart';

class RaizDoApp extends StatefulWidget {
  const RaizDoApp({super.key});

  @override
  State<RaizDoApp> createState() => _RaizDoAppState();
}

class _RaizDoAppState extends State<RaizDoApp> {
  late final SessaoViewModel _sessao = context.read<SessaoViewModel>();
  late EstadoDaSessao _estadoAnterior = _sessao.estado;

  @override
  void initState() {
    super.initState();
    _sessao.addListener(_aoMudarSessao);
  }

  @override
  void dispose() {
    _sessao.removeListener(_aoMudarSessao);
    super.dispose();
  }

  void _aoMudarSessao() {
    final atual = _sessao.estado;
    final trocouDeLado =
        atual != _estadoAnterior &&
        atual != EstadoDaSessao.inicializando &&
        _estadoAnterior != EstadoDaSessao.inicializando;
    _estadoAnterior = atual;

    if (!trocouDeLado || !mounted) return;

    Navigator.of(context).popUntil((rota) => rota.isFirst);
  }

  void _abrirLogin() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const TelaLogin()));
  }

  void _abrirCadastro() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const TelaCadastro()));
  }

  @override
  Widget build(BuildContext context) {
    final sessao = context.watch<SessaoViewModel>();

    return switch (sessao.estado) {
      EstadoDaSessao.inicializando => const TelaDeAbertura(),
      EstadoDaSessao.deslogado => TelaInicialDeslogada(
        aoEntrar: _abrirLogin,
        aoCadastrar: _abrirCadastro,
      ),
      EstadoDaSessao.logado => KeyedSubtree(
        key: ValueKey(sessao.usuario!.uuid),
        child: const TelaPrincipal(),
      ),
    };
  }
}
