import '../usuario/perfil_usuario.dart';

class SessaoGuardada {
  const SessaoGuardada({required this.token, required this.usuario});

  final String token;

  final PerfilUsuario usuario;
}
