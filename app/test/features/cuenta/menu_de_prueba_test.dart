import 'package:app/app.dart';
import 'package:app/core/preferencias/preferencias_provider.dart';
import 'package:app/core/router/rutas.dart';
import 'package:app/core/tema/colores.dart';
import 'package:app/features/cuenta/presentation/widgets/menu_de_prueba.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../soporte/montar_app.dart';

/// Tema que ve la pantalla activa.
ThemeData _temaActivo(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(AppBar)));

void main() {
  group('TC-TT-MOB-02-01 menú de prueba de tema e idioma', () {
    testWidgets('TC-TT-MOB-02-01 cambia tema e idioma sin reiniciar la app', (
      tester,
    ) async {
      // El teléfono está en oscuro: con «Sistema» la app lo sigue.
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      final container = await montarApp(tester, esTecnico: true);
      expect(container.read(preferenciasProvider), Preferencias.inicial);

      await tester.tap(enLaBarra('Mi cuenta'));
      await tester.pumpAndSettle();
      expect(ubicacion(container), Rutas.cuenta);

      // Mismo árbol durante todo el recorrido: ni la app ni el router se
      // vuelven a montar.
      final elementoApp = tester.element(find.byType(KnockApp));
      final estadoRouter = tester.state(
        find.byWidgetPredicate((w) => w is Router),
      );

      expect(_temaActivo(tester).brightness, Brightness.dark);
      expect(
        _temaActivo(tester).scaffoldBackgroundColor,
        esquemaOscuro.surface,
      );

      await tocarTexto(tester, 'Claro');
      expect(container.read(preferenciasProvider).modoTema, ThemeMode.light);
      expect(_temaActivo(tester).brightness, Brightness.light);
      expect(_temaActivo(tester).scaffoldBackgroundColor, ColoresClaro.crema);

      await tocarTexto(tester, 'Oscuro');
      expect(container.read(preferenciasProvider).modoTema, ThemeMode.dark);
      expect(_temaActivo(tester).brightness, Brightness.dark);
      expect(_temaActivo(tester).scaffoldBackgroundColor, ColoresOscuro.bg);

      await tocarTexto(tester, 'English');
      expect(container.read(preferenciasProvider).idioma, const Locale('en'));
      expect(enElTitulo('My account'), findsOneWidget);
      expect(enElTitulo('Mi cuenta'), findsNothing);
      expect(etiquetasDeLaBarra(tester), [
        'Home',
        'Explore',
        'Activity',
        'Work',
        'My account',
      ]);
      expect(find.text('Theme (test)'), findsOneWidget);

      await tocarTexto(tester, 'Español');
      expect(enElTitulo('Mi cuenta'), findsOneWidget);
      expect(find.text('Tema (prueba)'), findsOneWidget);

      // Se conservan la pestaña, la ruta y el tema elegido.
      expect(indiceSeleccionado(tester), 4);
      expect(ubicacion(container), Rutas.cuenta);
      expect(_temaActivo(tester).brightness, Brightness.dark);
      expect(tester.element(find.byType(KnockApp)), same(elementoApp));
      expect(
        tester.state(find.byWidgetPredicate((w) => w is Router)),
        same(estadoRouter),
      );
    });

    testWidgets(
      'TC-TT-MOB-02-01 con tema Sistema la app sigue el claro del teléfono',
      (tester) async {
        tester.platformDispatcher.platformBrightnessTestValue =
            Brightness.light;
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

        await montarApp(tester, esTecnico: false);
        expect(_temaActivo(tester).brightness, Brightness.light);
        expect(_temaActivo(tester).scaffoldBackgroundColor, ColoresClaro.crema);
        expect(enElTitulo('Inicio'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-TT-MOB-02-01 sin modo de prueba (release) Mi cuenta no muestra el menú de tema e idioma',
      (tester) async {
        await montarApp(tester, esTecnico: false, interruptorDePrueba: false);
        await tester.tap(enLaBarra('Mi cuenta'));
        await tester.pumpAndSettle();

        expect(enElTitulo('Mi cuenta'), findsOneWidget);
        expect(find.byType(MenuDePrueba), findsNothing);
        expect(find.byType(RadioListTile<ThemeMode>), findsNothing);
        expect(find.byType(RadioListTile<Locale>), findsNothing);
        expect(find.text('Tema (prueba)'), findsNothing);
        expect(find.text('Idioma (prueba)'), findsNothing);
      },
    );
  });
}
