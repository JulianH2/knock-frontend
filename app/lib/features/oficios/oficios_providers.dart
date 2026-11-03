import 'package:app/core/red/cliente_api_provider.dart';
import 'package:app/features/oficios/data/oficios_repository_api.dart';
import 'package:app/features/oficios/domain/oficios_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Repositorio de oficios de la feature (raíz de composición: es lo único que
/// junta `data/` con el resto, para que `presentation/` no importe `data/`).
///
/// Los oficios llegan de la API por `clienteApiProvider` (TT-MOB-08): la
/// simulada sin `KNOCK_API_URL` y la real cuando TT-MOB-03 la conecte.
/// `OficiosRepositoryDePrueba` se conserva para la prueba TC-TT-PRU-02-07.
final oficiosRepositoryProvider = Provider<OficiosRepository>(
  (ref) => OficiosRepositoryApi(ref.watch(clienteApiProvider)),
);
