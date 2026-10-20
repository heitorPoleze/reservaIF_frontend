T enumDoJson<T extends Enum>(
  List<T> valores,
  Object Function(T) valorJson,
  Object? json,
) =>
    valores.firstWhere(
      (valor) => valorJson(valor) == json,
      orElse: () => throw ArgumentError.value(
        json,
        'json',
        'Valor desconhecido para $T',
      ),
    );
