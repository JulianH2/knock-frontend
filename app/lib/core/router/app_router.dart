import 'package:app/core/notificaciones/navegacion_notificaciones.dart';
import 'package:app/core/router/app_shell.dart';
import 'package:app/core/router/rutas.dart';
import 'package:app/core/sesion/es_tecnico_provider.dart';
import 'package:app/features/actividad/presentation/actividad_screen.dart';
import 'package:app/features/cuenta/presentation/completar_perfil_screen.dart';
import 'package:app/features/cuenta/presentation/configuracion_screen.dart';
import 'package:app/features/cuenta/presentation/perfil_controller.dart';
import 'package:app/features/cuenta/presentation/cuenta_screen.dart';
import 'package:app/features/explorar/presentation/explorar_screen.dart';
import 'package:app/features/inicio/presentation/inicio_screen.dart';
import 'package:app/features/oficios/presentation/oficios_screen.dart';
import 'package:app/features/trabajo/presentation/trabajo_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Router de la app: `StatefulShellRoute` con una rama por pestaña.
///
/// Las 5 ramas existen siempre (el orden coincide con la barra); la barra
/// oculta Trabajo y el `redirect` manda `/trabajo` a `/inicio` si el usuario
/// no es técnico. El router se refresca cuando cambia el indicador.
final appRouterProvider = Provider<GoRouter>((ref) {
  final esTecnico = ValueNotifier<bool>(ref.read(esTecnicoProvider));
  ref.listen<bool>(esTecnicoProvider, (_, valor) => esTecnico.value = valor);
  // Perfil incompleto (cuenta nueva) => completar perfil. Mientras carga no se
  // redirige. El perfil es SIMULADO hasta que exista GET /me.
  final perfilPendiente = ValueNotifier<bool>(
    ref.read(perfilPendienteProvider),
  );
  ref.listen<bool>(
    perfilPendienteProvider,
    (_, valor) => perfilPendiente.value = valor,
  );

  final router = GoRouter(
    initialLocation: Rutas.inicio,
    refreshListenable: Listenable.merge([esTecnico, perfilPendiente]),
    redirect: (context, state) =>
        redireccionPorPerfil(
          perfilPendiente: perfilPendiente.value,
          ubicacion: state.matchedLocation,
        ) ??
        redireccionPorRol(
          esTecnico: esTecnico.value,
          ubicacion: state.matchedLocation,
        ),
    routes: [
      GoRoute(
        path: Rutas.completarPerfil,
        builder: (context, state) => const CompletarPerfilScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          _rama(Rutas.inicio, const InicioScreen()),
          _rama(
            Rutas.explorar,
            const ExplorarScreen(),
            subrutas: [
              GoRoute(
                path: 'oficios',
                builder: (context, state) => const OficiosScreen(),
              ),
            ],
          ),
          _rama(Rutas.actividad, const ActividadScreen()),
          _rama(Rutas.trabajo, const TrabajoScreen()),
          _rama(
            Rutas.cuenta,
            const CuentaScreen(),
            subrutas: [
              GoRoute(
                path: 'configuracion',
                builder: (context, state) => const ConfiguracionScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  abrirPantallaDesdeNotificaciones(ref, router);

  ref.onDispose(() {
    router.dispose();
    esTecnico.dispose();
    perfilPendiente.dispose();
  });
  return router;
});

StatefulShellBranch _rama(
  String ruta,
  Widget pantalla, {
  List<RouteBase> subrutas = const [],
}) => StatefulShellBranch(
  routes: [
    GoRoute(
      path: ruta,
      builder: (context, state) => pantalla,
      routes: subrutas,
    ),
  ],
);
