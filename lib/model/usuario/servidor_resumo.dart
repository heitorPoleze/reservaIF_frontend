import 'perfil.dart';
import 'usuario_resumo.dart';

class ServidorResumo {
  const ServidorResumo({
    required this.id,
    required this.nome,
    required this.perfil,
  });

  factory ServidorResumo.fromJson(Map<String, dynamic> json) => ServidorResumo(
        id: json['id'] as String,
        nome: json['nome'] as String,
        perfil: Perfil.fromJson(json['role']),
      );

  final String id;

  final String nome;

  final Perfil perfil;

  UsuarioResumo get resumo => UsuarioResumo(id: id, nome: nome);
}
