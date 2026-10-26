import 'package:app/features/oficios/data/oficio_mapper.dart';
import 'package:app/features/oficios/domain/oficio.dart';
import 'package:app/features/oficios/domain/oficios_repository.dart';

/// Respuesta de ejemplo del contrato de TT-PRU-01 (`GET /api/v1/oficios`):
/// oficios ficticios, ordenados por nombre. No hay datos reales ni red.
const List<Object?> contratoOficiosDePrueba = [
  {'clave': 'ele', 'nombre': 'Electricidad', 'modalidad': 'domicilio'},
  {'clave': 'mec', 'nombre': 'Mecánica', 'modalidad': 'taller'},
  {'clave': 'plo', 'nombre': 'Plomería', 'modalidad': 'domicilio'},
];

/// Datos de prueba mientras no exista el contrato vendorizado ni el cliente
/// generado (TT-MOB-03) ni la API simulada (TT-MOB-08).
///
/// Para sustituirlo basta registrar otra implementación de
/// [OficiosRepository] en `oficiosRepositoryProvider`: la pantalla y el
/// controlador no cambian. Pasa siempre por [OficioMapper], igual que lo
/// hará la respuesta real.
class OficiosRepositoryDePrueba implements OficiosRepository {
  const OficiosRepositoryDePrueba();

  @override
  Future<List<Oficio>> listar() async =>
      OficioMapper.listaDesdeContrato(contratoOficiosDePrueba);
}
