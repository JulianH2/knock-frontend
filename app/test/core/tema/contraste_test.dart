import 'package:app/core/tema/colores.dart';
import 'package:app/core/tema/contraste.dart';
import 'package:app/core/tema/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Todos los pares texto/fondo (`onX`/`X`) del esquema, con su nombre.
Map<String, (Color, Color)> _paresDelEsquema(ColorScheme e) => {
  'onPrimary/primary': (e.onPrimary, e.primary),
  'onPrimaryContainer/primaryContainer': (
    e.onPrimaryContainer,
    e.primaryContainer,
  ),
  'onPrimaryFixed/primaryFixed': (e.onPrimaryFixed, e.primaryFixed),
  'onPrimaryFixed/primaryFixedDim': (e.onPrimaryFixed, e.primaryFixedDim),
  'onPrimaryFixedVariant/primaryFixed': (
    e.onPrimaryFixedVariant,
    e.primaryFixed,
  ),
  'onPrimaryFixedVariant/primaryFixedDim': (
    e.onPrimaryFixedVariant,
    e.primaryFixedDim,
  ),
  'onSecondary/secondary': (e.onSecondary, e.secondary),
  'onSecondaryContainer/secondaryContainer': (
    e.onSecondaryContainer,
    e.secondaryContainer,
  ),
  'onSecondaryFixed/secondaryFixed': (e.onSecondaryFixed, e.secondaryFixed),
  'onSecondaryFixed/secondaryFixedDim': (
    e.onSecondaryFixed,
    e.secondaryFixedDim,
  ),
  'onSecondaryFixedVariant/secondaryFixed': (
    e.onSecondaryFixedVariant,
    e.secondaryFixed,
  ),
  'onSecondaryFixedVariant/secondaryFixedDim': (
    e.onSecondaryFixedVariant,
    e.secondaryFixedDim,
  ),
  'onTertiary/tertiary': (e.onTertiary, e.tertiary),
  'onTertiaryContainer/tertiaryContainer': (
    e.onTertiaryContainer,
    e.tertiaryContainer,
  ),
  'onTertiaryFixed/tertiaryFixed': (e.onTertiaryFixed, e.tertiaryFixed),
  'onTertiaryFixed/tertiaryFixedDim': (e.onTertiaryFixed, e.tertiaryFixedDim),
  'onTertiaryFixedVariant/tertiaryFixed': (
    e.onTertiaryFixedVariant,
    e.tertiaryFixed,
  ),
  'onTertiaryFixedVariant/tertiaryFixedDim': (
    e.onTertiaryFixedVariant,
    e.tertiaryFixedDim,
  ),
  'onError/error': (e.onError, e.error),
  'onErrorContainer/errorContainer': (e.onErrorContainer, e.errorContainer),
  'onInverseSurface/inverseSurface': (e.onInverseSurface, e.inverseSurface),
  'inversePrimary/inverseSurface': (e.inversePrimary, e.inverseSurface),
  for (final (nombre, fondo) in _superficies(e)) ...{
    'onSurface/$nombre': (e.onSurface, fondo),
    'onSurfaceVariant/$nombre': (e.onSurfaceVariant, fondo),
  },
};

List<(String, Color)> _superficies(ColorScheme e) => [
  ('surface', e.surface),
  ('surfaceDim', e.surfaceDim),
  ('surfaceBright', e.surfaceBright),
  ('surfaceContainerLowest', e.surfaceContainerLowest),
  ('surfaceContainerLow', e.surfaceContainerLow),
  ('surfaceContainer', e.surfaceContainer),
  ('surfaceContainerHigh', e.surfaceContainerHigh),
  ('surfaceContainerHighest', e.surfaceContainerHighest),
];

/// Los 7 pares de la maqueta por debajo de 4.5:1 (spec §8 decisión 1), con
/// el valor reportado: (texto, fondo, contraste).
const _paresProhibidos = <String, (Color, Color, double)>{
  'claro amber/crema': (ColoresClaro.amber, ColoresClaro.crema, 2.98),
  'claro amber/blanco': (ColoresClaro.amber, ColoresClaro.surface, 3.24),
  'claro blanco/amber': (ColoresClaro.surface, ColoresClaro.amber, 3.24),
  'oscuro mut/navybg': (ColoresOscuro.mut, ColoresOscuro.navybg, 3.44),
  'oscuro navy/navybg': (ColoresOscuro.navy, ColoresOscuro.navybg, 4.25),
  'oscuro amber/navybg': (ColoresOscuro.amber, ColoresOscuro.navybg, 2.50),
  'oscuro amber/navy-soft': (ColoresOscuro.amber, ColoresOscuro.navySoft, 4.01),
};

Matcher _cumpleTexto(String par) => greaterThanOrEqualTo(contrasteMinimoTexto);

void _esperaContraste(Color texto, Color fondo, String par, double minimo) {
  final relacion = relacionDeContraste(texto, fondo);
  expect(
    relacion,
    greaterThanOrEqualTo(minimo),
    reason: '$par da ${relacion.toStringAsFixed(2)}:1 (mínimo $minimo)',
  );
}

void main() {
  group('TC-TT-MOB-02-03 contraste WCAG 2.x', () {
    test('TC-TT-MOB-02-03 la fórmula de contraste da 21:1 con blanco y negro y 1:1 con el mismo color', () {
      const blanco = Color(0xFFFFFFFF);
      const negro = Color(0xFF000000);
      expect(relacionDeContraste(blanco, negro), closeTo(21, 0.001));
      expect(relacionDeContraste(negro, blanco), closeTo(21, 0.001));
      expect(relacionDeContraste(ColoresClaro.crema, ColoresClaro.crema), 1);
      // Valores calculados a mano en la spec (§8 decisión 1).
      expect(
        relacionDeContraste(ColoresClaro.ink, ColoresClaro.amber),
        closeTo(5.27, 0.01),
      );
      expect(
        relacionDeContraste(ColoresClaro.ink, ColoresClaro.crema),
        closeTo(15.72, 0.01),
      );
    });

    test('TC-TT-MOB-02-03 el texto sobre crema cumple al menos 4.5:1', () {
      const textosClaros = {
        'ink': ColoresClaro.ink,
        'ink2': ColoresClaro.ink2,
        'mut': ColoresClaro.mut,
        'amber-ink': ColoresClaro.amberInk,
        'navy': ColoresClaro.navy,
      };
      for (final MapEntry(key: nombre, value: texto) in textosClaros.entries) {
        _esperaContraste(
          texto,
          ColoresClaro.crema,
          '$nombre/crema',
          contrasteMinimoTexto,
        );
        _esperaContraste(
          texto,
          ColoresClaro.surface,
          '$nombre/blanco',
          contrasteMinimoTexto,
        );
      }
      // El fondo de la app en claro es crema.
      expect(esquemaClaro.surface, ColoresClaro.crema);
      expect(temaClaro.scaffoldBackgroundColor, ColoresClaro.crema);
    });

    test('TC-TT-MOB-02-03 el texto del tema oscuro cumple al menos 4.5:1 sobre sus fondos', () {
      const textos = {
        'ink': ColoresOscuro.ink,
        'ink2': ColoresOscuro.ink2,
        'mut': ColoresOscuro.mut,
        'navy': ColoresOscuro.navy,
        'amber': ColoresOscuro.amber,
      };
      const fondos = {
        'bg': ColoresOscuro.bg,
        'stage': ColoresOscuro.stage,
        'surface': ColoresOscuro.surface,
        'surface2': ColoresOscuro.surface2,
      };
      for (final MapEntry(key: t, value: texto) in textos.entries) {
        for (final MapEntry(key: f, value: fondo) in fondos.entries) {
          _esperaContraste(texto, fondo, '$t/$f', contrasteMinimoTexto);
        }
      }
      for (final fondo in [ColoresOscuro.navybg, ColoresOscuro.navySoft]) {
        _esperaContraste(ColoresOscuro.ink, fondo, 'ink/azul', 4.5);
        _esperaContraste(ColoresOscuro.ink2, fondo, 'ink2/azul', 4.5);
      }
    });

    for (final (nombre, esquema) in [
      ('claro', esquemaClaro),
      ('oscuro', esquemaOscuro),
    ]) {
      test(
        'TC-TT-MOB-02-03 todos los pares onX/X del ColorScheme $nombre cumplen al menos 4.5:1',
        () {
          final pares = _paresDelEsquema(esquema);
          expect(pares.length, greaterThanOrEqualTo(38));
          for (final MapEntry(key: par, value: (texto, fondo))
              in pares.entries) {
            expect(
              relacionDeContraste(texto, fondo),
              _cumpleTexto(par),
              reason:
                  '$nombre $par da '
                  '${relacionDeContraste(texto, fondo).toStringAsFixed(2)}:1',
            );
          }
        },
      );
    }

    test('TC-TT-MOB-02-03 ningún par onX/X usa uno de los 7 pares prohibidos y onPrimary en claro no es blanco', () {
      // Regla del líder (2026-10-21): esos pares no se usan para texto ni
      // botones. Se comprueba que siguen por debajo de 4.5:1 (si la paleta
      // cambia, hay que revisar la regla) y que el esquema no los usa.
      for (final MapEntry(key: par, value: (texto, fondo, reportado))
          in _paresProhibidos.entries) {
        final relacion = relacionDeContraste(texto, fondo);
        expect(relacion, closeTo(reportado, 0.01), reason: par);
        expect(relacion, lessThan(contrasteMinimoTexto), reason: par);
      }
      final usados = {
        ..._paresDelEsquema(esquemaClaro).values,
        ..._paresDelEsquema(esquemaOscuro).values,
      };
      for (final MapEntry(key: par, value: (texto, fondo, _))
          in _paresProhibidos.entries) {
        expect(usados.contains((texto, fondo)), isFalse, reason: par);
      }

      expect(esquemaClaro.onPrimary, isNot(const Color(0xFFFFFFFF)));
      expect(esquemaClaro.onPrimary, ColoresClaro.ink);
      expect(esquemaOscuro.onPrimary, ColoresOscuro.bg);
      expect(esquemaOscuro.onSecondaryContainer, ColoresOscuro.ink);
    });

    test('TC-TT-MOB-02-03 en claro los botones sin relleno no usan el naranja como texto', () {
      for (final (nombre, estilo) in [
        ('TextButton', temaClaro.textButtonTheme.style),
        ('OutlinedButton', temaClaro.outlinedButtonTheme.style),
        ('ElevatedButton', temaClaro.elevatedButtonTheme.style),
      ]) {
        final texto = estilo!.foregroundColor!.resolve(<WidgetState>{})!;
        expect(texto, ColoresClaro.amberInk, reason: nombre);
        _esperaContraste(texto, ColoresClaro.crema, nombre, 4.5);
        _esperaContraste(texto, ColoresClaro.surface, nombre, 4.5);
      }
      final radio = temaClaro.radioTheme.fillColor!.resolve({
        WidgetState.selected,
      })!;
      _esperaContraste(
        radio,
        ColoresClaro.crema,
        'radio seleccionado/crema',
        contrasteMinimoComponente,
      );
    });

    test('TC-TT-MOB-02-03 en claro el botón relleno naranja lleva un borde visible sobre crema', () {
      final borde = temaClaro.filledButtonTheme.style!.side!.resolve(
        <WidgetState>{},
      )!;
      _esperaContraste(
        borde.color,
        ColoresClaro.crema,
        'borde del botón relleno/crema',
        contrasteMinimoComponente,
      );
      expect(borde.width, greaterThan(0));
      // El color del botón no cambia: sigue siendo el naranja con tinta.
      expect(temaClaro.colorScheme.primary, ColoresClaro.amber);
      expect(temaOscuro.filledButtonTheme.style!.side, isNull);
    });

    test(
      'TC-TT-MOB-02-03 los temas usan la paleta y la fuente de la maqueta',
      () {
        expect(temaClaro.colorScheme, esquemaClaro);
        expect(temaOscuro.colorScheme, esquemaOscuro);
        expect(temaClaro.brightness, Brightness.light);
        expect(temaOscuro.brightness, Brightness.dark);
        expect(temaOscuro.scaffoldBackgroundColor, ColoresOscuro.bg);
        expect(temaClaro.textTheme.bodyMedium!.fontFamily, familiaTipografica);
        expect(temaOscuro.textTheme.bodyMedium!.fontFamily, familiaTipografica);
      },
    );
  });
}
