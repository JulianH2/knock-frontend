import 'package:flutter/material.dart';

/// Pantalla base de una pestaña: barra superior con el título y un cuerpo.
///
/// Las pestañas de TT-MOB-01 están vacías; cada historia reemplaza el cuerpo
/// con su contenido y sus 4 estados.
class PantallaTitulada extends StatelessWidget {
  const PantallaTitulada({required this.titulo, this.cuerpo, super.key});

  final String titulo;
  final Widget? cuerpo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: cuerpo ?? const SizedBox.shrink(),
    );
  }
}
