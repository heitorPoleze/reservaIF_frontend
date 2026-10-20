import '../../utils/formatacao.dart';
import '../usuario/perfil.dart';
import '../usuario/servidor_resumo.dart';
import 'reserva.dart';
import 'solicitacao_cancelamento.dart';

class ConflitoDeHorario {
  const ConflitoDeHorario({
    required this.solicitacao,
    required this.reserva,
    this.professor,
  });

  final SolicitacaoCancelamento solicitacao;

  final Reserva reserva;

  final ServidorResumo? professor;

  String get nomeDoAluno => reserva.solicitante.nome;

  String get rotuloDoAluno => Perfil.aluno.rotulo;

  String get nomeDoProfessor => professor?.nome ?? Perfil.professor.rotulo;

  String get rotuloDoProfessor =>
      (professor?.perfil ?? Perfil.professor).rotulo;

  String get titulo => '$nomeDoAluno X $nomeDoProfessor';

  String get salaComCapacidade =>
      '${reserva.sala.nomeComPredio} · ${reserva.sala.capacidadeFormatada}';

  String get horarioComData =>
      '${reserva.horarioFormatado} | ${formatarDataBr(reserva.inicio)}';

  String get justificativa => solicitacao.justificativa;
}
