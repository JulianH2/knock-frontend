import 'dart:math' as math;

import 'package:app/features/inicio/domain/punto_mapa.dart';

// DESECHABLE (TT-MOB-04): se borra cuando HU-011 tenga datos reales.

/// Centro aproximado de Tula de Allende, Hidalgo (ciudad piloto).
const centroTulaDeAllende = PuntoMapa(
  id: 'centro',
  latitud: 20.05,
  longitud: -99.34,
);

/// Radio máximo, en km, alrededor de [centroTulaDeAllende].
const radioPinesKm = 3.8;

/// Kilómetros por grado de latitud (aproximación esférica).
const _kmPorGrado = 111.32;

/// Ángulo áureo en radianes: reparte los puntos sin huecos ni aleatoriedad.
final _anguloAureo = math.pi * (3 - math.sqrt(5));

/// Genera [cantidad] pines ficticios en espiral de Fermat alrededor de Tula.
///
/// Determinista por construcción (no usa `Random` ni red): dos llamadas
/// devuelven la misma lista. Identificadores `prueba-01`, `prueba-02`…, sin
/// nombres ni datos reales.
List<PuntoMapa> pinesDePrueba({int cantidad = 50}) {
  final cosLatitud = math.cos(centroTulaDeAllende.latitud * math.pi / 180);
  return List<PuntoMapa>.generate(cantidad, (i) {
    final radioKm = radioPinesKm * math.sqrt((i + 0.5) / cantidad);
    final angulo = i * _anguloAureo;
    return PuntoMapa(
      id: 'prueba-${(i + 1).toString().padLeft(2, '0')}',
      latitud:
          centroTulaDeAllende.latitud +
          radioKm * math.sin(angulo) / _kmPorGrado,
      longitud:
          centroTulaDeAllende.longitud +
          radioKm * math.cos(angulo) / (_kmPorGrado * cosLatitud),
    );
  }, growable: false);
}
