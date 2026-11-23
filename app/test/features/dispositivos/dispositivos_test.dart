import 'package:app/core/errores/failure.dart';
import 'package:app/features/dispositivos/data/dispositivos_de_prueba.dart';
import 'package:app/features/dispositivos/dispositivos_providers.dart';
import 'package:app/features/dispositivos/domain/dispositivo.dart';
import 'package:app/features/dispositivos/domain/permiso_notificaciones.dart';
import 'package:app/features/dispositivos/presentation/notificaciones_screen.dart';
import 'package:app/features/dispositivos/presentation/registro_push_controller.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<ProviderContainer> _montar(
  WidgetTester tester,
  DispositivosRepositoryDePrueba repo, {
  ProveedorTokenPush? token,
  PermisoNotificacionesDePrueba? permiso,
}) async {
  final contenedor = ProviderContainer(
    overrides: [
      dispositivosRepositoryProvider.overrideWithValue(repo),
      if (token != null) proveedorTokenPushProvider.overrideWithValue(token),
      permisoNotificacionesProvider.overrideWithValue(
        permiso ??
            PermisoNotificacionesDePrueba(actual: EstadoPermiso.concedido),
      ),
    ],
  );
  addTearDown(contenedor.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: contenedor,
      child: const MaterialApp(home: NotificacionesScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return contenedor;
}

Future<void> _activar(WidgetTester tester) async {
  await tester.tap(find.text('Activar notificaciones'));
  await tester.pumpAndSettle();
}

void main() {
  group('validarIdentificadorDispositivo', () {
    test('acepta un token normal', () {
      expect(validarIdentificadorDispositivo(' abc123 '), 'abc123');
    });

    test('rechaza vacío, largo y caracteres de control', () {
      final malos = ['', '   ', 'a\nb', 'a\u0000b', 'x' * 4097];
      for (final malo in malos) {
        expect(
          () => validarIdentificadorDispositivo(malo),
          throwsA(isA<DatosInvalidosFailure>()),
        );
      }
    });
  });

  testWidgets('con permiso, activar registra y muestra el estado', (
    tester,
  ) async {
    final repo = DispositivosRepositoryDePrueba();
    await _montar(tester, repo);
    await _activar(tester);
    expect(
      find.text('Las notificaciones están activas en este dispositivo.'),
      findsOneWidget,
    );
    expect(find.text('Concedido'), findsOneWidget);
    expect(repo.llamadas, 1);
  });

  testWidgets('sin preguntar: explica y luego pide el permiso', (tester) async {
    final repo = DispositivosRepositoryDePrueba();
    final permiso = PermisoNotificacionesDePrueba();
    await _montar(tester, repo, permiso: permiso);
    await _activar(tester);
    expect(find.textContaining('necesitamos tu permiso'), findsOneWidget);
    expect(permiso.solicitudes, 0);
    expect(repo.llamadas, 0);

    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(permiso.solicitudes, 1);
    expect(repo.llamadas, 1);
    expect(find.textContaining('están activas'), findsOneWidget);
  });

  testWidgets('«Ahora no» en la explicación no pide nada', (tester) async {
    final permiso = PermisoNotificacionesDePrueba();
    await _montar(tester, DispositivosRepositoryDePrueba(), permiso: permiso);
    await _activar(tester);
    await tester.tap(find.text('Ahora no'));
    await tester.pumpAndSettle();
    expect(permiso.solicitudes, 0);
    expect(find.text('Activar notificaciones'), findsOneWidget);
  });

  testWidgets('denegado: ofrece pedir de nuevo y no registra', (tester) async {
    final repo = DispositivosRepositoryDePrueba();
    await _montar(
      tester,
      repo,
      permiso: PermisoNotificacionesDePrueba(
        alSolicitar: EstadoPermiso.denegado,
      ),
    );
    await _activar(tester);
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(find.text('Pedir permiso de nuevo'), findsOneWidget);
    expect(repo.llamadas, 0);
  });

  testWidgets('bloqueado: lleva a Ajustes y registra al volver con permiso', (
    tester,
  ) async {
    final repo = DispositivosRepositoryDePrueba();
    final permiso = PermisoNotificacionesDePrueba(
      actual: EstadoPermiso.denegadoPermanente,
    );
    final c = await _montar(tester, repo, permiso: permiso);
    await _activar(tester);
    expect(find.text('Bloqueado en Ajustes'), findsOneWidget);
    await tester.tap(find.text('Abrir ajustes'));
    await tester.pumpAndSettle();
    expect(permiso.ajustesAbiertos, 1);

    permiso.actual = EstadoPermiso.concedido;
    await c.read(registroPushControllerProvider.notifier).refrescarPermiso();
    await tester.pumpAndSettle();
    expect(repo.llamadas, 1);
    expect(find.textContaining('están activas'), findsOneWidget);
  });

  testWidgets('503 muestra «no disponibles por ahora» y no reintenta', (
    tester,
  ) async {
    final repo = DispositivosRepositoryDePrueba(
      falla: const ServicioNoDisponibleFailure(),
    );
    final contenedor = await _montar(tester, repo);
    await _activar(tester);
    expect(
      find.text('Las notificaciones no están disponibles por ahora.'),
      findsOneWidget,
    );
    await contenedor.read(registroPushControllerProvider.notifier).registrar();
    await tester.pump(const Duration(seconds: 30));
    expect(repo.llamadas, 1);

    // Solo la persona puede volver a comprobar.
    await tester.tap(find.text('Volver a comprobar'));
    await tester.pumpAndSettle();
    expect(repo.llamadas, 2);
  });

  testWidgets('409 muestra que el dispositivo está en uso', (tester) async {
    final repo = DispositivosRepositoryDePrueba(
      falla: const ReglaDeNegocioFailure('device_conflict'),
    );
    await _montar(tester, repo);
    await _activar(tester);
    expect(find.textContaining('ya está en uso'), findsOneWidget);
    expect(repo.llamadas, 1);
  });

  testWidgets('429 muestra el texto de límite', (tester) async {
    await _montar(
      tester,
      DispositivosRepositoryDePrueba(falla: const LimiteDePeticionesFailure()),
    );
    await _activar(tester);
    expect(find.textContaining('muchas peticiones'), findsOneWidget);
  });

  testWidgets('token con caracteres de control ofrece pedir uno nuevo', (
    tester,
  ) async {
    await _montar(
      tester,
      DispositivosRepositoryDePrueba(),
      token: const ProveedorTokenPushDePrueba('mal\ntoken'),
    );
    await _activar(tester);
    expect(find.text('Obtener uno nuevo'), findsOneWidget);
  });

  testWidgets('sin token ofrece intentar de nuevo', (tester) async {
    await _montar(
      tester,
      DispositivosRepositoryDePrueba(),
      token: const ProveedorTokenPushDePrueba(null),
    );
    await _activar(tester);
    expect(find.text('Intentar de nuevo'), findsOneWidget);
  });

  testWidgets('dejar de recibir da de baja el dispositivo', (tester) async {
    final repo = DispositivosRepositoryDePrueba();
    await _montar(tester, repo);
    await _activar(tester);
    await tester.tap(find.text('Dejar de recibir en este dispositivo'));
    await tester.pumpAndSettle();
    expect(find.text('Activar notificaciones'), findsOneWidget);
    expect(repo.llamadas, 2);
  });

  group('sesión', () {
    ProviderContainer crear(
      DispositivosRepositoryDePrueba repo,
      PermisoNotificacionesDePrueba permiso,
    ) {
      final c = ProviderContainer(
        overrides: [
          dispositivosRepositoryProvider.overrideWithValue(repo),
          permisoNotificacionesProvider.overrideWithValue(permiso),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    test('al iniciar sesión registra solo si ya hay permiso', () async {
      final repo = DispositivosRepositoryDePrueba();
      final permiso = PermisoNotificacionesDePrueba();
      final c = crear(repo, permiso);
      final controlador = c.read(registroPushControllerProvider.notifier);
      await controlador.alIniciarSesion();
      expect(repo.llamadas, 0);
      expect(permiso.solicitudes, 0, reason: 'no abre el diálogo solo');

      permiso.actual = EstadoPermiso.concedido;
      await controlador.alIniciarSesion();
      expect(
        c.read(registroPushControllerProvider).estado,
        EstadoPush.registrado,
      );
    });

    test('al cerrar sesión da de baja y vuelve a sin registrar', () async {
      final repo = DispositivosRepositoryDePrueba();
      final c = crear(
        repo,
        PermisoNotificacionesDePrueba(actual: EstadoPermiso.concedido),
      );
      final controlador = c.read(registroPushControllerProvider.notifier);
      await controlador.alIniciarSesion();
      await controlador.darDeBaja();
      expect(
        c.read(registroPushControllerProvider).estado,
        EstadoPush.sinRegistrar,
      );
      expect(repo.llamadas, 2);
    });

    test('darDeBaja sin registro no llama a la API', () async {
      final repo = DispositivosRepositoryDePrueba();
      final c = crear(repo, PermisoNotificacionesDePrueba());
      await c.read(registroPushControllerProvider.notifier).darDeBaja();
      expect(repo.llamadas, 0);
    });
  });
}
