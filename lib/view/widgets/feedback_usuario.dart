import 'package:flutter/material.dart';
import 'package:reserva_if/view/theme/app_cores.dart';

void mostrarErro(BuildContext context, String mensagem) =>
    _mostrar(context, mensagem, AppCores.erro);

void mostrarSucesso(BuildContext context, String mensagem) =>
    _mostrar(
      context,
      mensagem,
      AppCores.sucesso,
      corDoTexto: AppCores.sobreSucesso,
    );

void mostrarAviso(BuildContext context, String mensagem) =>
    _mostrar(context, mensagem, AppCores.aviso);

void mostrarInfo(BuildContext context, String mensagem) =>
    _mostrar(context, mensagem, null);

void mostrarResultado(
  BuildContext context,
  String mensagem, {
  required bool sucesso,
}) =>
    sucesso ? mostrarSucesso(context, mensagem) : mostrarErro(context, mensagem);

void _mostrar(
  BuildContext context,
  String mensagem,
  Color? cor, {
  Color? corDoTexto,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        mensagem,
        style: corDoTexto == null ? null : TextStyle(color: corDoTexto),
      ),
      backgroundColor: cor,
    ),
  );
}
