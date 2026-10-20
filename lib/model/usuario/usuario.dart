import 'aluno.dart';
import 'coordenacao.dart';
import 'perfil.dart';
import 'professor.dart';
import 'tecnico.dart';

abstract class Usuario {
  const Usuario({
    this.id,
    required this.nome,
    this.email,
    this.telefone,
    required this.perfil,
  });

  Usuario.deJson(Map<String, dynamic> json, this.perfil)
      : id = json['id'] as String?,
        nome = json['nome'] as String,
        email = json['email'] as String?,
        telefone = json['telefone'] as String?;

  final String? id;

  final String nome;

  final String? email;

  final String? telefone;

  final Perfil perfil;

  bool get podeAprovar => perfil.podeAprovar;

  static Usuario fromJson(Map<String, dynamic> json) =>
      switch (Perfil.fromJson(json['perfil'])) {
        Perfil.aluno => Aluno.fromJson(json),
        Perfil.tecnico => Tecnico.fromJson(json),
        Perfil.professor => Professor.fromJson(json),
        Perfil.coordenador => Coordenacao.fromJson(json),
      };

  Map<String, dynamic> toJson() => {
        'nome': nome,
        if (email != null) 'email': email,
        if (telefone != null) 'telefone': telefone,
        'perfil': perfil.toJson(),
      };
}
