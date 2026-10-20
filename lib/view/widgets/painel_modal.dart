import 'package:flutter/material.dart';
import 'package:reserva_if/view/theme/app_cores.dart';

Future<T?> mostrarPainelModal<T>({
  required BuildContext context,
  required WidgetBuilder construir,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AlcaDoPainel(),
          Flexible(child: construir(context)),
        ],
      ),
    ),
  );
}

class AlcaDoPainel extends StatelessWidget {
  const AlcaDoPainel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      decoration: BoxDecoration(
        color: AppCores.borda,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
