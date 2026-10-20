enum ModoCancelamento {
  cancelar(
    rotuloAcao: 'Cancelar reserva',
    tituloConfirmacao: 'Cancelar reserva?',
    explicacao: 'O horário volta a ficar livre e a reserva segue no '
        'histórico como cancelada.',
    dicaJustificativa: 'Por que a reserva está sendo cancelada?',
  ),
  solicitar(
    rotuloAcao: 'Solicitar Horário',
    tituloConfirmacao: 'Solicitar horário?',
    explicacao: 'A coordenação do departamento do responsável vai avaliar '
        'o cancelamento da reserva do aluno. Ela continua ativa até a '
        'decisão, e o horário não fica reservado para você.',
    dicaJustificativa: 'Por que você precisa deste horário?',
  );

  const ModoCancelamento({
    required this.rotuloAcao,
    required this.tituloConfirmacao,
    required this.explicacao,
    required this.dicaJustificativa,
  });

  final String rotuloAcao;

  final String tituloConfirmacao;

  final String explicacao;

  final String dicaJustificativa;
}
