import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reserva_if/view/pendencias/tela_pendencias.dart';
import 'package:reserva_if/view/perfil/tela_perfil.dart';
import 'package:reserva_if/view/predio/lista_predios_view.dart';
import 'package:reserva_if/view/principal/widgets/rodape_navegacao.dart';
import 'package:reserva_if/viewmodel/sessao/sessao_viewmodel.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  static const _agendamentos = AbaPrincipal(
    rotulo: 'Agendamentos',
    icone: Icons.calendar_month_outlined,
    iconeSelecionado: Icons.calendar_month,
    pagina: ListaPrediosView(),
  );

  static const _pendencias = AbaPrincipal(
    rotulo: 'Pendências',
    icone: Icons.inventory_2_outlined,
    iconeSelecionado: Icons.inventory_2,
    pagina: TelaPendencias(),
  );

  static const _perfil = AbaPrincipal(
    rotulo: 'Perfil',
    icone: Icons.person_outline,
    iconeSelecionado: Icons.person,
    pagina: TelaPerfil(),
  );

  int _indiceSelecionado = 0;

  List<AbaPrincipal> _abasDo(bool acompanhaPendencias) => [
    _agendamentos,
    if (acompanhaPendencias) _pendencias,
    _perfil,
  ];

  @override
  Widget build(BuildContext context) {
    final acompanhaPendencias = context.select<SessaoViewModel, bool>(
      (sessao) => sessao.usuario?.perfil.acompanhaPendencias ?? false,
    );
    final abas = _abasDo(acompanhaPendencias);
    final indice = _indiceSelecionado.clamp(0, abas.length - 1);

    return Scaffold(
      body: IndexedStack(
        index: indice,
        children: [for (final aba in abas) aba.pagina],
      ),
      bottomNavigationBar: RodapeNavegacao(
        abas: abas,
        indiceSelecionado: indice,
        aoSelecionar: (novo) => setState(() => _indiceSelecionado = novo),
      ),
    );
  }
}
