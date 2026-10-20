class Endereco {
  const Endereco({
    required this.rua,
    required this.numero,
    required this.bairro,
    required this.cep,
  });

  factory Endereco.fromJson(Map<String, dynamic> json) => Endereco(
        rua: json['rua'] as String,
        numero: json['numero'] as int,
        bairro: json['bairro'] as String,
        cep: json['cep'] as String,
      );

  static Endereco? fromJsonOpcional(Object? json) =>
      json == null ? null : Endereco.fromJson(json as Map<String, dynamic>);

  final String rua;

  final int numero;

  final String bairro;

  final String cep;

  String get formatado => '$rua, $numero - $bairro';

  Map<String, dynamic> toJson() => {
        'rua': rua,
        'numero': numero,
        'bairro': bairro,
        'cep': cep,
      };
}
