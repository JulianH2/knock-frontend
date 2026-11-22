import 'package:app/core/datos/formato_fecha.dart';
import 'package:app/features/visitas/domain/visita.dart';
import 'package:app/features/visitas/visitas_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EstadoAgenda {
  const EstadoAgenda({
    required this.items,
    this.nextCursor,
    this.cargandoMas = false,
    this.huboErrorAlCargarMas = false,
  });

  final List<AgendaItem> items;
  final String? nextCursor;
  final bool cargandoMas;
  final bool huboErrorAlCargarMas;
}

/// Agenda con cursor (`GET /agenda`). Sin rango se usa el de la API: desde hoy
/// y 14 días.
class AgendaController extends AsyncNotifier<EstadoAgenda> {
  @override
  Future<EstadoAgenda> build() async {
    final pagina = await ref.watch(visitasRepositoryProvider).agenda();
    return EstadoAgenda(items: pagina.items, nextCursor: pagina.nextCursor);
  }

  void reintentar() => ref.invalidateSelf();

  Future<void> cargarMas() async {
    final actual = state.value;
    final cursor = actual?.nextCursor;
    if (actual == null || cursor == null || actual.cargandoMas) {
      return;
    }
    state = AsyncData(
      EstadoAgenda(items: actual.items, nextCursor: cursor, cargandoMas: true),
    );
    try {
      final pagina = await ref
          .read(visitasRepositoryProvider)
          .agenda(cursor: cursor);
      state = AsyncData(
        EstadoAgenda(
          items: [...actual.items, ...pagina.items],
          nextCursor: pagina.nextCursor,
        ),
      );
    } on Object {
      state = AsyncData(
        EstadoAgenda(
          items: actual.items,
          nextCursor: cursor,
          huboErrorAlCargarMas: true,
        ),
      );
    }
  }
}

final agendaControllerProvider =
    AsyncNotifierProvider<AgendaController, EstadoAgenda>(
      AgendaController.new,
      retry: (_, _) => null,
    );

/// Resultado de una acción sobre la visita: un `mensaje` de éxito o el `error`.
typedef ResultadoAccion = ({String? mensaje, Object? error});

/// Detalle de una visita y sus acciones. Tras una acción que cambia la visita
/// se vuelve a pedir el detalle y la agenda.
class VisitaController extends AsyncNotifier<Visita> {
  VisitaController(this.visitaId);

  final String visitaId;

  @override
  Future<Visita> build() =>
      ref.watch(visitasRepositoryProvider).obtener(visitaId);

  void reintentar() => ref.invalidateSelf();

  Future<ResultadoAccion> _accion(Future<String> Function() hacer) async {
    try {
      final mensaje = await hacer();
      ref
        ..invalidateSelf()
        ..invalidate(agendaControllerProvider);
      return (mensaje: mensaje, error: null);
    } on Object catch (e) {
      return (mensaje: null, error: e);
    }
  }

  Future<ResultadoAccion> reprogramar(DateTime fechaHora) => _accion(() async {
    final propuesta = await ref
        .read(visitasRepositoryProvider)
        .reprogramar(visitaId, fechaHora: fechaHora.toUtc());
    return 'Propusiste el ${fechaHoraCorta(propuesta.fechaHora)}. '
        'Falta que la otra persona responda.';
  });

  Future<ResultadoAccion> responder({required bool acepta}) =>
      _accion(() async {
        final r = await ref
            .read(visitasRepositoryProvider)
            .responderReprogramacion(visitaId, acepta: acepta);
        return r.aceptada
            ? 'Aceptaste el nuevo horario.'
            : 'Rechazaste el nuevo horario.';
      });

  Future<ResultadoAccion> cancelar(String motivo) => _accion(() async {
    final limpio = validarMotivoCancelacion(motivo);
    final r = await ref
        .read(visitasRepositoryProvider)
        .cancelar(visitaId, motivo: limpio);
    return r.tardia ? 'Visita cancelada fuera de plazo.' : 'Visita cancelada.';
  });

  Future<ResultadoAccion> noSePresento() => _accion(() async {
    final r = await ref.read(visitasRepositoryProvider).noSePresento(visitaId);
    return r.quienFalto == 'cliente'
        ? 'Registramos que el cliente no se presentó.'
        : 'Registramos que el técnico no se presentó.';
  });
}

final visitaControllerProvider =
    AsyncNotifierProvider.family<VisitaController, Visita, String>(
      VisitaController.new,
      retry: (_, _) => null,
    );
