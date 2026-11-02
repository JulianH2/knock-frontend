import 'package:app/core/preferencias/preferencias_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../soporte/montar_app.dart';

const _clavesDePestana = [
  'tabInicio',
  'tabExplorar',
  'tabActividad',
  'tabTrabajo',
  'tabCuenta',
];

void main() {
  group('TC-TT-MOB-02-04 barra inferior en inglés', () {
    testWidgets(
      'TC-TT-MOB-02-04 al cambiar el idioma a inglés las pestañas cambian de texto',
      (tester) async {
        final es = leerArb('es');
        final en = leerArb('en');
        final container = await montarApp(tester, esTecnico: true);

        expect(etiquetasDeLaBarra(tester), [
          for (final c in _clavesDePestana) es[c],
        ]);
        expect(etiquetasDeLaBarra(tester), [
          'Inicio',
          'Explorar',
          'Actividad',
          'Trabajo',
          'Mi cuenta',
        ]);

        container
            .read(preferenciasProvider.notifier)
            .cambiarIdioma(const Locale('en'));
        await tester.pumpAndSettle();

        expect(etiquetasDeLaBarra(tester), [
          for (final c in _clavesDePestana) en[c],
        ]);
        expect(etiquetasDeLaBarra(tester), [
          'Home',
          'Explore',
          'Activity',
          'Work',
          'My account',
        ]);
        for (final c in _clavesDePestana) {
          expect(enLaBarra(es[c]!), findsNothing, reason: es[c]);
        }
        expect(enElTitulo('Home'), findsOneWidget);
      },
    );

    for (final modo in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets(
        'TC-TT-MOB-02-04 la barra y Mi cuenta cumplen el contraste de texto en ${modo.name} (A11Y)',
        (tester) async {
          final semantica = tester.ensureSemantics();
          final container = await montarApp(tester, esTecnico: true);
          container.read(preferenciasProvider.notifier).cambiarTema(modo);
          await tester.pumpAndSettle();

          await expectLater(tester, meetsGuideline(textContrastGuideline));

          await tester.tap(enLaBarra('Mi cuenta'));
          await tester.pumpAndSettle();
          await expectLater(tester, meetsGuideline(textContrastGuideline));
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

          semantica.dispose();
        },
      );
    }
  });
}
