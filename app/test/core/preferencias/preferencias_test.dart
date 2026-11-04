import 'package:app/core/preferencias/preferencias_provider.dart';
import 'package:app/l10n/generado/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TC-TT-MOB-02-01 preferencias de tema e idioma (unitarias)', () {
    test('TC-TT-MOB-02-01 estado inicial sistema y español; cambiar tema e idioma actualiza el estado', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final cambios = <Preferencias>[];
      container.listen<Preferencias>(
        preferenciasProvider,
        (_, nuevo) => cambios.add(nuevo),
      );

      expect(
        container.read(preferenciasProvider),
        const Preferencias(modoTema: ThemeMode.system, idioma: Locale('es')),
      );

      final notifier = container.read(preferenciasProvider.notifier);
      notifier.cambiarTema(ThemeMode.light);
      notifier.cambiarTema(ThemeMode.dark);
      notifier.cambiarIdioma(const Locale('en'));

      expect(
        container.read(preferenciasProvider),
        const Preferencias(modoTema: ThemeMode.dark, idioma: Locale('en')),
      );
      expect(cambios.map((p) => (p.modoTema, p.idioma)), [
        (ThemeMode.light, const Locale('es')),
        (ThemeMode.dark, const Locale('es')),
        (ThemeMode.dark, const Locale('en')),
      ]);

      notifier.cambiarIdioma(const Locale('es'));
      notifier.cambiarTema(ThemeMode.system);
      expect(container.read(preferenciasProvider), Preferencias.inicial);
    });

    test(
      'TC-TT-MOB-02-01 un idioma no soportado se rechaza y no cambia el estado',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        expect(
          () => container
              .read(preferenciasProvider.notifier)
              .cambiarIdioma(const Locale('fr')),
          throwsArgumentError,
        );
        expect(container.read(preferenciasProvider).idioma, const Locale('es'));
      },
    );

    test('TC-TT-MOB-02-01 los idiomas soportados son los del ARB y el español va primero', () {
      expect(idiomasSoportados.first, const Locale('es'));
      expect(
        idiomasSoportados.toSet(),
        AppLocalizations.supportedLocales.toSet(),
      );
    });

    test('TC-TT-MOB-02-01 Preferencias compara por valor', () {
      const a = Preferencias(modoTema: ThemeMode.dark, idioma: Locale('en'));
      final b = Preferencias.inicial.copyWith(
        modoTema: ThemeMode.dark,
        idioma: const Locale('en'),
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a == Preferencias.inicial, isFalse);
      expect(Preferencias.inicial.copyWith(), Preferencias.inicial);
    });
  });
}
