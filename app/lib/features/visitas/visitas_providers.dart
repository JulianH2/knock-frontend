import 'package:app/features/visitas/data/visitas_repository_de_prueba.dart';
import 'package:app/features/visitas/domain/visita.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Raíz de composición de visitas y agenda (KNOCK-119/122). Datos de prueba
/// hasta que exista el cliente HTTP; muchas rutas aún no están en el gateway
/// (404), por eso todo pasa por `VisitasRepository`.
final visitasRepositoryProvider = Provider<VisitasRepository>(
  (ref) => VisitasRepositoryDePrueba(),
);
