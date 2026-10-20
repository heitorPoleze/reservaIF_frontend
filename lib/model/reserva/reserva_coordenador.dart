import '../sala/sala.dart';
import '../usuario/usuario_resumo.dart';
import 'cancelamento.dart';
import 'regra_recorrencia.dart';
import 'reserva.dart';
import 'serie_recorrencia.dart';
import 'status_reserva.dart';
import 'tipo_recorrencia.dart';

class ReservaCoordenador extends Reserva {
  ReservaCoordenador({
    super.id,
    required super.sala,
    required super.solicitante,
    required super.responsavel,
    required super.inicio,
    required super.fim,
    required super.finalidade,
    super.observacoes,
    super.status,
    required this.recorrencia,
  }) : super(tipoRecorrencia: recorrencia.tipo);

  final RegraRecorrencia recorrencia;

  @override
  ReservaCoordenador copyWith({
    String? id,
    Sala? sala,
    UsuarioResumo? solicitante,
    UsuarioResumo? responsavel,
    UsuarioResumo? analisadoPor,
    SerieRecorrencia? serieRecorrencia,
    TipoRecorrencia? tipoRecorrencia,
    DateTime? inicio,
    DateTime? fim,
    String? finalidade,
    String? observacoes,
    StatusReserva? status,
    String? motivoRejeicao,
    Cancelamento? cancelamento,
    DateTime? criadoEm,
    DateTime? aceitoPeloResponsavelEm,
    DateTime? analisadoEm,
    RegraRecorrencia? recorrencia,
  }) =>
      ReservaCoordenador(
        id: id ?? this.id,
        sala: sala ?? this.sala,
        solicitante: solicitante ?? this.solicitante,
        responsavel: responsavel ?? this.responsavel,
        inicio: inicio ?? this.inicio,
        fim: fim ?? this.fim,
        finalidade: finalidade ?? this.finalidade,
        observacoes: observacoes ?? this.observacoes,
        status: status ?? this.status,
        recorrencia: recorrencia ?? this.recorrencia,
      );

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'recorrencia': recorrencia.toJson(),
      };
}
