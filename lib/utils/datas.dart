DateTime apenasData(DateTime data) => DateTime(data.year, data.month, data.day);

DateTime hoje() => apenasData(DateTime.now());

DateTime inicioDoMes(DateTime data) => DateTime(data.year, data.month);

bool ehFutura(DateTime data) => apenasData(data).isAfter(hoje());

bool mesmoDia(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

int diasEntre(DateTime de, DateTime ate) {
  final inicio = DateTime.utc(de.year, de.month, de.day);
  final fim = DateTime.utc(ate.year, ate.month, ate.day);

  return fim.difference(inicio).inDays;
}

int diasAPartirDeHoje(DateTime dia) => diasEntre(hoje(), dia);

DateTime diaSeguinte(DateTime data) =>
    DateTime(data.year, data.month, data.day + 1);

DateTime combinarDataEHora(DateTime dia, int hora, int minuto) =>
    DateTime(dia.year, dia.month, dia.day, hora, minuto);

DateTime? menorData(DateTime? a, DateTime? b) {
  if (a == null) return b;
  if (b == null) return a;

  return a.isBefore(b) ? a : b;
}

DateTime? maiorData(DateTime? a, DateTime? b) {
  if (a == null || b == null) return null;

  return a.isAfter(b) ? a : b;
}

DateTime? lerDataDoJson(dynamic valor) {
  if (valor == null) return null;
  if (valor is DateTime) return valor;

  if (valor is num) {
    return DateTime.fromMillisecondsSinceEpoch(valor.toInt(), isUtc: true);
  }

  return DateTime.tryParse(valor.toString());
}

DateTime? lerInstanteDoJson(dynamic valor) => lerDataDoJson(valor)?.toLocal();

String _comDoisDigitos(int valor) => valor.toString().padLeft(2, '0');

String dataParaJson(DateTime data) =>
    '${data.year.toString().padLeft(4, '0')}'
    '-${_comDoisDigitos(data.month)}-${_comDoisDigitos(data.day)}';

String instanteParaJson(DateTime instante) =>
    instante.toUtc().toIso8601String();
