class Siape {
  const Siape._(this.valor);

  factory Siape.criar(String valor) {
    final normalizado = valor.trim();
    if (!isValid(normalizado)) {
      throw ArgumentError.value(valor, 'valor', 'SIAPE inválido');
    }
    return Siape._(normalizado);
  }

  static final RegExp _formato = RegExp(r'^\d{6,7}$');

  final String valor;

  static bool isValid(String valor) => _formato.hasMatch(valor.trim());

  String get formatado => valor;
}
