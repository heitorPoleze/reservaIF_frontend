import 'package:flutter/material.dart';
import 'package:reserva_if/model/predio/predio.dart';
import 'package:reserva_if/services/services_predio.dart';
import 'package:reserva_if/view/predio/salas_do_predio_view.dart';
import 'package:reserva_if/view/predio/widgets/card_predio.dart';
import 'package:reserva_if/view/widgets/app_bar_padrao.dart';
import 'package:reserva_if/view/widgets/corpo_com_estado.dart';
import 'package:reserva_if/view/widgets/estados.dart';
import 'package:reserva_if/viewmodel/predio/lista_predios_viewmodel.dart';

class ListaPrediosView extends StatefulWidget {
  const ListaPrediosView({super.key});

  @override
  State<ListaPrediosView> createState() => _ListaPrediosViewState();
}

class _ListaPrediosViewState extends State<ListaPrediosView> {
  late final ListaPrediosViewModel _viewModel = ListaPrediosViewModel(
    service: ServicesPredio(),
  );

  @override
  void initState() {
    super.initState();
    _viewModel.carregar();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _abrirSalas(Predio predio) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SalasDoPredioView(predio: predio),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarPadrao(titulo: 'Agendamentos'),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) => RefreshIndicator(
          onRefresh: _viewModel.carregar,
          child: CorpoComEstado(
            isLoading: _viewModel.isLoading,
            mensagemErro: _viewModel.mensagemErro,
            vazio: _viewModel.predios.isEmpty,
            manterConteudoAoRecarregar: true,
            aoTentarNovamente: _viewModel.carregar,
            construirVazio: (_) => const EstadoVazio(
              mensagem: 'Nenhum prédio cadastrado.',
              icone: Icons.domain_disabled_outlined,
            ),
            construirConteudo: (_) => _ListaDePredios(
              predios: _viewModel.predios,
              aoSelecionar: _abrirSalas,
            ),
          ),
        ),
      ),
    );
  }
}

class _ListaDePredios extends StatelessWidget {
  final List<Predio> predios;
  final ValueChanged<Predio> aoSelecionar;

  const _ListaDePredios({required this.predios, required this.aoSelecionar});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      itemCount: predios.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final predio = predios[index];
        return CardPredio(
          nome: predio.nome,
          aoTocar: () => aoSelecionar(predio),
        );
      },
    );
  }
}
