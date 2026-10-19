import 'package:flutter/material.dart';
import 'package:reserva_if/view/theme/app_cores.dart';

class TelaDeAbertura extends StatelessWidget {
  const TelaDeAbertura({super.key});

  static const _ladoDaLogo = 120.0;
  static const _respiro = 32.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppCores.casca,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.meeting_room_outlined,
              size: _ladoDaLogo,
              color: AppCores.sobreCasca,
            ),
            const SizedBox(height: 16),
            Text(
              'reservaIF',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: AppCores.sobreCasca),
            ),
            const SizedBox(height: _respiro),
            const CircularProgressIndicator(color: AppCores.sobreCasca),
          ],
        ),
      ),
    );
  }
}
