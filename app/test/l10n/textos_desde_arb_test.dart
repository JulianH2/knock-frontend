import 'package:app/core/preferencias/preferencias_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../soporte/montar_app.dart';

/// Todo texto que pinta la pantalla activa: `Text` (barra, títulos, menú)
/// y los mensajes de `Tooltip` (los lee el lector de pantalla).
List<String> _textosVisibles(WidgetTester tester) => [
  for (final texto in tester.widgetList<Text>(find.byType(Text)))
    texto.data ?? texto.textSpan!.toPlainText(),
  for (final ayuda in tester.widgetList<Tooltip>(find.byType(Tooltip)))
    if (ayuda.message != null) ayuda.message!,
];

const _clavesDePestana = [
  'tabInicio',
  'tabExplorar',
  'tabActividad',
  'tabTrabajo',
  'tabCuenta',
];

void main() {
  group('TC-TT-MOB-02-02 textos solo desde ARB', () {
    test(
      'TC-TT-MOB-02-02 app_es.arb y app_en.arb tienen las mismas claves',
      () {
        final es = leerArb('es');
        final en = leerArb('en');

        expect(es.keys.toSet(), en.keys.toSet());
        expect(es, isNotEmpty);
        for (final MapEntry<String, String>(:key, :value) in [
          ...es.entries,
          ...en.entries,
        ]) {
          expect(value.trim(), isNotEmpty, reason: key);
        }
      },
    );

    for (final idioma in ['es', 'en']) {
      testWidgets(
        'TC-TT-MOB-02-02 todo texto visible sale del ARB del idioma activo ($idioma)',
        (tester) async {
          final arb = leerArb(idioma);
          final permitidos = arb.values.toSet();
          final container = await montarApp(tester, esTecnico: true);
          container
              .read(preferenciasProvider.notifier)
              .cambiarIdioma(Locale(idioma));
          await tester.pumpAndSettle();

          expect(
            tester.widget<Title>(find.byType(Title)).title,
            arb['appTitle'],
          );

          final vistos = <String>{};
          for (final clave in _clavesDePestana) {
            await tester.tap(enLaBarra(arb[clave]!));
            await tester.pumpAndSettle();
            expect(enElTitulo(arb[clave]!), findsOneWidget, reason: clave);

            final textos = _textosVisibles(tester);
            for (final texto in textos) {
              expect(
                permitidos,
                contains(texto),
                reason: '«$texto» en ${arb[clave]} no está en app_$idioma.arb',
              );
            }
            vistos.addAll(textos);
          }

          // El recorrido vio las 5 pestañas y el menú de prueba completo.
          for (final clave in [
            ..._clavesDePestana,
            'pruebaModoTecnico',
            'pruebaTema',
            'pruebaTemaSistema',
            'pruebaTemaClaro',
            'pruebaTemaOscuro',
            'pruebaIdioma',
            'pruebaIdiomaEspanol',
            'pruebaIdiomaIngles',
          ]) {
            expect(vistos, contains(arb[clave]), reason: clave);
          }
        },
      );
    }
  });
}
