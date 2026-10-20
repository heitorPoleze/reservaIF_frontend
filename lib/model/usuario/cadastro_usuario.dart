import 'credencial/credencial.dart';
import 'perfil.dart';
import 'tipo_credencial.dart';

class CadastroUsuario {
  const CadastroUsuario({
    required this.perfil,
    required this.nome,
    required this.email,
    this.telefone,
    required this.identificador,
    required this.senha,
    this.vinculoId,
  });

  final Perfil perfil;

  final String nome;

  final String email;

  final String? telefone;

  final String identificador;

  final String senha;

  final String? vinculoId;

  bool get exigeProvisionamento => perfil.exigeProvisionamento;

  TipoCredencial get tipoCredencial => perfil.tipoCredencial;

  Credencial get credencial =>
      Credencial.criar(entrada: identificador, senha: senha);

  String get _departamentoId {
    final id = vinculoId;
    if (id == null) {
      throw StateError('Selecione um departamento para o cadastro.');
    }
    return id;
  }

  String? get _telefoneInformado {
    final valor = telefone?.trim();
    return valor == null || valor.isEmpty ? null : valor;
  }

  Map<String, dynamic> get _dadosPessoais => {
    'nome': nome.trim(),
    'email': email.trim().toLowerCase(),
    if (_telefoneInformado != null) 'telefone': _telefoneInformado,
  };

  Map<String, dynamic> toJson() =>
      perfil.coordenaPredio ? _jsonDeCoordenador() : _jsonDeUsuario();

  Map<String, dynamic> _jsonDeUsuario() => {
    ..._dadosPessoais,
    'tipoCredencial': tipoCredencial.toJson(),
    'credencial': credencial.toJson(),
    if (perfil.exigeDepartamento) 'departamentoId': _departamentoId,
  };

  Map<String, dynamic> _jsonDeCoordenador() {
    final credencial = this.credencial;

    return {
      ..._dadosPessoais,
      'siape': credencial.entrada,
      'senha': credencial.senha,
      'departamentoId': _departamentoId,
    };
  }
}
