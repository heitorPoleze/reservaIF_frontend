import '../usuario/perfil.dart';

class SessaoAutenticada {
  const SessaoAutenticada({
    required this.uuid,
    required this.perfil,
    required this.token,
  });

  factory SessaoAutenticada.fromJson(Map<String, dynamic> json) =>
      SessaoAutenticada(
        uuid: json['uuid'] as String,
        perfil: Perfil.fromNivelAcesso(json['nivelAcesso']),
        token: json['token'] as String,
      );

  final String uuid;

  final Perfil perfil;

  final String token;
}
