class Matricula {
  const Matricula._(this.valor);

  factory Matricula.criar(String valor) {
    final normalizado = valor.trim().toLowerCase();
    if (!isValid(normalizado)) {
      throw ArgumentError.value(valor, 'valor', 'Matrícula inválida');
    }
    return Matricula._(normalizado);
  }

  static final RegExp _formato = RegExp(
    r'^(?<ano>\d{4})(?<semestre>[12])(?<curso>[a-z]{2,6})(?<sequencial>\d{3,6})$',
    caseSensitive: false,
  );

  final String valor;

  static bool isValid(String valor) => _formato.hasMatch(valor.trim());

  RegExpMatch get _partes => _formato.firstMatch(valor)!;

  int get ano => int.parse(_partes.namedGroup('ano')!);

  int get semestre => int.parse(_partes.namedGroup('semestre')!);

  String get curso => _partes.namedGroup('curso')!;

  String get sequencial => _partes.namedGroup('sequencial')!;

  String get formatado => valor;
}
