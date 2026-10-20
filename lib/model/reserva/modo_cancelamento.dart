enum ModoCancelamento {
  cancelar(
    rotuloAcao: 'Cancelar reserva',
    tituloConfirmacao: 'Cancelar reserva?',
    explicacao: 'O horário volta a ficar livre e a reserva segue no '
        'histórico como cancelada.',
    dicaJustificativa: 'Por que a reserva está sendo cancelada?',
    falhaPadrao: 'Não foi possível cancelar a reserva.',
  ),
  solicitar(
    rotuloAcao: 'Solicitar Horário',
    tituloConfirmacao: 'Solicitar horário?',
    explicacao: 'A coordenação vai avaliar o pedido. A reserva do aluno '
        'continua ativa até a decisão; se aprovada, ela é cancelada e o '
        'horário passa a ser reservado em seu nome.',
    dicaJustificativa: 'Por que você precisa deste horário?',
    falhaPadrao: 'Não foi possível solicitar o horário.',
  );

  const ModoCancelamento({
    required this.rotuloAcao,
    required this.tituloConfirmacao,
    required this.explicacao,
    required this.dicaJustificativa,
    required this.falhaPadrao,
  });

  final String rotuloAcao;

  final String tituloConfirmacao;

  final String explicacao;

  final String dicaJustificativa;

  final String falhaPadrao;
}
