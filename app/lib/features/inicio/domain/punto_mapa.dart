/// Un punto que se pinta como pin en el mapa de Inicio.
///
/// En el spike TT-MOB-04 lo llena el generador de pines de prueba; en HU-011,
/// la API. Solo lleva un identificador y la posición: nada de nombres ni datos
/// personales.
class PuntoMapa {
  const PuntoMapa({
    required this.id,
    required this.latitud,
    required this.longitud,
  });

  final String id;
  final double latitud;
  final double longitud;

  @override
  bool operator ==(Object other) =>
      other is PuntoMapa &&
      other.id == id &&
      other.latitud == latitud &&
      other.longitud == longitud;

  @override
  int get hashCode => Object.hash(id, latitud, longitud);

  @override
  String toString() => 'PuntoMapa($id)';
}
