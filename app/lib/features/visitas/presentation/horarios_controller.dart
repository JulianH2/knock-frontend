import 'package:app/core/errores/failure.dart';
import 'package:app/features/visitas/domain/visita_acciones.dart';
import 'package:app/features/visitas/presentation/visitas_controller.dart';
import 'package:app/features/visitas/visitas_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Horarios de los siete días del técnico (`GET`/`PUT /tecnicos/me/horarios`).
class HorariosController extends AsyncNotifier<List<HorarioDia>> {
  bool _guardando = false;

  @override
  Future<List<HorarioDia>> build() =>
      ref.watch(visitasRepositoryProvider).horarios();

  void reintentar() => ref.invalidateSelf();

  /// Valida los siete días y los guarda; un segundo toque mientras guarda no
  /// hace nada.
  Future<ResultadoAccion> guardar(List<HorarioDia> horarios) async {
    if (_guardando) {
      return (mensaje: null, error: null);
    }
    _guardando = true;
    try {
      if (errorHorarios(horarios) != null) {
        throw const DatosInvalidosFailure();
      }
      final guardados = await ref
          .read(visitasRepositoryProvider)
          .guardarHorarios(horarios);
      state = AsyncData(guardados);
      return (mensaje: 'Guardamos tus horarios.', error: null);
    } on Object catch (e) {
      return (mensaje: null, error: e);
    } finally {
      _guardando = false;
    }
  }
}

final horariosControllerProvider =
    AsyncNotifierProvider<HorariosController, List<HorarioDia>>(
      HorariosController.new,
      retry: (_, _) => null,
    );
