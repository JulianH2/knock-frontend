import 'package:app/features/oficios/domain/modalidad.dart';

/// Un oficio del catálogo (contrato de `GET /api/v1/oficios`, TT-PRU-01).
final class Oficio {
  const Oficio({
    required this.clave,
    required this.nombre,
    required this.modalidad,
  });

  /// Clave corta y estable, p. ej. `ele`.
  final String clave;

  /// Nombre para mostrar, en español.
  final String nombre;

  final Modalidad modalidad;

  @override
  bool operator ==(Object other) =>
      other is Oficio &&
      other.clave == clave &&
      other.nombre == nombre &&
      other.modalidad == modalidad;

  @override
  int get hashCode => Object.hash(clave, nombre, modalidad);
}
