import 'package:flutter_test/flutter_test.dart';
import 'package:reserva_if/model/predio/predio.dart';
import 'package:reserva_if/model/reserva/conflito_de_horario.dart';
import 'package:reserva_if/model/reserva/reserva.dart';
import 'package:reserva_if/model/reserva/solicitacao_cancelamento.dart';
import 'package:reserva_if/model/reserva/status_solicitacao_cancelamento.dart';
import 'package:reserva_if/model/sala/sala.dart';
import 'package:reserva_if/model/usuario/perfil.dart';
import 'package:reserva_if/model/usuario/servidor_resumo.dart';
import 'package:reserva_if/model/usuario/usuario_resumo.dart';

const _aluno = UsuarioResumo(id: 'a1', nome: 'Raquel Souza');

final _reserva = Reserva(
  id: 'r1',
  sala: const Sala(
    id: 's1',
    nome: 'Sala 02',
    predio: Predio(id: 'p1', nome: 'PP'),
    capacidade: 40,
  ),
  solicitante: _aluno,
  responsavel: _aluno,
  inicio: DateTime(2026, 11, 1, 7, 20),
  fim: DateTime(2026, 11, 1, 9, 20),
  finalidade: 'Estudo',
);

SolicitacaoCancelamento _solicitacao({String? id}) => SolicitacaoCancelamento(
  id: id,
  reservaId: 'r1',
  solicitadoPorId: 'p9',
  justificativa: 'Aula necessária para prova.',
  criadoEm: DateTime(2026, 10, 20),
);

void main() {
  group('SolicitacaoCancelamento', () {
    test('fromJson lê os campos do contrato', () {
      final solicitacao = SolicitacaoCancelamento.fromJson({
        'id': 'sol1',
        'tipo': 'SOLICITACAO_CANCELAMENTO',
        'reservaId': 'r1',
        'solicitadoPorId': 'p9',
        'justificativa': 'Prova.',
        'finalidade': 'Avaliação',
        'status': 'PENDENTE',
        'criadoEm': '2026-10-20T14:00:00.000Z',
      });

      expect(solicitacao.id, 'sol1');
      expect(solicitacao.finalidade, 'Avaliação');
      expect(solicitacao.status, StatusSolicitacaoCancelamento.pendente);
      expect(solicitacao.criadoEm.isUtc, isFalse);
    });

    test('sem id, a decisão usa o id da reserva', () {
      expect(_solicitacao(id: 'sol1').idParaDecisao, 'sol1');
      expect(_solicitacao().idParaDecisao, 'r1');
    });
  });

  group('ConflitoDeHorario', () {
    test('formata título, sala e horário', () {
      final conflito = ConflitoDeHorario(
        solicitacao: _solicitacao(),
        reserva: _reserva,
        professor: const ServidorResumo(
          id: 'p9',
          nome: 'Bruno Ratto',
          perfil: Perfil.professor,
        ),
      );

      expect(conflito.titulo, 'Raquel Souza X Bruno Ratto');
      expect(conflito.rotuloDoAluno, 'Aluno');
      expect(conflito.rotuloDoProfessor, 'Professor');
      expect(conflito.salaComCapacidade, 'Sala 02 · PP · 40 lugares');
      expect(conflito.horarioComData, contains('01/11/2026'));
      expect(conflito.justificativa, 'Aula necessária para prova.');
    });

    test('professor ausente da lista de servidores vira rótulo neutro', () {
      final conflito = ConflitoDeHorario(
        solicitacao: _solicitacao(),
        reserva: _reserva,
      );

      expect(conflito.nomeDoProfessor, 'Professor');
      expect(conflito.titulo, 'Raquel Souza X Professor');
    });
  });
}
