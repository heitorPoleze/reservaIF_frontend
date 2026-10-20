import 'package:flutter_test/flutter_test.dart';
import 'package:reserva_if/model/predio/predio.dart';
import 'package:reserva_if/model/reserva/reserva.dart';
import 'package:reserva_if/model/sala/sala.dart';
import 'package:reserva_if/model/usuario/perfil.dart';
import 'package:reserva_if/model/usuario/perfil_usuario.dart';
import 'package:reserva_if/model/usuario/tipo_credencial.dart';
import 'package:reserva_if/model/usuario/usuario_resumo.dart';
import 'package:reserva_if/services/services_reserva.dart';
import 'package:reserva_if/viewmodel/reserva/reservas_perfil_viewmodel.dart';

class _ServicesReservaFalso extends ServicesReserva {
  int chamadasSolicitadas = 0;
  int chamadasResponsabilidade = 0;

  @override
  Future<List<Reserva>> buscarSolicitadas() async {
    chamadasSolicitadas++;
    return [_reserva('solicitada')];
  }

  @override
  Future<List<Reserva>> buscarSobMinhaResponsabilidade() async {
    chamadasResponsabilidade++;
    return [_reserva('responsavel')];
  }
}

PerfilUsuario _usuario(Perfil perfil) => PerfilUsuario(
  uuid: 'u1',
  nome: 'Ana Souza',
  email: 'ana@ifes.edu.br',
  perfil: perfil,
  tipoCredencial: perfil == Perfil.aluno
      ? TipoCredencial.matriculaAluno
      : TipoCredencial.siapeDocente,
  identificador: '1234567',
  ativo: true,
);

Reserva _reserva(String id) => Reserva(
  id: id,
  sala: const Sala(
    id: 's1',
    nome: 'Sala 01',
    predio: Predio(id: 'p1', nome: 'Bloco A'),
  ),
  solicitante: const UsuarioResumo(id: 'u1', nome: 'Ana Souza'),
  responsavel: const UsuarioResumo(id: 'u2', nome: 'Carlos Lima'),
  inicio: DateTime.utc(2026, 10, 21, 13),
  fim: DateTime.utc(2026, 10, 21, 14),
  finalidade: 'Atividade acadêmica',
);

void main() {
  test('aluno carrega apenas agendamentos solicitados', () async {
    final service = _ServicesReservaFalso();
    final viewModel = ReservasPerfilViewModel(
      usuario: _usuario(Perfil.aluno),
      service: service,
    );
    addTearDown(viewModel.dispose);

    await viewModel.carregar();

    expect(viewModel.podeVerResponsabilidades, isFalse);
    expect(viewModel.solicitadas.single.id, 'solicitada');
    expect(viewModel.sobMinhaResponsabilidade, isEmpty);
    expect(service.chamadasSolicitadas, 1);
    expect(service.chamadasResponsabilidade, 0);
  });

  test('servidor carrega solicitados e sob responsabilidade', () async {
    final service = _ServicesReservaFalso();
    final viewModel = ReservasPerfilViewModel(
      usuario: _usuario(Perfil.coordenador),
      service: service,
    );
    addTearDown(viewModel.dispose);

    await viewModel.carregar();

    expect(viewModel.podeVerResponsabilidades, isTrue);
    expect(viewModel.solicitadas.single.id, 'solicitada');
    expect(viewModel.sobMinhaResponsabilidade.single.id, 'responsavel');
    expect(service.chamadasSolicitadas, 1);
    expect(service.chamadasResponsabilidade, 1);
  });
}
