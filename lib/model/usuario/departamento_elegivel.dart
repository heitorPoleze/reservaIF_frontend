class DepartamentoElegivel {
  const DepartamentoElegivel({
    required this.id,
    required this.nome,
    required this.diretoria,
    this.sigla,
  });

  factory DepartamentoElegivel.fromJson(Map<String, dynamic> json) =>
      DepartamentoElegivel(
        id: json['id'] as String,
        nome: json['nome'] as String,
        diretoria: json['diretoria'] as String,
        sigla: json['sigla'] as String?,
      );

  static const String _prefixoDeCurso = 'curso-';

  static const String _prefixoDoNomeDeCurso = 'Coordenadoria do Curso ';

  final String id;

  final String nome;

  final String diretoria;

  final String? sigla;

  bool get ehCoordenadoriaDeCurso => id.startsWith(_prefixoDeCurso);

  String get rotulo => sigla == null ? nome : '$sigla · $nome';

  String get rotuloDeCurso => nome.startsWith(_prefixoDoNomeDeCurso)
      ? nome.substring(_prefixoDoNomeDeCurso.length)
      : nome;

  String get rotuloDeVinculo => ehCoordenadoriaDeCurso ? rotuloDeCurso : rotulo;
}
