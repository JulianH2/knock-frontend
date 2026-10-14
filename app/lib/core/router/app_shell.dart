import 'package:app/core/sesion/es_tecnico_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Índice de la rama Trabajo dentro del `StatefulShellRoute`.
const int ramaTrabajo = 3;

/// Destino de la barra inferior, en el mismo orden que las ramas del router.
class _Destino {
  const _Destino(this.etiqueta, this.icono, this.iconoSeleccionado);

  final String etiqueta;
  final IconData icono;
  final IconData iconoSeleccionado;
}

const List<_Destino> _destinos = [
  _Destino('Inicio', Icons.home_outlined, Icons.home),
  _Destino('Explorar', Icons.explore_outlined, Icons.explore),
  _Destino('Actividad', Icons.receipt_long_outlined, Icons.receipt_long),
  _Destino('Trabajo', Icons.handyman_outlined, Icons.handyman),
  _Destino('Mi cuenta', Icons.person_outline, Icons.person),
];

/// Ramas visibles en la barra según el rol: sin técnico no hay Trabajo.
List<int> ramasVisibles({required bool esTecnico}) => [
  for (var i = 0; i < _destinos.length; i++)
    if (esTecnico || i != ramaTrabajo) i,
];

/// Estructura con la barra inferior Inicio · Explorar · Actividad · Trabajo ·
/// Mi cuenta (Trabajo solo si el usuario es técnico).
class AppShell extends ConsumerWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ramas = ramasVisibles(esTecnico: ref.watch(esTecnicoProvider));
    final seleccionado = ramas.indexOf(navigationShell.currentIndex);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: seleccionado < 0 ? 0 : seleccionado,
        onDestinationSelected: (indice) {
          final rama = ramas[indice];
          navigationShell.goBranch(
            rama,
            initialLocation: rama == navigationShell.currentIndex,
          );
        },
        destinations: [
          for (final rama in ramas)
            NavigationDestination(
              icon: Icon(_destinos[rama].icono),
              selectedIcon: Icon(_destinos[rama].iconoSeleccionado),
              label: _destinos[rama].etiqueta,
            ),
        ],
      ),
    );
  }
}
