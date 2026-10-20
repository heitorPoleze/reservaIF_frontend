import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:reserva_if/model/predio/predio.dart';
import 'package:reserva_if/model/reserva/horario_do_dia.dart';
import 'package:reserva_if/model/reserva/reserva.dart';
import 'package:reserva_if/model/reserva/status_reserva.dart';
import 'package:reserva_if/model/sala/sala.dart';
import 'package:reserva_if/model/usuario/usuario_resumo.dart';

const _sala = Sala(
  id: 's1',
  nome: 'Lab. 03',
  predio: Predio(id: 'p1', nome: 'Bloco A'),
);

const _aluna = UsuarioResumo(id: 'u1', nome: 'Ana Souza');

final _dia = DateTime(2026, 10, 19);

Reserva _reserva(int hora, StatusReserva status) => Reserva(
  id: 'r$hora',
  sala: _sala,
  solicitante: _aluna,
  responsavel: _aluna,
  inicio: DateTime(2026, 10, 19, hora),
  fim: DateTime(2026, 10, 19, hora, 50),
  finalidade: 'Monitoria',
  status: status,
);

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  test('gera 15 faixas de 50 minutos, das 07:00 às 21:50', () {
    final horarios = HorarioDoDia.doDia(_dia, const []);

    expect(horarios, hasLength(15));
    expect(horarios.first.faixaFormatada, '07:00 – 07:50');
    expect(horarios.last.faixaFormatada, '21:00 – 21:50');
    expect(horarios.every((horario) => horario.livre), isTrue);
  });

  test('reserva ativa ocupa a faixa que sobrepõe', () {
    final reserva = _reserva(14, StatusReserva.agendada);

    final horarios = HorarioDoDia.doDia(_dia, [reserva]);
    final dasQuatorze = horarios.singleWhere((h) => h.inicio.hour == 14);

    expect(dasQuatorze.reserva, same(reserva));
    expect(dasQuatorze.situacao(agora: DateTime(2026, 10, 18)), 'Reservado');
    expect(horarios.where((h) => !h.livre), hasLength(1));
  });

  test('pendente ocupa a faixa; terminal libera', () {
    final horarios = HorarioDoDia.doDia(_dia, [
      _reserva(8, StatusReserva.pendente),
      _reserva(9, StatusReserva.cancelada),
      _reserva(10, StatusReserva.rejeitada),
    ]);

    expect(horarios.singleWhere((h) => h.inicio.hour == 8).livre, isFalse);
    expect(horarios.singleWhere((h) => h.inicio.hour == 9).livre, isTrue);
    expect(horarios.singleWhere((h) => h.inicio.hour == 10).livre, isTrue);
  });

  test('reserva de outro dia não ocupa', () {
    final horarios = HorarioDoDia.doDia(DateTime(2026, 10, 20), [
      _reserva(14, StatusReserva.aprovada),
    ]);

    expect(horarios.every((horario) => horario.livre), isTrue);
  });

  test('faixa livre que já começou fica encerrada e não é reservável', () {
    final horario = HorarioDoDia.doDia(_dia, const []).first;
    final depois = DateTime(2026, 10, 19, 7, 10);

    expect(horario.reservavel(agora: depois), isFalse);
    expect(horario.situacao(agora: depois), 'Encerrado');
    expect(horario.reservavel(agora: DateTime(2026, 10, 19, 6)), isTrue);
    expect(horario.situacao(agora: DateTime(2026, 10, 19, 6)), 'Livre');
  });

  test('diaFormatado traz o dia da semana e o dia do mês', () {
    expect(
      HorarioDoDia.doDia(_dia, const []).first.diaFormatado,
      'Segunda-feira, 19 de outubro',
    );
  });
}
