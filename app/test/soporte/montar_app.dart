import 'dart:convert';
import 'dart:io';

import 'package:app/app.dart';
import 'package:app/core/router/app_router.dart';
import 'package:app/core/sesion/es_tecnico_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Indicador de técnico con valor inicial fijo; `cambiar` sigue funcionando.
class _EsTecnicoInicial extends EsTecnicoNotifier {
  _EsTecnicoInicial(this._inicial);

  final bool _inicial;

  @override
  bool build() => _inicial;
}

/// Monta `KnockApp` con un contenedor propio (sin red).
Future<ProviderContainer> montarApp(
  WidgetTester tester, {
  required bool esTecnico,
  bool interruptorDePrueba = true,
}) async {
  final container = ProviderContainer(
    overrides: [
      esTecnicoProvider.overrideWith(() => _EsTecnicoInicial(esTecnico)),
      interruptorDePruebaProvider.overrideWithValue(interruptorDePrueba),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const KnockApp()),
  );
  await tester.pumpAndSettle();
  return container;
}

/// Textos de un ARB (`lib/l10n/app_<idioma>.arb`) sin los metadatos `@…`.
///
/// Archivo local del repositorio: `flutter test` corre desde `app/`.
Map<String, String> leerArb(String idioma) {
  final json = jsonDecode(
    File('lib/l10n/app_$idioma.arb').readAsStringSync(),
  ) as Map<String, Object?>;
  return {
    for (final MapEntry(:key, :value) in json.entries)
      if (!key.startsWith('@')) key: value! as String,
  };
}

/// Etiquetas de la barra inferior, en orden.
List<String> etiquetasDeLaBarra(WidgetTester tester) => tester
    .widgetList<NavigationDestination>(find.byType(NavigationDestination))
    .map((d) => d.label)
    .toList();

Finder enLaBarra(String etiqueta) => find.descendant(
  of: find.byType(NavigationBar),
  matching: find.text(etiqueta),
);

Finder enElTitulo(String texto) =>
    find.descendant(of: find.byType(AppBar), matching: find.text(texto));

int indiceSeleccionado(WidgetTester tester) =>
    tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex;

String ubicacion(ProviderContainer container) => container
    .read(appRouterProvider)
    .routerDelegate
    .currentConfiguration
    .uri
    .path;

/// Desplaza hasta el texto si hace falta, lo toca y espera a que se asiente.
Future<void> tocarTexto(WidgetTester tester, String texto) async {
  await tester.ensureVisible(find.text(texto));
  await tester.pumpAndSettle();
  await tester.tap(find.text(texto));
  await tester.pumpAndSettle();
}
