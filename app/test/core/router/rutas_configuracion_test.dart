import 'package:app/core/router/app_router.dart';
import 'package:app/core/router/rutas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../soporte/montar_app.dart';

void main() {
  testWidgets('TC-HU-052-09 la ruta de Configuración cuelga de Mi cuenta', (
    tester,
  ) async {
    expect(Rutas.configuracion, '${Rutas.cuenta}/configuracion');
    expect(
      redireccionPorRol(esTecnico: false, ubicacion: Rutas.configuracion),
      isNull,
    );

    final container = await montarApp(tester, esTecnico: true);
    container.read(appRouterProvider).go(Rutas.configuracion);
    await tester.pumpAndSettle();

    expect(ubicacion(container), Rutas.configuracion);
    expect(enElTitulo('Configuración'), findsOneWidget);
    // Dentro de la barra, con Mi cuenta (la quinta pestaña del técnico)
    // seleccionada.
    expect(indiceSeleccionado(tester), 4);
    expect(find.byType(BackButton), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(ubicacion(container), Rutas.cuenta);
    expect(indiceSeleccionado(tester), 4);
  });
}
