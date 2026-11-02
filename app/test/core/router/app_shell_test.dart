import 'package:app/core/router/app_router.dart';
import 'package:app/core/router/rutas.dart';
import 'package:app/core/sesion/es_tecnico_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../soporte/montar_app.dart';

/// Etiquetas de la barra inferior, en orden.
List<String> _etiquetasDeLaBarra(WidgetTester tester) => tester
    .widgetList<NavigationDestination>(find.byType(NavigationDestination))
    .map((d) => d.label)
    .toList();

int _indiceSeleccionado(WidgetTester tester) =>
    tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex;

/// Título visible en la barra superior de la pantalla activa.
Finder _titulo(String texto) =>
    find.descendant(of: find.byType(AppBar), matching: find.text(texto));

Finder _destino(String etiqueta) => find.descendant(
  of: find.byType(NavigationBar),
  matching: find.text(etiqueta),
);

String _ubicacion(ProviderContainer container) => container
    .read(appRouterProvider)
    .routerDelegate
    .currentConfiguration
    .uri
    .path;

void main() {
  group('TC-TT-MOB-01-02 pestaña Trabajo según el rol', () {
    testWidgets(
      'TC-TT-MOB-01-02 oculta la pestaña Trabajo si el usuario no es técnico',
      (tester) async {
        final container = await montarApp(tester, esTecnico: false);

        expect(_etiquetasDeLaBarra(tester), [
          'Inicio',
          'Explorar',
          'Actividad',
          'Mi cuenta',
        ]);
        expect(_destino('Trabajo'), findsNothing);

        container.read(appRouterProvider).go(Rutas.trabajo);
        await tester.pumpAndSettle();

        expect(_ubicacion(container), Rutas.inicio);
        expect(_titulo('Inicio'), findsOneWidget);
        expect(_titulo('Trabajo'), findsNothing);
        expect(_indiceSeleccionado(tester), 0);
      },
    );

    testWidgets(
      'TC-TT-MOB-01-02 muestra Trabajo entre Actividad y Mi cuenta si es técnico',
      (tester) async {
        final container = await montarApp(tester, esTecnico: true);

        expect(_etiquetasDeLaBarra(tester), [
          'Inicio',
          'Explorar',
          'Actividad',
          'Trabajo',
          'Mi cuenta',
        ]);

        container.read(appRouterProvider).go(Rutas.trabajo);
        await tester.pumpAndSettle();

        expect(_ubicacion(container), Rutas.trabajo);
        expect(_titulo('Trabajo'), findsOneWidget);
        expect(_indiceSeleccionado(tester), 3);
      },
    );

    testWidgets(
      'TC-TT-MOB-01-02 al dejar de ser técnico estando en Trabajo vuelve a Inicio',
      (tester) async {
        final container = await montarApp(tester, esTecnico: true);
        container.read(appRouterProvider).go(Rutas.trabajo);
        await tester.pumpAndSettle();
        expect(_titulo('Trabajo'), findsOneWidget);

        container.read(esTecnicoProvider.notifier).cambiar(esTecnico: false);
        await tester.pumpAndSettle();

        expect(_ubicacion(container), Rutas.inicio);
        expect(_titulo('Inicio'), findsOneWidget);
        expect(_destino('Trabajo'), findsNothing);
      },
    );

    testWidgets(
      'TC-TT-MOB-01-02 el interruptor de prueba de Mi cuenta muestra y oculta Trabajo',
      (tester) async {
        final container = await montarApp(tester, esTecnico: false);
        await tester.tap(_destino('Mi cuenta'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Modo técnico (prueba)'));
        await tester.pumpAndSettle();

        expect(container.read(esTecnicoProvider), isTrue);
        expect(_destino('Trabajo'), findsOneWidget);
        expect(_titulo('Mi cuenta'), findsOneWidget);
        expect(_indiceSeleccionado(tester), 4);

        await tester.tap(find.text('Modo técnico (prueba)'));
        await tester.pumpAndSettle();

        expect(container.read(esTecnicoProvider), isFalse);
        expect(_destino('Trabajo'), findsNothing);
        expect(_indiceSeleccionado(tester), 3);
      },
    );

    testWidgets(
      'TC-TT-MOB-01-02 sin el interruptor de prueba (release) Mi cuenta no ofrece Modo técnico',
      (tester) async {
        await montarApp(tester, esTecnico: false, interruptorDePrueba: false);
        await tester.tap(_destino('Mi cuenta'));
        await tester.pumpAndSettle();

        expect(_titulo('Mi cuenta'), findsOneWidget);
        expect(find.byType(SwitchListTile), findsNothing);
        expect(find.text('Modo técnico (prueba)'), findsNothing);
      },
    );
  });

  group('TC-TT-MOB-01-04 navegación por la barra inferior', () {
    testWidgets('TC-TT-MOB-01-04 tocar cada pestaña muestra su pantalla', (
      tester,
    ) async {
      final container = await montarApp(tester, esTecnico: true);
      expect(_titulo('Inicio'), findsOneWidget);
      expect(_indiceSeleccionado(tester), 0);

      const recorrido = <(String, String, int)>[
        ('Explorar', Rutas.explorar, 1),
        ('Actividad', Rutas.actividad, 2),
        ('Trabajo', Rutas.trabajo, 3),
        ('Mi cuenta', Rutas.cuenta, 4),
        ('Inicio', Rutas.inicio, 0),
      ];
      const titulos = [
        'Inicio',
        'Explorar',
        'Actividad',
        'Trabajo',
        'Mi cuenta',
      ];

      for (final (etiqueta, ruta, indice) in recorrido) {
        await tester.tap(_destino(etiqueta));
        await tester.pumpAndSettle();

        expect(_titulo(etiqueta), findsOneWidget, reason: etiqueta);
        for (final otro in titulos.where((t) => t != etiqueta)) {
          expect(_titulo(otro), findsNothing, reason: '$etiqueta vs $otro');
        }
        expect(_indiceSeleccionado(tester), indice, reason: etiqueta);
        expect(_ubicacion(container), ruta, reason: etiqueta);
      }
    });

    testWidgets(
      'TC-TT-MOB-01-04 la barra cumple tamaño táctil y etiquetas (A11Y)',
      (tester) async {
        final semantica = tester.ensureSemantics();
        await montarApp(tester, esTecnico: true);

        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

        semantica.dispose();
      },
    );

    testWidgets(
      'TC-TT-MOB-01-04 con texto al 200 % la barra se muestra sin desbordes (A11Y)',
      (tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        await montarApp(tester, esTecnico: true);

        expect(tester.takeException(), isNull);
        expect(_etiquetasDeLaBarra(tester), hasLength(5));
        await tester.tap(_destino('Mi cuenta'));
        await tester.pumpAndSettle();
        expect(_titulo('Mi cuenta'), findsOneWidget);
      },
    );
  });
}
