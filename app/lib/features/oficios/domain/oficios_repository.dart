import 'package:app/features/oficios/domain/oficio.dart';

/// Fuente de los oficios. La implementación puede cambiar (datos de prueba,
/// API simulada o cliente generado) sin tocar la pantalla.
///
/// Devuelve los oficios en el orden del contrato (por nombre) y falla con un
/// `Failure` de `core/errores`.
abstract interface class OficiosRepository {
  Future<List<Oficio>> listar();
}
