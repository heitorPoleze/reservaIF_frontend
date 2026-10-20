import 'package:flutter/material.dart';
import 'package:reserva_if/model/predio/predio.dart';
import 'package:reserva_if/view/widgets/app_bar_padrao.dart';
import 'package:reserva_if/view/widgets/estados.dart';

class SalasDoPredioView extends StatelessWidget {
  final Predio predio;

  const SalasDoPredioView({super.key, required this.predio});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarPadrao(titulo: predio.nome),
      body: const EstadoVazio(
        mensagem: 'As salas deste prédio estarão disponíveis em breve.',
        icone: Icons.meeting_room_outlined,
      ),
    );
  }
}
