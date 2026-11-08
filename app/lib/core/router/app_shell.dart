import 'package:app/core/router/rutas.dart';
import 'package:app/core/sesion/es_tecnico_provider.dart';
import 'package:app/l10n/generado/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Índice de la rama Trabajo dentro de las rutas del router.
const int ramaTrabajo = 3;

/// Destino de la barra inferior, en el mismo orden que las rutas del router.
class _Destino {
  const _Destino(this.etiqueta, this.icono, this.iconoSeleccionado, this.ruta);

  /// Texto de la etiqueta en el idioma activo (ARB).
  final String Function(AppLocalizations textos) etiqueta;
  final IconData icono;
  final IconData iconoSeleccionado;
  final String ruta;
}

String _tabInicio(AppLocalizations t) => t.tabInicio;
String _tabExplorar(AppLocalizations t) => t.tabExplorar;
String _tabActividad(AppLocalizations t) => t.tabActividad;
String _tabTrabajo(AppLocalizations t) => t.tabTrabajo;
String _tabCuenta(AppLocalizations t) => t.tabCuenta;

const List<_Destino> _destinos = [
  _Destino(_tabInicio, Icons.home_outlined, Icons.home, Rutas.inicio),
  _Destino(_tabExplorar, Icons.explore_outlined, Icons.explore, Rutas.explorar),
  _Destino(
    _tabActividad,
    Icons.receipt_long_outlined,
    Icons.receipt_long,
    Rutas.actividad,
  ),
  _Destino(_tabTrabajo, Icons.handyman_outlined, Icons.handyman, Rutas.trabajo),
  _Destino(_tabCuenta, Icons.person_outline, Icons.person, Rutas.cuenta),
];

/// Ramas visibles en la barra según el rol: sin técnico no hay Trabajo.
List<int> ramasVisibles({required bool esTecnico}) => [
  for (var i = 0; i < _destinos.length; i++)
    if (esTecnico || i != ramaTrabajo) i,
];

/// Estructura con la barra inferior Inicio · Explorar · Actividad · Trabajo ·
/// Mi cuenta (Trabajo solo si el usuario es técnico).
///
/// Recibe un [child] que es la pantalla actual (generada por el router).
class AppShell extends ConsumerWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final esTecnico = ref.watch(esTecnicoProvider);
    final ramas = ramasVisibles(esTecnico: esTecnico);
    final textos = AppLocalizations.of(context);
    final router = GoRouter.of(context);
    final ubicacion = router.routerDelegate.currentConfiguration.uri.path;
    final seleccionado = ramas.indexWhere(
      (i) => ubicacion == _destinos[i].ruta ||
          ubicacion.startsWith('${_destinos[i].ruta}/'),
    );

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: seleccionado < 0 ? 0 : seleccionado,
        onDestinationSelected: (indice) {
          final rama = ramas[indice];
          context.go(_destinos[rama].ruta);
        },
        destinations: [
          for (final rama in ramas)
            NavigationDestination(
              icon: Icon(_destinos[rama].icono),
              selectedIcon: Icon(_destinos[rama].iconoSeleccionado),
              label: _destinos[rama].etiqueta(textos),
            ),
        ],
      ),
    );
  }
}
