import 'package:app/core/router/app_shell.dart';
import 'package:app/core/router/rutas.dart';
import 'package:app/core/sesion/es_tecnico_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TC-TT-MOB-01-02 reglas de rol (unitarias)', () {
    test('TC-TT-MOB-01-02 sin rol de técnico /trabajo redirige a /inicio', () {
      expect(
        redireccionPorRol(esTecnico: false, ubicacion: Rutas.trabajo),
        Rutas.inicio,
      );
      expect(
        redireccionPorRol(esTecnico: false, ubicacion: '/trabajo/agenda'),
        Rutas.inicio,
      );
    });

    test('TC-TT-MOB-01-02 sin rol de técnico las demás rutas no redirigen', () {
      for (final ruta in [
        Rutas.inicio,
        Rutas.explorar,
        Rutas.actividad,
        Rutas.cuenta,
        '/trabajos',
      ]) {
        expect(
          redireccionPorRol(esTecnico: false, ubicacion: ruta),
          isNull,
          reason: ruta,
        );
      }
    });

    test('TC-TT-MOB-01-02 con rol de técnico /trabajo no redirige', () {
      expect(
        redireccionPorRol(esTecnico: true, ubicacion: Rutas.trabajo),
        isNull,
      );
    });

    test('TC-TT-MOB-01-02 ramas visibles según el rol', () {
      expect(ramasVisibles(esTecnico: false), [0, 1, 2, 4]);
      expect(ramasVisibles(esTecnico: true), [0, 1, 2, 3, 4]);
    });

    test('TC-TT-MOB-01-02 el indicador inicia en falso y se puede cambiar', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(esTecnicoProvider), isFalse);
      container.read(esTecnicoProvider.notifier).cambiar(esTecnico: true);
      expect(container.read(esTecnicoProvider), isTrue);
    });
  });
}
