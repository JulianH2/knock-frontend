import 'package:app/core/router/rutas.dart';
import 'package:app/core/widgets/pantalla_titulada.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Pestaña Explorar. Su historia agrega el contenido real.
///
/// El acceso «Oficios» es **temporal** (TT-PRU-02): da entrada a la pantalla
/// de oficios y lo reemplaza la historia de Explorar.
class ExplorarScreen extends StatelessWidget {
  const ExplorarScreen({super.key});

  @override
  Widget build(BuildContext context) => PantallaTitulada(
    titulo: 'Explorar',
    cuerpo: ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.handyman_outlined),
          title: const Text('Oficios'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go(Rutas.oficios),
        ),
      ],
    ),
  );
}
