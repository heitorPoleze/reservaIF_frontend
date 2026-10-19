import 'package:flutter/material.dart';
import 'package:reserva_if/view/theme/app_cores.dart';

abstract final class AppEstilos {
  static const raioCartao = 16.0;

  static const raioCampo = 8.0;

  static const raioDialogo = 16.0;

  static const raioPainel = 20.0;

  static const espacoPagina = 16.0;

  static const espacoEntreCampos = 16.0;

  static const sombraCartao = <BoxShadow>[
    BoxShadow(
      color: AppCores.sombra,
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];

  static const sombraElevada = <BoxShadow>[
    BoxShadow(
      color: AppCores.sombraChrome,
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const sombraChromeInferior = <BoxShadow>[
    BoxShadow(
      color: AppCores.sombraChrome,
      blurRadius: 16,
      offset: Offset(0, -4),
    ),
  ];

  static BoxDecoration cartao({Color cor = AppCores.superficie}) {
    return BoxDecoration(
      color: cor,
      borderRadius: BorderRadius.circular(raioCartao),
      boxShadow: sombraCartao,
    );
  }
}
