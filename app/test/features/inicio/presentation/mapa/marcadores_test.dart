import 'package:app/features/inicio/domain/punto_mapa.dart';
import 'package:app/features/inicio/presentation/mapa/marcadores.dart';
import 'package:app/features/inicio/presentation/spike/pines_de_prueba.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  test('TC-TT-MOB-04-03 cada pin se asigna al administrador de agrupación', () {
    final puntos = pinesDePrueba();

    final marcadores = construirMarcadores(puntos);

    expect(marcadores, hasLength(50));
    expect(
      marcadores.map((m) => m.markerId.value).toSet(),
      puntos.map((p) => p.id).toSet(),
    );
    for (final marcador in marcadores) {
      expect(
        marcador.clusterManagerId,
        agrupacionDePines.clusterManagerId,
        reason: marcador.markerId.value,
      );
    }
  });

  test('TC-TT-MOB-04-03 el marcador conserva la posición del punto', () {
    const punto = PuntoMapa(id: 'prueba-01', latitud: 20.06, longitud: -99.33);

    final marcador = construirMarcadores([punto]).single;

    expect(marcador.markerId, const MarkerId('prueba-01'));
    expect(marcador.position, const LatLng(20.06, -99.33));
    expect(marcador.clusterManagerId, const ClusterManagerId('pines'));
  });
}
