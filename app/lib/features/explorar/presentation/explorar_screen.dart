import 'package:flutter/material.dart';

import 'package:app/core/widgets/pantalla_titulada.dart';

/// Pestaña Explorar. Vacía en TT-MOB-01; su historia agrega el contenido.
class ExplorarScreen extends StatelessWidget {
  const ExplorarScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const PantallaTitulada(titulo: 'Explorar');
}
