import 'dart:convert';

import '../model/usuario/credencial/tipo_entrada.dart';
import '../model/usuario/matricula.dart';
import '../model/usuario/siape.dart';

class Validator {
  static const int minimoCaracteresNome = 3;

  static const int maximoCaracteresNome = 100;

  static const int minimoCaracteresSenha = 8;

  static const int maximoBytesSenha = 72;

  static const int minimoCaracteresDescricao = 3;

  static const int maximoCaracteresDescricao = 255;

  static final RegExp _regexEmail = RegExp(
    r"^[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+)*"
    r'@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?'
    r'(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$',
  );

  static final RegExp _regexEmoji = RegExp(
    r'[\u{1F1E6}-\u{1F1FF}\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}\u{2B00}-\u{2BFF}\u{FE0F}\u{200D}]',
    unicode: true,
  );

  static bool emailValido(String valor) => _regexEmail.hasMatch(valor.trim());

  static String? obrigatorio(String? value, [String? mensagem]) {
    if (value == null || value.trim().isEmpty) {
      return mensagem ?? 'Obrigatório';
    }
    return null;
  }

  static String? selecaoObrigatoria(Object? valor) =>
      valor == null ? 'Obrigatório' : null;

  static String? validarEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (!emailValido(value)) {
      return 'Digite um e-mail válido';
    }
    return null;
  }

  static String? validarEmailObrigatorio(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'O e-mail é obrigatório';
    }
    return validarEmail(value);
  }

  static String? validarTelefone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (!RegExp(r'^[\d\s()+-]+$').hasMatch(value.trim())) {
      return 'Informe um telefone válido com DDD';
    }

    final digitos = value.replaceAll(RegExp(r'\D'), '');
    if (digitos.length != 10 && digitos.length != 11) {
      return 'Informe um telefone válido com DDD';
    }

    return null;
  }

  static String? validarSiape(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'O SIAPE é obrigatório';
    }
    if (!Siape.isValid(value)) {
      return 'Informe um SIAPE válido';
    }
    return null;
  }

  static String? validarMatricula(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'A matrícula é obrigatória';
    }
    if (!Matricula.isValid(value)) {
      return 'Informe uma matrícula válida';
    }
    return null;
  }

  static String? Function(String?) validarIdentificador(TipoEntrada tipo) =>
      switch (tipo) {
        TipoEntrada.matricula => validarMatricula,
        TipoEntrada.siape => validarSiape,
      };

  static String? validarEntradaDeLogin(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe sua matrícula ou SIAPE';
    }
    if (TipoEntrada.inferir(value.trim()) == null) {
      return 'Informe uma matrícula ou um SIAPE válidos';
    }
    return null;
  }

  static String? validarSenhaLogin(String? value) {
    if (value == null || value.isEmpty) {
      return 'A senha é obrigatória';
    }
    return null;
  }

  static String? validarSenha(String? value) {
    if (value == null || value.isEmpty) {
      return 'A senha é obrigatória';
    }
    if (value.length < minimoCaracteresSenha) {
      return 'A senha deve ter no mínimo $minimoCaracteresSenha caracteres';
    }
    if (_regexEmoji.hasMatch(value)) {
      return 'A senha não pode conter emojis';
    }
    if (utf8.encode(value).length > maximoBytesSenha) {
      return 'A senha está longa demais';
    }
    return null;
  }

  static String? validarConfirmacaoSenha(
    String? senhaConfirmada,
    String? senhaOriginal,
  ) {
    if (senhaConfirmada == null || senhaConfirmada.isEmpty) {
      return 'Confirme sua senha';
    }
    if (senhaConfirmada != senhaOriginal) {
      return 'As senhas não coincidem';
    }
    return null;
  }

  static String? validarNome(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'O nome é obrigatório';
    }
    final nome = value.trim();
    if (nome.length < minimoCaracteresNome) {
      return 'O nome deve conter pelo menos $minimoCaracteresNome caracteres';
    }
    if (nome.length > maximoCaracteresNome) {
      return 'O nome deve ter no máximo $maximoCaracteresNome caracteres';
    }
    return null;
  }

  static String? descricaoObrigatoria(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Obrigatório';
    }
    return _tamanhoDaDescricao(value.trim());
  }

  static String? descricaoOpcional(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return _tamanhoDaDescricao(value.trim());
  }

  static String? inteiroPositivo(String? value, [String? mensagem]) {
    if (value == null || value.trim().isEmpty) {
      return mensagem ?? 'Obrigatório';
    }
    final numero = int.tryParse(value.trim());
    if (numero == null) {
      return 'Valor inválido';
    }
    if (numero <= 0) {
      return 'Informe um valor maior que zero';
    }
    return null;
  }

  static String? _tamanhoDaDescricao(String texto) {
    if (texto.length < minimoCaracteresDescricao) {
      return 'Descreva com pelo menos $minimoCaracteresDescricao caracteres';
    }
    if (texto.length > maximoCaracteresDescricao) {
      return 'A descrição deve ter no máximo $maximoCaracteresDescricao caracteres';
    }
    return null;
  }
}
