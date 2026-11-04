import 'package:app/core/router/rutas.dart';
import 'package:app/features/cuenta/presentation/widgets/menu_de_prueba.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../soporte/montar_app.dart';

void main() {
  testWidgets(
    'TC-HU-052-09 en release Mi cuenta muestra Configuración y no el modo técnico',
    (tester) async {
      final container = await montarApp(
        tester,
        esTecnico: false,
        interruptorDePrueba: false,
      );
      await tester.tap(enLaBarra('Mi cuenta'));
      await tester.pumpAndSettle();

      expect(find.text('Configuración'), findsOneWidget);
      expect(find.text('Modo técnico (prueba)'), findsNothing);
      expect(find.byType(MenuDePrueba), findsNothing);
      expect(find.byType(SwitchListTile), findsNothing);

      await tocarTexto(tester, 'Configuración');
      expect(ubicacion(container), Rutas.configuracion);
      expect(enElTitulo('Configuración'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(indiceSeleccionado(tester), 3);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(ubicacion(container), Rutas.cuenta);
      expect(enElTitulo('Mi cuenta'), findsOneWidget);
    },
  );

  testWidgets(
    'TC-HU-052-09 fuera de release el menú de prueba solo tiene el modo técnico',
    (tester) async {
      await montarApp(tester, esTecnico: false);
      await tester.tap(enLaBarra('Mi cuenta'));
      await tester.pumpAndSettle();

      expect(find.text('Configuración'), findsOneWidget);
      expect(find.byType(MenuDePrueba), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(MenuDePrueba),
          matching: find.byType(SwitchListTile),
        ),
        findsOneWidget,
      );
      expect(find.text('Modo técnico (prueba)'), findsOneWidget);
      // Ningún selector de tema ni idioma fuera de Configuración.
      expect(find.byType(RadioListTile<ThemeMode>), findsNothing);
      expect(find.byType(RadioListTile<Locale>), findsNothing);
      expect(find.text('Tema'), findsNothing);
      expect(find.text('Idioma'), findsNothing);

      // El interruptor sigue dando la pestaña Trabajo.
      await tester.tap(find.text('Modo técnico (prueba)'));
      await tester.pumpAndSettle();
      expect(enLaBarra('Trabajo'), findsOneWidget);
    },
  );
}
