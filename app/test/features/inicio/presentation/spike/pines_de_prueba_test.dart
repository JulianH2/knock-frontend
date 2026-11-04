import 'package:app/features/inicio/presentation/spike/pines_de_prueba.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TC-TT-MOB-04-06 genera 50 pines ficticios, deterministas y dentro de la ciudad piloto', () {
    final pines = pinesDePrueba();

    expect(pines, hasLength(50));

    final ids = pines.map((p) => p.id).toList();
    expect(ids.toSet(), hasLength(50), reason: 'identificadores únicos');
    expect(ids.first, 'prueba-01');
    expect(ids.last, 'prueba-50');
    for (final id in ids) {
      expect(id, matches(RegExp(r'^prueba-\d{2}$')));
    }

    // Área acotada del piloto (validador de knock-backend, TT-BD-02).
    for (final p in pines) {
      expect(p.longitud, inInclusiveRange(-99.40, -99.28), reason: p.id);
      expect(p.latitud, inInclusiveRange(20.00, 20.12), reason: p.id);
    }

    // No son el mismo punto repetido: se reparten alrededor del centro.
    final posiciones = pines.map((p) => (p.latitud, p.longitud)).toSet();
    expect(posiciones, hasLength(50));
    expect(
      pines.where((p) => p.latitud > centroTulaDeAllende.latitud),
      isNotEmpty,
    );
    expect(
      pines.where((p) => p.latitud < centroTulaDeAllende.latitud),
      isNotEmpty,
    );

    // Determinista: otra llamada da exactamente la misma lista.
    expect(pinesDePrueba(), orderedEquals(pines));
  });

  test('TC-TT-MOB-04-06 respeta la cantidad pedida', () {
    expect(pinesDePrueba(cantidad: 3).map((p) => p.id), [
      'prueba-01',
      'prueba-02',
      'prueba-03',
    ]);
  });
}
