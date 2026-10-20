import 'package:flutter/material.dart';
import 'package:reserva_if/model/reserva/horario_do_dia.dart';
import 'package:reserva_if/view/theme/app_cores.dart';
import 'package:reserva_if/view/theme/app_estilos.dart';

class ListaHorariosDoDia extends StatelessWidget {
  final List<HorarioDoDia> horarios;
  final ValueChanged<HorarioDoDia> aoTocar;

  const ListaHorariosDoDia({
    super.key,
    required this.horarios,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: AppEstilos.cartao(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppEstilos.raioCartao),
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            children: [
              for (var indice = 0; indice < horarios.length; indice++) ...[
                if (indice > 0) const Divider(),
                _LinhaDeHorario(horario: horarios[indice], aoTocar: aoTocar),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LinhaDeHorario extends StatelessWidget {
  final HorarioDoDia horario;
  final ValueChanged<HorarioDoDia> aoTocar;

  const _LinhaDeHorario({required this.horario, required this.aoTocar});

  bool get _tocavel => !horario.livre || horario.reservavel();

  Color get _corDaSituacao {
    if (!horario.livre) return AppCores.textoTerciario;
    return horario.reservavel() ? AppCores.acao : AppCores.textoInativo;
  }

  Color get _corDoPonto {
    if (!horario.livre) return AppCores.textoInativo;
    return horario.reservavel() ? AppCores.acao : AppCores.textoInativo;
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final encerrado = horario.livre && !horario.reservavel();

    return Semantics(
      button: _tocavel,
      label: '${horario.intervaloFormatado}, ${horario.situacao()}',
      excludeSemantics: true,
      child: InkWell(
        onTap: _tocavel ? () => aoTocar(horario) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  horario.faixaFormatada,
                  style: textos.bodyLarge?.copyWith(
                    color: encerrado
                        ? AppCores.textoInativo
                        : AppCores.textoPrimario,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              Text(
                horario.situacao(),
                style: textos.labelMedium?.copyWith(
                  color: _corDaSituacao,
                  fontWeight: horario.reservavel()
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _corDoPonto,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
