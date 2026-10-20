import 'package:flutter/foundation.dart';
import 'package:reserva_if/model/usuario/cadastro_usuario.dart';
import 'package:reserva_if/model/usuario/departamento_elegivel.dart';
import 'package:reserva_if/model/usuario/perfil.dart';
import 'package:reserva_if/services/services_usuario.dart';
import 'package:reserva_if/viewmodel/estado_de_carga.dart';
import 'package:reserva_if/viewmodel/notifica_se_vivo_mixin.dart';

class CadastroViewModel extends ChangeNotifier
    with NotificaSeVivoMixin, EstadoDeCarregamentoMixin {
  CadastroViewModel({required this._service});

  final ServicesUsuario _service;

  late final EstadoDeCarga _cargaDepartamentos = EstadoDeCarga(
    aoMudar: notificarSeVivo,
  );

  Perfil _perfil = Perfil.aluno;
  String? _vinculoId;
  List<DepartamentoElegivel> _departamentos = const [];

  Perfil get perfil => _perfil;

  String? get vinculoId => _vinculoId;

  bool get podeEnviar => _perfil.cadastroDisponivel;

  bool get isCarregandoVinculos => _cargaDepartamentos.isLoading;

  String? get mensagemErroVinculos => _cargaDepartamentos.mensagemErro;

  List<DepartamentoElegivel> get opcoesDeVinculo => _departamentos
      .where((item) => !item.ehCoordenadoriaDeCurso)
      .toList(growable: false);

  Future<void> carregarDepartamentos() {
    if (_cargaDepartamentos.isLoading) return Future.value();

    return _cargaDepartamentos.executar(
      chamada: () async =>
          _departamentos = await _service.buscarDepartamentosElegiveis(),
      aoFalhar: () {},
    );
  }

  void selecionarPerfil(Perfil novo) {
    if (novo == _perfil) return;

    if (novo == Perfil.aluno || _perfil == Perfil.aluno) _vinculoId = null;
    _perfil = novo;
    notificarSeVivo();
  }

  void selecionarVinculo(String? id) {
    _vinculoId = id;
    notificarSeVivo();
  }

  Future<bool> cadastrar({
    required String nome,
    required String email,
    required String telefone,
    required String identificador,
    required String senha,
  }) async {
    final vinculo = _vinculoId;
    final cadastroDeServidor = _perfil != Perfil.aluno;
    if (isLoading || !podeEnviar || (cadastroDeServidor && vinculo == null)) {
      return false;
    }

    final cadastro = CadastroUsuario(
      perfil: _perfil,
      nome: nome,
      email: email,
      telefone: telefone,
      identificador: identificador,
      senha: senha,
      vinculoId: cadastroDeServidor ? vinculo : null,
    );

    return cargaPrincipal.executar(
      chamada: () async {
        await _service.cadastrar(cadastro);
        return true;
      },
      aoFalhar: () => false,
    );
  }
}
