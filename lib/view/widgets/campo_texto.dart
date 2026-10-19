import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reserva_if/view/theme/app_cores.dart';
import 'package:reserva_if/view/widgets/campos_formulario.dart';

class CampoTexto extends StatefulWidget {
  final String rotulo;
  final TextEditingController? controller;
  final String? dica;
  final String? Function(String?)? validador;
  final bool ehSenha;
  final bool habilitado;
  final bool somenteLeitura;
  final bool abreSeletor;
  final bool opcional;
  final TextInputType? tipoDeTeclado;
  final TextInputAction? acaoDoTeclado;
  final List<TextInputFormatter>? formatadores;
  final int maxLinhas;
  final int? maxCaracteres;
  final IconData? iconePrefixo;
  final Widget? sufixo;
  final VoidCallback? aoTocar;
  final ValueChanged<String>? aoMudar;
  final ValueChanged<String>? aoSubmeter;
  final FocusNode? focusNode;
  final TextCapitalization capitalizacao;

  const CampoTexto({
    super.key,
    required this.rotulo,
    this.controller,
    this.dica,
    this.validador,
    this.ehSenha = false,
    this.habilitado = true,
    this.somenteLeitura = false,
    this.abreSeletor = false,
    this.opcional = false,
    this.tipoDeTeclado,
    this.acaoDoTeclado,
    this.formatadores,
    this.maxLinhas = 1,
    this.maxCaracteres,
    this.iconePrefixo,
    this.sufixo,
    this.aoTocar,
    this.aoMudar,
    this.aoSubmeter,
    this.focusNode,
    this.capitalizacao = TextCapitalization.none,
  });

  @override
  State<CampoTexto> createState() => _CampoTextoState();
}

class _CampoTextoState extends State<CampoTexto> {
  bool _senhaOculta = true;

  bool get _preenchido => widget.somenteLeitura || !widget.habilitado;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        rotuloDeCampo(context, widget.rotulo, opcional: widget.opcional),
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          enabled: widget.habilitado,
          readOnly: widget.somenteLeitura || widget.abreSeletor,
          obscureText: widget.ehSenha && _senhaOculta,
          keyboardType: widget.tipoDeTeclado,
          textInputAction: widget.acaoDoTeclado,
          inputFormatters: widget.formatadores,
          maxLines: widget.ehSenha ? 1 : widget.maxLinhas,
          maxLength: widget.maxCaracteres,
          textCapitalization: widget.capitalizacao,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: widget.validador,
          onTap: widget.aoTocar,
          onChanged: widget.aoMudar,
          onFieldSubmitted: widget.aoSubmeter,
          style: estiloDeValorDeCampo(context),
          decoration: InputDecoration(
            hintText: widget.dica,
            filled: _preenchido,
            prefixIcon:
                widget.iconePrefixo == null ? null : Icon(widget.iconePrefixo),
            suffixIcon: _sufixo,
            counterText: '',
          ),
        ),
      ],
    );
  }

  Widget? get _sufixo {
    if (!widget.ehSenha) return widget.sufixo;

    return IconButton(
      tooltip: _senhaOculta ? 'Mostrar senha' : 'Ocultar senha',
      icon: Icon(
        _senhaOculta ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: AppCores.textoSecundario,
      ),
      onPressed: () => setState(() => _senhaOculta = !_senhaOculta),
    );
  }
}
