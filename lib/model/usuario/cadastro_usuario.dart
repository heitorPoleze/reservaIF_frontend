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

  TipoCredencial get tipoCredencial {
    final tipo = perfil.tipoCredencial;
    if (tipo == null) {
      throw StateError('O perfil ${perfil.rotulo} não tem cadastro aberto');
    }
    return tipo;
  }

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

  Map<String, dynamic> toJson() => {
    'nome': nome.trim(),
    'email': email.trim().toLowerCase(),
    if (_telefoneInformado != null) 'telefone': _telefoneInformado,
    'tipoCredencial': tipoCredencial.toJson(),
    'credencial': credencial.toJson(),
    if (perfil != Perfil.aluno) 'departamentoId': _departamentoId,
  };
}
