import 'package:app/core/errores/failure.dart';
import 'package:app/features/avisos/avisos_providers.dart';
import 'package:app/features/avisos/data/avisos_repository_de_prueba.dart';
import 'package:app/features/avisos/presentation/preferencias_avisos_controller.dart';
import 'package:app/features/avisos/presentation/preferencias_avisos_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<ProviderContainer> _montar(
  WidgetTester tester,
  PreferenciasAvisosRepositoryDePrueba repo,
) async {
  final contenedor = ProviderContainer(
    overrides: [preferenciasAvisosRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(contenedor.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: contenedor,
      child: const MaterialApp(home: PreferenciasAvisosScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return contenedor;
}

bool _valor(WidgetTester tester, String titulo) => tester
    .widget<SwitchListTile>(find.widgetWithText(SwitchListTile, titulo))
    .value;

void main() {
  testWidgets('seguridad no se puede apagar', (tester) async {
    await _montar(tester, PreferenciasAvisosRepositoryDePrueba());
    final seguridad = tester.widget<SwitchListTile>(
      find.widgetWithText(SwitchListTile, 'Seguridad'),
    );
    expect(seguridad.value, isTrue);
    expect(seguridad.onChanged, isNull);
    expect(
      find.text('Los avisos de seguridad no se pueden apagar'),
      findsOneWidget,
    );
  });

  testWidgets('un cambio queda pendiente, con Guardar y Descartar', (
    tester,
  ) async {
    final c = await _montar(tester, PreferenciasAvisosRepositoryDePrueba());
    expect(find.text('Guardar cambios'), findsNothing);
    await tester.tap(find.widgetWithText(SwitchListTile, 'Visitas'));
    await tester.pumpAndSettle();
    expect(_valor(tester, 'Visitas'), isFalse);
    expect(find.text('Tienes cambios pendientes de guardar.'), findsOneWidget);
    expect(c.read(pendientesPreferenciasProvider).cambios, {'visita': false});
  });

  testWidgets('volver al valor guardado quita el pendiente', (tester) async {
    final c = await _montar(tester, PreferenciasAvisosRepositoryDePrueba());
    await tester.tap(find.widgetWithText(SwitchListTile, 'Visitas'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(SwitchListTile, 'Visitas'));
    await tester.pumpAndSettle();
    expect(c.read(pendientesPreferenciasProvider).hayPendientes, isFalse);
    expect(find.text('Guardar cambios'), findsNothing);
  });

  testWidgets('sin ruta de guardado, el cambio sigue pendiente y es honesto', (
    tester,
  ) async {
    final repo = PreferenciasAvisosRepositoryDePrueba();
    await _montar(tester, repo);
    await tester.tap(find.widgetWithText(SwitchListTile, 'Visitas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar cambios'));
    await tester.pumpAndSettle();

    expect(repo.intentosDeGuardar, 1);
    expect(repo.guardados, isNull);
    expect(find.text('Preferencias guardadas'), findsNothing);
    expect(
      find.textContaining('Esta función todavía no está disponible.'),
      findsOneWidget,
    );
    expect(find.textContaining('siguen pendientes'), findsOneWidget);
    expect(_valor(tester, 'Visitas'), isFalse);
    expect(find.text('Guardar cambios'), findsOneWidget);
  });

  testWidgets('con ruta de guardado (futuro) se guarda y se limpia', (
    tester,
  ) async {
    final repo = PreferenciasAvisosRepositoryDePrueba(guardaBien: true);
    final c = await _montar(tester, repo);
    await tester.tap(find.widgetWithText(SwitchListTile, 'Mensajes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar cambios'));
    await tester.pumpAndSettle();

    expect(find.text('Preferencias guardadas'), findsOneWidget);
    expect(c.read(pendientesPreferenciasProvider).hayPendientes, isFalse);
    expect(
      repo.guardados!.firstWhere((p) => p.tipo == 'mensaje').activo,
      isFalse,
    );
  });

  testWidgets('Descartar vuelve a lo guardado', (tester) async {
    final c = await _montar(tester, PreferenciasAvisosRepositoryDePrueba());
    await tester.tap(find.widgetWithText(SwitchListTile, 'Promociones'));
    await tester.pumpAndSettle();
    expect(_valor(tester, 'Promociones'), isTrue);
    await tester.tap(find.text('Descartar cambios'));
    await tester.pumpAndSettle();
    expect(_valor(tester, 'Promociones'), isFalse);
    expect(c.read(pendientesPreferenciasProvider).hayPendientes, isFalse);
  });

  testWidgets('los pendientes sobreviven a recargar la pantalla', (
    tester,
  ) async {
    final c = await _montar(tester, PreferenciasAvisosRepositoryDePrueba());
    await tester.tap(find.widgetWithText(SwitchListTile, 'Visitas'));
    await tester.pumpAndSettle();

    c.invalidate(preferenciasAvisosControllerProvider);
    await tester.pumpAndSettle();
    expect(_valor(tester, 'Visitas'), isFalse);
    expect(find.text('Guardar cambios'), findsOneWidget);
  });

  testWidgets('el controlador ignora un intento de apagar seguridad', (
    tester,
  ) async {
    final c = await _montar(tester, PreferenciasAvisosRepositoryDePrueba());
    c
        .read(preferenciasAvisosControllerProvider.notifier)
        .cambiar('seguridad', activo: false);
    await tester.pumpAndSettle();
    expect(_valor(tester, 'Seguridad'), isTrue);
    expect(c.read(pendientesPreferenciasProvider).hayPendientes, isFalse);
  });

  testWidgets('404 de ruta al cargar dice que no está disponible', (
    tester,
  ) async {
    await _montar(
      tester,
      PreferenciasAvisosRepositoryDePrueba(
        falla: const RutaNoDisponibleFailure(),
      ),
    );
    expect(
      find.text('Esta función todavía no está disponible.'),
      findsOneWidget,
    );
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('503 al cargar ofrece Reintentar', (tester) async {
    await _montar(
      tester,
      PreferenciasAvisosRepositoryDePrueba(
        falla: const ServicioNoDisponibleFailure(),
      ),
    );
    expect(
      find.text('El servicio no está disponible por ahora. Intenta más tarde.'),
      findsOneWidget,
    );
  });
}
