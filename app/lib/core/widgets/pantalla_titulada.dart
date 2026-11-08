import 'package:flutter/material.dart';

/// Pantalla base de una pestaña: título y cuerpo.
///
/// No usa Scaffold directamente: el Scaffold (con AppBar y BottomNavigationBar)
/// lo provee AppShell, que envuelve cada pantalla.
class PantallaTitulada extends StatelessWidget {
  const PantallaTitulada({required this.titulo, this.cuerpo, super.key});

  final String titulo;
  final Widget? cuerpo;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              titulo,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: cuerpo ?? const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
