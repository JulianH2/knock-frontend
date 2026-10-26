import 'package:app/features/oficios/data/oficios_repository_de_prueba.dart';
import 'package:app/features/oficios/domain/oficios_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Repositorio de oficios de la feature (raíz de composición: es lo único que
/// junta `data/` con el resto, para que `presentation/` no importe `data/`).
///
/// Hoy son datos de prueba del contrato de TT-PRU-01. Cuando llegue el
/// cliente generado o la API simulada (TT-MOB-03, TT-MOB-08), se cambia
/// solo esta línea.
final oficiosRepositoryProvider = Provider<OficiosRepository>(
  (ref) => const OficiosRepositoryDePrueba(),
);
