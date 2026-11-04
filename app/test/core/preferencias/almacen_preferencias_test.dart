import 'dart:async';

import 'package:app/core/preferencias/almacen_preferencias.dart';
import 'package:app/core/preferencias/preferencias_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _tema = AlmacenPreferenciasShared.claveTema;
const _idioma = AlmacenPreferenciasShared.claveIdioma;

/// Contenedor cuyo almacén es `shared_preferences` con [guardado] en el
/// dispositivo simulado (sin disco ni red).
Future<(ProviderContainer, SharedPreferences)> _conGuardado(
  Map<String, Object> guardado,
) async {
  SharedPreferences.setMockInitialValues(guardado);
  final preferencias = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      almacenPreferenciasProvider.overrideWithValue(
        AlmacenPreferenciasShared(preferencias),
      ),
    ],
  );
  addTearDown(container.dispose);
  return (container, preferencias);
}

/// `SharedPreferences` cuyo guardado falla de la forma indicada.
class _PreferenciasQueFallan extends Fake implements SharedPreferences {
  _PreferenciasQueFallan(this._setString);

  final Future<bool> Function() _setString;

  @override
  Object? get(String key) => null;

  @override
  Future<bool> setString(String key, String value) => _setString();
}

/// Corre [cuerpo] y devuelve lo que se haya escrito con `print` o
/// `debugPrint`.
Future<List<String>> _registrosDe(Future<void> Function() cuerpo) async {
  final registros = <String>[];
  final original = debugPrint;
  debugPrint = (mensaje, {wrapWidth}) => registros.add('$mensaje');
  try {
    await runZoned(
      cuerpo,
      zoneSpecification: ZoneSpecification(
        print: (_, _, _, linea) => registros.add(linea),
      ),
    );
  } finally {
    debugPrint = original;
  }
  return registros;
}

void main() {
  test(
    'TC-HU-052-06 solo se guardan tema e idioma con valores permitidos',
    () async {
      final (container, preferencias) = await _conGuardado({});
      final notifier = container.read(preferenciasProvider.notifier);

      final vistos = <String, Set<Object?>>{_tema: {}, _idioma: {}};
      for (final modo in ThemeMode.values) {
        for (final idioma in idiomasSoportados) {
          notifier
            ..cambiarTema(modo)
            ..cambiarIdioma(idioma);
          await pumpEventQueue();
          // Se relee del almacenamiento simulado, no solo de la caché.
          await preferencias.reload();
          expect(preferencias.getKeys(), {_tema, _idioma});
          vistos[_tema]!.add(preferencias.get(_tema));
          vistos[_idioma]!.add(preferencias.get(_idioma));
        }
      }

      expect(vistos[_tema], {'automatico', 'claro', 'oscuro'});
      expect(vistos[_idioma], {'es', 'en'});
      // Lo último elegido es lo que quedó guardado.
      expect(preferencias.get(_tema), 'oscuro');
      expect(preferencias.get(_idioma), 'en');
    },
  );

  test(
    'TC-HU-052-07 un valor guardado inválido vuelve al valor por defecto',
    () async {
      // Valores válidos: cada uno se lee como su valor de Knock.
      const temasValidos = {
        'automatico': ThemeMode.system,
        'claro': ThemeMode.light,
        'oscuro': ThemeMode.dark,
      };
      const idiomasValidos = {'es': Locale('es'), 'en': Locale('en')};
      for (final MapEntry(:key, :value) in temasValidos.entries) {
        final (container, _) = await _conGuardado({_tema: key});
        expect(
          container.read(preferenciasProvider).modoTema,
          value,
          reason: key,
        );
      }
      for (final MapEntry(:key, :value) in idiomasValidos.entries) {
        final (container, _) = await _conGuardado({_idioma: key});
        expect(container.read(preferenciasProvider).idioma, value, reason: key);
      }

      // Inválidos: idioma que ya no existe, vacío, mayúsculas, región, nombres
      // de Flutter y tipos distintos.
      const idiomasInvalidos = <Object>[
        'fr',
        'pt',
        '',
        'EN',
        'en_US',
        'en-US',
        7,
        true,
        1.5,
        <String>['en'],
      ];
      const temasInvalidos = <Object>[
        'sepia',
        '',
        'OSCURO',
        'dark',
        'system',
        1,
        false,
        2.5,
        <String>['oscuro'],
      ];

      for (final invalido in idiomasInvalidos) {
        final guardado = <String, Object>{_idioma: invalido, _tema: 'oscuro'};
        final (container, preferencias) = await _conGuardado(guardado);
        expect(
          container.read(preferenciasProvider),
          const Preferencias(modoTema: ThemeMode.dark, idioma: Locale('es')),
          reason: '$invalido',
        );
        // La lectura no reescribe lo guardado.
        await preferencias.reload();
        expect(preferencias.get(_idioma), invalido);
        expect(preferencias.get(_tema), 'oscuro');
      }

      for (final invalido in temasInvalidos) {
        final guardado = <String, Object>{_tema: invalido, _idioma: 'en'};
        final (container, preferencias) = await _conGuardado(guardado);
        expect(
          container.read(preferenciasProvider),
          const Preferencias(modoTema: ThemeMode.system, idioma: Locale('en')),
          reason: '$invalido',
        );
        await preferencias.reload();
        expect(preferencias.get(_tema), invalido);
        expect(preferencias.get(_idioma), 'en');
      }

      // Los dos inválidos a la vez: valores iniciales.
      final (container, _) = await _conGuardado({_tema: 3, _idioma: 'fr'});
      expect(container.read(preferenciasProvider), Preferencias.inicial);
    },
  );

  test(
    'TC-HU-052-08 si falla guardar el cambio se aplica igual en pantalla',
    () async {
      final fallos = <String, Future<bool> Function()>{
        'lanza al llamar': () => throw PlatformException(code: 'sin-disco'),
        'falla el futuro': () => Future.error(StateError('sin disco')),
        'devuelve false': () async => false,
      };

      for (final MapEntry(key: fallo, value: setString) in fallos.entries) {
        final container = ProviderContainer(
          overrides: [
            almacenPreferenciasProvider.overrideWithValue(
              AlmacenPreferenciasShared(_PreferenciasQueFallan(setString)),
            ),
          ],
        );
        addTearDown(container.dispose);

        final registros = await _registrosDe(() async {
          container.read(preferenciasProvider.notifier)
            ..cambiarTema(ThemeMode.dark)
            ..cambiarIdioma(const Locale('en'));
          // Deja terminar el guardado: un error no atrapado haría fallar la
          // prueba.
          await pumpEventQueue();
        });

        expect(
          container.read(preferenciasProvider),
          const Preferencias(modoTema: ThemeMode.dark, idioma: Locale('en')),
          reason: fallo,
        );
        expect(registros, isEmpty, reason: fallo);
      }
    },
  );

  test(
    'TC-HU-052-08 el almacén en memoria conserva lo elegido en la sesión',
    () async {
      final almacen = AlmacenPreferenciasEnMemoria();
      expect(almacen.leerTema(), isNull);
      expect(almacen.leerIdioma(), isNull);

      await almacen.guardarTema(ThemeMode.light);
      await almacen.guardarIdioma(const Locale('en'));

      expect(almacen.leerTema(), ThemeMode.light);
      expect(almacen.leerIdioma(), const Locale('en'));
    },
  );
}
