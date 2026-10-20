import 'perfil.dart';
import 'tipo_credencial.dart';
import 'usuario_resumo.dart';

class PerfilUsuario {
  const PerfilUsuario({
    required this.uuid,
    required this.nome,
    required this.email,
    this.telefone,
    required this.perfil,
    required this.tipoCredencial,
    required this.identificador,
    required this.ativo,
  });

  factory PerfilUsuario.fromJson(Map<String, dynamic> json) => PerfilUsuario(
    uuid: json['uuid'] as String,
    nome: json['nome'] as String,
    email: json['email'] as String,
    telefone: json['telefone'] as String?,
    perfil: Perfil.fromJson(json['role']),
    tipoCredencial: TipoCredencial.fromJson(json['tipoCredencial']),
    identificador: json['identificador'] as String,
    ativo: json['ativo'] as bool,
  );

  final String uuid;

  final String nome;

  final String email;

  final String? telefone;

  final Perfil perfil;

  final TipoCredencial tipoCredencial;

  final String identificador;

  final bool ativo;

  bool get podeAprovar => perfil.podeAprovar;

  String get identificadorFormatado =>
      '${perfil.identificador.rotulo} $identificador';

  bool get solicitaCancelamentoDeAluno => perfil.solicitaCancelamentoDeAluno;

  UsuarioResumo get resumo =>
      UsuarioResumo(id: uuid, nome: nome, tipoCredencial: tipoCredencial);

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'nome': nome,
    'email': email,
    if (telefone != null) 'telefone': telefone,
    'nivelAcesso': perfil.nivelAcesso,
    'role': perfil.toJson(),
    'tipoCredencial': tipoCredencial.toJson(),
    'identificador': identificador,
    'ativo': ativo,
  };
}
