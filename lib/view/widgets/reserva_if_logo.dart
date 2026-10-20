import 'package:flutter/material.dart';

class ReservaIfLogo extends StatelessWidget {
  final double width;
  final double height;

  const ReservaIfLogo({
    super.key,
    this.width = 240,
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: width,
      height: height,
      fit: BoxFit.contain,
      semanticLabel: 'Logo do ReservaIF',
    );
  }
}
