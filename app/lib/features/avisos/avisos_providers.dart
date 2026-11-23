import 'package:app/features/avisos/data/avisos_repository_de_prueba.dart';
import 'package:app/features/avisos/domain/avisos_repository.dart';
import 'package:app/features/avisos/domain/preferencias_avisos.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Raíz de composición de avisos (KNOCK-105). Hoy son datos de prueba; cuando
/// exista el cliente HTTP contra el gateway, se cambia solo esta línea.
final avisosRepositoryProvider = Provider<AvisosRepository>(
  (ref) => AvisosRepositoryDePrueba(),
);

final preferenciasAvisosRepositoryProvider =
    Provider<PreferenciasAvisosRepository>(
      (ref) => PreferenciasAvisosRepositoryDePrueba(),
    );
