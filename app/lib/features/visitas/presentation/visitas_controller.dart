import 'package:app/core/datos/formato_fecha.dart';
import 'package:app/core/errores/failure.dart';
import 'package:app/features/visitas/domain/visita.dart';
import 'package:app/features/visitas/domain/visita_acciones.dart';
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
    final rango = ref.watch(rangoAgendaProvider);
    final pagina = await ref
        .watch(visitasRepositoryProvider)
        .agenda(desde: rango?.start, hasta: rango?.end);
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
      final rango = ref.read(rangoAgendaProvider);
      final pagina = await ref
          .read(visitasRepositoryProvider)
          .agenda(cursor: cursor, desde: rango?.start, hasta: rango?.end);
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

  bool _ocupado = false;

  /// Ejecuta una acción a la vez: un segundo toque mientras la primera sigue
  /// en curso no hace nada (`mensaje` y `error` nulos).
  Future<ResultadoAccion> _accion(Future<String> Function() hacer) async {
    if (_ocupado) {
      return (mensaje: null, error: null);
    }
    _ocupado = true;
    try {
      final mensaje = await hacer();
      ref
        ..invalidateSelf()
        ..invalidate(agendaControllerProvider);
      return (mensaje: mensaje, error: null);
    } on Object catch (e) {
      return (mensaje: null, error: e);
    } finally {
      _ocupado = false;
    }
  }

  Future<ResultadoAccion> reprogramar(DateTime fechaHora) => _accion(() async {
    if (errorFechaReprogramacion(fechaHora, ref.read(relojVisitasProvider)()) !=
        null) {
      throw const DatosInvalidosFailure();
    }
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

  Future<ResultadoAccion> llegada(String codigo) => _accion(() async {
    if (errorCodigoLlegada(codigo) != null) {
      throw const DatosInvalidosFailure();
    }
    await ref
        .read(visitasRepositoryProvider)
        .llegada(visitaId, codigo: codigo.trim());
    return 'Registramos tu llegada. La visita está en curso.';
  });

  /// El texto del aviso no cambia la visita, así que no la vuelve a pedir.
  Future<({AvisoConfianza? aviso, Object? error})> pedirAviso() async {
    try {
      final aviso = await ref
          .read(visitasRepositoryProvider)
          .avisoConfianza(visitaId);
      return (aviso: aviso, error: null);
    } on Object catch (e) {
      return (aviso: null, error: e);
    }
  }

  Future<ResultadoAccion> terminar({
    required String descripcion,
    required String recomendacion,
    required List<String> fotos,
  }) => _accion(() async {
    if (errorDescripcionTrabajo(descripcion) != null ||
        errorRecomendacion(recomendacion) != null ||
        errorFotos(fotos.length) != null) {
      throw const DatosInvalidosFailure();
    }
    await ref
        .read(visitasRepositoryProvider)
        .terminar(
          visitaId,
          descripcion: descripcion.trim(),
          recomendacion: recomendacion.trim(),
          fotos: fotos,
        );
    return 'Visita terminada. Gracias por tu trabajo.';
  });

  Future<ResultadoAccion> noTerminado(String texto) => _accion(() async {
    if (errorTextoNoTerminado(texto) != null) {
      throw const DatosInvalidosFailure();
    }
    await ref
        .read(visitasRepositoryProvider)
        .noTerminado(visitaId, texto: texto.trim());
    return 'Recibimos tu reporte. Lo vamos a revisar.';
  });

  Future<ResultadoAccion> enviarCotizacionFinal({
    required String precio,
    required String descripcion,
  }) => _accion(() async {
    if (errorPrecio(precio) != null ||
        errorDescripcionTrabajo(descripcion) != null) {
      throw const DatosInvalidosFailure();
    }
    final c = await ref
        .read(visitasRepositoryProvider)
        .enviarCotizacionFinal(
          visitaId,
          precio: int.parse(precio.trim()),
          descripcion: descripcion.trim(),
        );
    return 'Enviaste la cotización final de \$${c.precio}. '
        'Vence el ${fechaHoraCorta(c.venceEn)}.';
  });

  Future<ResultadoAccion> decidirCotizacion({required bool aprueba}) =>
      _accion(() async {
        final d = await ref
            .read(visitasRepositoryProvider)
            .decidirCotizacionFinal(visitaId, aprueba: aprueba);
        if (aprueba) {
          return 'Aprobaste la cotización final.';
        }
        return d.resultado == 'solo_visita'
            ? 'Rechazaste la cotización final: solo se paga la visita.'
            : 'Rechazaste la cotización final.';
      });

  Future<ResultadoAccion> permisoFotos({required bool permiso}) =>
      _accion(() async {
        final r = await ref
            .read(visitasRepositoryProvider)
            .permisoFotos(visitaId, permiso: permiso);
        return r.permiso
            ? 'Autorizaste publicar las fotos del trabajo.'
            : 'No se publicarán las fotos del trabajo.';
      });
}

final visitaControllerProvider =
    AsyncNotifierProvider.family<VisitaController, Visita, String>(
      VisitaController.new,
      retry: (_, _) => null,
    );
