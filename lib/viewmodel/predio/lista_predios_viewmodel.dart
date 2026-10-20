import 'package:flutter/foundation.dart';
import 'package:reserva_if/model/predio/predio.dart';
import 'package:reserva_if/services/services_predio.dart';
import 'package:reserva_if/viewmodel/estado_de_carga.dart';
import 'package:reserva_if/viewmodel/notifica_se_vivo_mixin.dart';

class ListaPrediosViewModel extends ChangeNotifier
    with NotificaSeVivoMixin, EstadoDeCarregamentoMixin {
  ListaPrediosViewModel({required this._service});

  final ServicesPredio _service;

  List<Predio> _predios = const [];

  List<Predio> get predios => _predios;

  Future<void> carregar() {
    if (isLoading) return Future.value();

    return cargaPrincipal.executar(
      chamada: () async => _predios = await _service.buscarTodos(),
      aoFalhar: () {},
    );
  }
}
