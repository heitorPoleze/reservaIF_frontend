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
    required this.vinculoId,
  });

  static const int entradaLocal = 0;

  final Perfil perfil;

  final String nome;

  final String email;

  final String? telefone;

  final String identificador;

  final String senha;

  final String vinculoId;

  bool get exigeProvisionamento => perfil.exigeProvisionamento;

  TipoCredencial get tipoCredencial {
    final tipo = perfil.tipoCredencial;
    if (tipo == null) {
      throw StateError('O perfil ${perfil.rotulo} não tem cadastro aberto');
    }
    return tipo;
  }

  String get _chaveDoVinculo => perfil.vinculaCurso ? 'cursoId' : 'departamentoId';

  String? get _telefoneInformado {
    final valor = telefone?.trim();
    return valor == null || valor.isEmpty ? null : valor;
  }

  Map<String, dynamic> toJson() => {
        'nome': nome.trim(),
        'email': email.trim().toLowerCase(),
        if (_telefoneInformado != null) 'telefone': _telefoneInformado,
        'tipoCredencial': tipoCredencial.toJson(),
        'credencial': {
          'tipoEntrada': entradaLocal,
          'entrada': identificador.trim(),
          'senha': senha,
        },
        _chaveDoVinculo: vinculoId,
      };
}
