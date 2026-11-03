import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:app/features/inicio/domain/punto_mapa.dart';

/// Identificador del único administrador de agrupación del mapa de Inicio.
const idAgrupacionDePines = ClusterManagerId('pines');

/// Agrupación nativa de `google_maps_flutter` (desde 2.9.0): los pines
/// cercanos se juntan en un marcador con el número de pines al alejar el zoom
/// y se separan al acercarlo.
const agrupacionDePines = ClusterManager(clusterManagerId: idAgrupacionDePines);

/// Construye un marcador por punto, todos asignados a [agrupacionDePines].
///
/// Es una función pura para probarla sin montar `GoogleMap` (vista nativa).
Set<Marker> construirMarcadores(Iterable<PuntoMapa> puntos) => {
  for (final punto in puntos)
    Marker(
      markerId: MarkerId(punto.id),
      position: LatLng(punto.latitud, punto.longitud),
      clusterManagerId: idAgrupacionDePines,
    ),
};
