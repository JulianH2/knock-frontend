import 'package:app/features/oficios/domain/oficio.dart';
import 'package:app/features/oficios/oficios_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado de la pantalla de oficios: cargando, datos (lista, posiblemente
/// vacía) o error.
class OficiosController extends AsyncNotifier<List<Oficio>> {
  @override
  Future<List<Oficio>> build() => ref.watch(oficiosRepositoryProvider).listar();

  /// Vuelve a pedir los oficios (botón Reintentar): el estado pasa por
  /// «cargando» y termina en datos o en error.
  void reintentar() => ref.invalidateSelf();
}

/// Sin reintento automático: Riverpod reintenta solo los proveedores que
/// fallan y eso escondería el error; aquí la persona decide con Reintentar.
final oficiosControllerProvider =
    AsyncNotifierProvider<OficiosController, List<Oficio>>(
      OficiosController.new,
      retry: (_, _) => null,
    );
