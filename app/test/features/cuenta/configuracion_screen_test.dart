import 'package:app/app.dart';
import 'package:app/core/preferencias/preferencias_provider.dart';
import 'package:app/core/router/app_router.dart';
import 'package:app/core/router/rutas.dart';
import 'package:app/core/tema/colores.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test';

import '../../soporte/montar_app.dart';

/// Tema que ve la pantalla activa.
ThemeData _tema(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(Scaffold)));

/// Fija el tema del teléfono para la prueba.
void _telefonoEn(WidgetTester tester, Brightness brillo) {
  tester.platformDispatcher.platformBrightnessTestValue = brillo;
  addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
}

/// Ruta para cada pestaña de la barra inferior.
final _pestanasYRutas = [
  ('Inicio', Rutas.inicio),
  ('Explorar', Rutas.explorar),
  ('Actividad', Rutas.actividad),
  ('Trabajo', Rutas.trabajo),
  ('Mi cuenta', Rutas.cuenta),
];

/// Monta la app y entra a Mi cuenta → Configuración.
Future<dynamic> _abrirConfiguracion(
  WidgetTester tester, {
  bool esTecnico = false,
}) async {
  final container = await montarApp(
    tester,
    esTecnico: esTecnico,
    rutaInicial: Rutas.configuracion,
  );
  await tester.pumpAndSettle();
  expect(find.text('Configuración'), findsOneWidget);
  return container;
}

void _esperarOscuro(WidgetTester tester, String pantalla) {
  expect(_tema(tester).brightness, Brightness.dark, reason: pantalla);
  expect(
    _tema(tester).scaffoldBackgroundColor,
    ColoresOscuro.bg,
    reason: pantalla,
  );
}

void main() {
  testWidgets(
    'TC-HU-052-01 al elegir English la app cambia de idioma sin reiniciar',
    (tester) async {
      final container = await montarApp(
        tester,
        esTecnico: false,
        rutaInicial: Rutas.configuracion,
      );
      await tester.pumpAndSettle();

      final elementoApp = tester.element(find.byType(KnockApp));
      final estadoRouter = tester.state(
        find.byWidgetPredicate((w) => w is Router),
      );

      await tocarTexto(tester, 'English');

      expect(container.read(preferenciasProvider).idioma, const Locale('en'));
      expect(find.text('Settings'), findsOneWidget);
      for (final texto in [
        'Language',
        'Español',
        'English',
        'Theme',
        'Automatic',
        'Same as your phone',
        'Light',
        'Dark',
      ]) {
        expect(find.text(texto), findsOneWidget, reason: texto);
      }
      expect(find.text('Idioma'), findsNothing);
      expect(etiquetasDeLaBarra(tester), [
        'Home',
        'Explore',
        'Activity',
        'My account',
      ]);
      expect(ubicacion(container), Rutas.configuracion);
      expect(indiceSeleccionado(tester), 3);
      expect(tester.element(find.byType(KnockApp)), same(elementoApp));
      expect(
        tester.state(find.byWidgetPredicate((w) => w is Router)),
        same(estadoRouter),
      );

      await tocarTexto(tester, 'Español');
      expect(container.read(preferenciasProvider).idioma, const Locale('es'));
      expect(find.text('Configuración'), findsOneWidget);
      expect(find.text('Idioma'), findsOneWidget);
      expect(etiquetasDeLaBarra(tester).last, 'Mi cuenta');
      expect(ubicacion(container), Rutas.configuracion);
      expect(tester.element(find.byType(KnockApp)), same(elementoApp));
    },
  );

  testWidgets(
    'TC-HU-052-03 con Oscuro todas las pantallas usan el tema oscuro de la maqueta',
    (tester) async {
      _telefonoEn(tester, Brightness.light);
      final container = await _abrirConfiguracion(tester, esTecnico: true);
      expect(_tema(tester).brightness, Brightness.light);

      await tocarTexto(tester, 'Oscuro');
      _esperarOscuro(tester, 'Configuración');

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      _esperarOscuro(tester, 'Mi cuenta');

      for (final (pestana, ruta) in _pestanasYRutas) {
        container.read(appRouterProvider).go(ruta);
        await tester.pumpAndSettle();
        expect(find.text(pestana), findsOneWidget);
        _esperarOscuro(tester, pestana);
      }

      container.read(appRouterProvider).go(Rutas.configuracion);
      await tester.pumpAndSettle();
      _esperarOscuro(tester, 'Configuración otra vez');
    },
  );

  testWidgets('TC-HU-052-04 con Automático la app sigue el tema del teléfono', (
    tester,
  ) async {
    _telefonoEn(tester, Brightness.light);
    await _abrirConfiguracion(tester);
    // Se elige otro y luego Automático, para que el cambio venga del radio.
    await tocarTexto(tester, 'Oscuro');
    await tocarTexto(tester, 'Automático');

    expect(_modoElegido(tester), ThemeMode.system);
    expect(_tema(tester).brightness, Brightness.light);

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpAndSettle();
    _esperarOscuro(tester, 'teléfono en oscuro');

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    await tester.pumpAndSettle();
    expect(_tema(tester).brightness, Brightness.light);
    expect(_tema(tester).scaffoldBackgroundColor, ColoresClaro.crema);
  });

  testWidgets('TC-HU-052-04 con Claro la app ignora el tema del teléfono', (
    tester,
  ) async {
    _telefonoEn(tester, Brightness.light);
    await _abrirConfiguracion(tester);
    await tocarTexto(tester, 'Claro');
    expect(_modoElegido(tester), ThemeMode.light);

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpAndSettle();
    expect(_tema(tester).brightness, Brightness.light);
    expect(_tema(tester).scaffoldBackgroundColor, ColoresClaro.crema);
  });

  for (final brillo in Brightness.values) {
    testWidgets(
      'TC-HU-052-10 los selectores tienen semántica de radio y cumplen las guías (${brillo.name})',
      (tester) async {
        final semantica = tester.ensureSemantics();
        _telefonoEn(tester, brillo);
        await _abrirConfiguracion(tester);
        expect(_tema(tester).brightness, brillo);

        for (final encabezado in ['Idioma', 'Tema']) {
          expect(
            tester.getSemantics(find.text(encabezado)),
            isSemantics(label: encabezado, isHeader: true),
            reason: encabezado,
          );
        }

        // Español y Automático vienen marcados (valores iniciales).
        final opciones = {
          'Español': true,
          'English': false,
          'Automático\nIgual que el teléfono': true,
          'Claro': false,
          'Oscuro': false,
        };
        final radios = find.byWidgetPredicate((w) => w is RadioListTile);
        expect(radios, findsNWidgets(opciones.length));
        var i = 0;
        for (final MapEntry(key: etiqueta, value: marcado)
            in opciones.entries) {
          expect(
            tester.getSemantics(radios.at(i++)),
            isSemantics(
              label: etiqueta,
              hasCheckedState: true,
              isChecked: marcado,
              isInMutuallyExclusiveGroup: true,
              hasTapAction: true,
            ),
            reason: etiqueta,
          );
        }

        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        semantica.dispose();
      },
    );
  }

  testWidgets('TC-HU-052-10 soporta texto al 200 % sin desbordes', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(320, 640)
      ..devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await _abrirConfiguracion(tester);
    expect(
      MediaQuery.textScalerOf(tester.element(find.byType(Scaffold))).scale(10),
      20,
    );

    // Recorre la lista completa y elige la última opción.
    await tocarTexto(tester, 'Oscuro');
    expect(_modoElegido(tester), ThemeMode.dark);
    await tocarTexto(tester, 'English');
    expect(find.text('Settings'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

ThemeMode _modoElegido(WidgetTester tester) => tester
    .widget<RadioGroup<ThemeMode>>(find.byType(RadioGroup<ThemeMode>))
    .groupValue!;
