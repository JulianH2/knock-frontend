import 'package:app/core/router/app_shell.dart';
import 'package:app/core/router/rutas.dart';
import 'package:app/core/sesion/es_tecnico_provider.dart';
import 'package:app/features/actividad/presentation/actividad_screen.dart';
import 'package:app/features/cuenta/presentation/completar_perfil_screen.dart';
import 'package:app/features/cuenta/presentation/configuracion_screen.dart';
import 'package:app/features/cuenta/presentation/cuenta_screen.dart';
import 'package:app/features/entrada/presentation/celular_screen.dart';
import 'package:app/features/entrada/presentation/codigo_screen.dart';
import 'package:app/features/explorar/presentation/explorar_screen.dart';
import 'package:app/features/inicio/presentation/inicio_screen.dart';
import 'package:app/features/oficios/presentation/oficios_screen.dart';
import 'package:app/features/trabajo/presentation/trabajo_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Router de la app: rutas planas con barra inferior compartida.
///
/// Cada ruta envuelve su pantalla con [AppShell] para mostrar la barra
/// inferior (Inicio · Explorar · Actividad · Trabajo · Mi cuenta).
/// Trabajo solo es accesible si el usuario es técnic
o.
/// La entrada (/entrar) queda fuera de la barra inferior.
final appRouterProvider = Provider<GoRouter>((ref) {
  final esTecnico = ValueNotifier<bool>(ref.read(esTecnicoProvider));
  ref.listen<bool>(esTecnicoProvider, (_, valor) => esTecnico.value = valor);

  final router = GoRouter(
    initialLocation: Rutas.inicio,
    refreshListenable: Listenable.merge([esTecnico]),
    routes: [
      GoRoute(
        path: Rutas.inicio,
        builder: (context, state) => AppShell(child: const InicioScreen()),
      ),
      GoRoute(
        path: Rutas.explorar,
        builder: (context, state) => AppShell(child: const ExplorarScreen()),
        routes: [
          GoRoute(
            path: 'oficios',
            builder: (context, state) => AppShell(child: const OficiosScreen()),
          ),
        ],
      ),
      GoRoute(
        path: Rutas.actividad,
        builder: (context, state) => AppShell(child: const ActividadScreen()),
      ),
      GoRoute(
        path: Rutas.trabajo,
        builder: (context, state) => AppShell(child: const TrabajoScreen()),
      ),
      GoRoute(
        path: Rutas.cuenta,
        builder: (context, state) => AppShell(child: const CuentaScreen()),
        routes: [
          GoRoute(
            path: 'configuracion',
            builder: (context, state) =>
                AppShell(child: const ConfiguracionScreen()),
          ),
        ],
      ),
      GoRoute(
        path: Rutas.completarPerfil,
        builder: (context, state) =>
            AppShell(child: const CompletarPerfilScreen()),
      ),
      GoRoute(
        path: Rutas.entrar,
        builder: (context, state) => const CelularScreen(),
        routes: [
          GoRoute(
            path: 'codigo',
            // El celular viaja en memoria como `extra`; sin él (enlace
            // directo) se regresa a escribirlo.
            redirect: (context, state) =>
                _celularDe(state) == null ? Rutas.entrar : null,
            builder: (context, state) =>
                CodigoScreen(celular: _celularDe(state)!),
          ),
        ],
      ),
    ],
  );

  return router;
});

String? _celularDe(GoRouterState state) {
  final extra = state.extra;
  return extra is String ? extra : null;
}
