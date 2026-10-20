import '../matricula.dart';
import 'tipo_entrada.dart';

class Credencial {
  const Credencial._({
    required this.tipoEntrada,
    required this.entrada,
    required this.senha,
  });

  factory Credencial.criar({required String entrada, required String senha}) {
    final tipoEntrada = TipoEntrada.inferir(entrada);
    if (tipoEntrada == null) {
      throw ArgumentError.value(
        entrada,
        'entrada',
        'Informe uma matrícula ou um SIAPE',
      );
    }
    return Credencial._(
      tipoEntrada: tipoEntrada,
      entrada: _normalizar(entrada, tipoEntrada),
      senha: senha,
    );
  }

  static const int tipoEntradaLocal = 0;

  final TipoEntrada tipoEntrada;

  final String entrada;

  final String senha;

  static String _normalizar(String entrada, TipoEntrada tipoEntrada) =>
      switch (tipoEntrada) {
        TipoEntrada.siape => entrada.trim(),
        TipoEntrada.matricula => Matricula.criar(entrada).valor,
      };

  Credencial copyWith({String? entrada, String? senha}) => Credencial.criar(
        entrada: entrada ?? this.entrada,
        senha: senha ?? this.senha,
      );

  Map<String, dynamic> toJson() => {
        'tipoEntrada': tipoEntradaLocal,
        'entrada': entrada,
        'senha': senha,
      };
}
