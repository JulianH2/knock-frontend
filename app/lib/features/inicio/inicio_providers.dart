import 'package:app/features/inicio/data/ubicacion_geolocator_repository.dart';
import 'package:app/features/inicio/domain/ubicacion_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Repositorio de ubicación de la app (raíz de composición: es lo único que
/// junta `data/` con el resto, para que `presentation/` no importe `data/`).
/// Las pruebas lo reemplazan por uno falso.
final ubicacionRepositoryProvider = Provider<UbicacionRepository>(
  (ref) => UbicacionGeolocatorRepository(),
);
