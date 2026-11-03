import 'dart:io';

import 'package:app/core/preferencias/almacen_preferencias.dart';
import 'package:app/core/preferencias/preferencias_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// `app/l10n.yaml` con las carpetas cambiadas a las de la prueba: así los ARB
/// de prueba se generan con las mismas opciones que la app.
String _l10nDePrueba() => [
  for (final linea in File('l10n.yaml').readAsLinesSync())
    if (linea.startsWith('arb-dir:'))
      'arb-dir: arb'
    else if (linea.startsWith('output-dir:'))
      'output-dir: generado'
    else
      linea,
].join('\n');

void main() {
  test('TC-HU-052-02 una clave sin traducción al inglés se muestra en español', () async {
    final temporal = Directory.systemTemp.createTempSync('knock_respaldo_');
    addTearDown(() => temporal.deleteSync(recursive: true));
    Directory('${temporal.path}/arb').createSync();
    for (final arb in ['app_es.arb', 'app_en.arb']) {
      File('test/l10n/respaldo/$arb').copySync('${temporal.path}/arb/$arb');
    }
    File('${temporal.path}/l10n.yaml').writeAsStringSync(_l10nDePrueba());
    // gen-l10n solo exige `flutter: generate: true`.
    File('${temporal.path}/pubspec.yaml')
        .writeAsStringSync('name: respaldo\nflutter:\n  generate: true\n');

    final resultado = await Process.run(
      'flutter',
      ['gen-l10n'],
      workingDirectory: temporal.path,
      runInShell: true,
    );
    expect(resultado.exitCode, 0, reason: '${resultado.stderr}');

    final ingles = File('${temporal.path}/generado/app_localizations_en.dart')
        .readAsStringSync();
    expect(ingles, contains('class AppLocalizationsEn'));
    // La clave traducida sale en inglés; la que falta, en español (no vacía
    // ni con el nombre de la clave).
    expect(ingles, contains("String get respaldoSaludo => 'Hello';"));
    expect(
      ingles,
      contains(
        "String get respaldoSinTraducir => 'Este texto solo está en español';",
      ),
    );
  }, timeout: const Timeout(Duration(minutes: 3)));

  test('TC-HU-052-02 un idioma no soportado se resuelve a español', () async {
    expect(idiomasSoportados.first, const Locale('es'));

    for (final pedido in ['fr', 'pt']) {
      SharedPreferences.setMockInitialValues({
        AlmacenPreferenciasShared.claveIdioma: pedido,
      });
      final container = ProviderContainer(
        overrides: [
          almacenPreferenciasProvider.overrideWithValue(
            AlmacenPreferenciasShared(await SharedPreferences.getInstance()),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(
        container.read(preferenciasProvider).idioma,
        const Locale('es'),
        reason: pedido,
      );
      expect(
        () => container
            .read(preferenciasProvider.notifier)
            .cambiarIdioma(Locale(pedido)),
        throwsArgumentError,
      );
      expect(container.read(preferenciasProvider).idioma, const Locale('es'));
    }
  });
}
