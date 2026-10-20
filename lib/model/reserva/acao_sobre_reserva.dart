enum AcaoSobreReserva {
  cancelarReserva(
    rotuloAcao: 'Cancelar Reserva',
    tituloConfirmacao: 'Cancelar reserva?',
    explicacao:
        'O horário volta a ficar livre e a reserva segue no '
        'histórico como cancelada.',
    dicaJustificativa: 'Por que a reserva está sendo cancelada?',
    falhaPadrao: 'Não foi possível cancelar a reserva.',
  ),
  solicitarHorario(
    rotuloAcao: 'Solicitar Horário',
    tituloConfirmacao: 'Solicitar horário?',
    explicacao:
        'A coordenação vai avaliar o pedido. Até a decisão, o '
        'horário continua com o aluno; se aprovado, ele passa a ser '
        'reservado em seu nome.',
    dicaJustificativa: 'Por que você precisa deste horário?',
    falhaPadrao: 'Não foi possível solicitar o horário.',
  );

  const AcaoSobreReserva({
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
