import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:app/features/inicio/domain/punto_mapa.dart';
import 'package:app/features/inicio/presentation/mapa/marcadores.dart';
import 'package:app/features/inicio/presentation/mapa/mi_ubicacion_controller.dart';

/// Mapa de Google con los pines agrupados.
///
/// Sin capa de «mi ubicación» ni botón nativo: el permiso solo lo pide
/// `BotonMiUbicacion` al tocarlo. Cuando el mapa está listo entrega su cámara
/// en [alCrearCamara].
class MapaConPines extends StatefulWidget {
  const MapaConPines({
    required this.puntos,
    required this.centro,
    required this.alCrearCamara,
    this.zoom = 13,
    super.key,
  });

  final List<PuntoMapa> puntos;
  final PuntoMapa centro;
  final double zoom;
  final ValueChanged<CamaraMapa> alCrearCamara;

  @override
  State<MapaConPines> createState() => _MapaConPinesState();
}

class _MapaConPinesState extends State<MapaConPines> {
  static final _agrupaciones = <ClusterManager>{agrupacionDePines};

  late Set<Marker> _marcadores = construirMarcadores(widget.puntos);

  @override
  void didUpdateWidget(MapaConPines anterior) {
    super.didUpdateWidget(anterior);
    if (!identical(anterior.puntos, widget.puntos)) {
      _marcadores = construirMarcadores(widget.puntos);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(widget.centro.latitud, widget.centro.longitud),
        zoom: widget.zoom,
      ),
      markers: _marcadores,
      clusterManagers: _agrupaciones,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      onMapCreated: (controlador) =>
          widget.alCrearCamara(_CamaraGoogleMap(controlador)),
    );
  }
}

/// Adaptador del controlador de `google_maps_flutter` al puerto [CamaraMapa].
class _CamaraGoogleMap implements CamaraMapa {
  _CamaraGoogleMap(this._controlador);

  final GoogleMapController _controlador;

  /// Zoom de calle al centrar en la posición de la persona.
  static const _zoomMiUbicacion = 15.0;

  @override
  Future<void> moverA({required double latitud, required double longitud}) =>
      _controlador.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(latitud, longitud), _zoomMiUbicacion),
      );
}
