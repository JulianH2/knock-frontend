import 'package:app/core/errores/failure.dart';
import 'package:app/features/dispositivos/data/dispositivos_de_prueba.dart';
import 'package:app/features/dispositivos/dispositivos_providers.dart';
import 'package:app/features/dispositivos/domain/dispositivo.dart';
import 'package:app/features/dispositivos/presentation/notificaciones_screen.dart';
import 'package:app/features/dispositivos/presentation/registro_push_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<ProviderContainer> _montar(
  WidgetTester tester,
  DispositivosRepositoryDePrueba repo, {
  ProveedorTokenPush? token,
}) async {
  final contenedor = ProviderContainer(
    overrides: [
      dispositivosRepositoryProvider.overrideWithValue(repo),
      if (token != null) proveedorTokenPushProvider.overrideWithValue(token),
    ],
  );
  addTearDown(contenedor.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: contenedor,
      child: const MaterialApp(home: NotificacionesScreen()),
    ),
  );
  return contenedor;
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

  testWidgets('activar registra el dispositivo y lo muestra activo', (
    tester,
  ) async {
    final repo = DispositivosRepositoryDePrueba();
    await _montar(tester, repo);
    await tester.tap(find.text('Activar notificaciones'));
    await tester.pumpAndSettle();
    expect(
      find.text('Las notificaciones están activas en este dispositivo.'),
      findsOneWidget,
    );
    expect(repo.llamadas, 1);
  });

  testWidgets('503 muestra «no disponibles por ahora» y no reintenta', (
    tester,
  ) async {
    final repo = DispositivosRepositoryDePrueba(
      falla: const ServicioNoDisponibleFailure(),
    );
    final contenedor = await _montar(tester, repo);
    await tester.tap(find.text('Activar notificaciones'));
    await tester.pumpAndSettle();
    expect(
      find.text('Las notificaciones no están disponibles por ahora.'),
      findsOneWidget,
    );
    expect(find.text('Activar notificaciones'), findsNothing);

    // Aunque se pida otra vez, no se llama de nuevo al servidor.
    await contenedor.read(registroPushControllerProvider.notifier).registrar();
    await tester.pump(const Duration(seconds: 30));
    expect(repo.llamadas, 1);
  });

  testWidgets('sin permiso ofrece intentar de nuevo', (tester) async {
    await _montar(
      tester,
      DispositivosRepositoryDePrueba(),
      token: const ProveedorTokenPushDePrueba(null),
    );
    await tester.tap(find.text('Activar notificaciones'));
    await tester.pumpAndSettle();
    expect(find.text('Intentar de nuevo'), findsOneWidget);
  });

  test('registrar y dar de baja vuelve a sin registrar', () async {
    final repo = DispositivosRepositoryDePrueba();
    final contenedor = ProviderContainer(
      overrides: [dispositivosRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(contenedor.dispose);
    final controlador = contenedor.read(
      registroPushControllerProvider.notifier,
    );
    await controlador.registrar();
    expect(
      contenedor.read(registroPushControllerProvider).estado,
      EstadoPush.registrado,
    );
    await controlador.darDeBaja();
    expect(
      contenedor.read(registroPushControllerProvider).estado,
      EstadoPush.sinRegistrar,
    );
  });
}
