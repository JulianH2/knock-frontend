import 'package:app/features/avisos/avisos_providers.dart';
import 'package:app/features/avisos/domain/preferencias_avisos.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Cambios hechos en pantalla que todavía no se guardan en el servidor.
///
/// Es la cola lista para el `PUT` (spec 037): hoy la ruta no existe, así que
/// los cambios solo viven en memoria mientras la app está abierta y la
/// pantalla lo dice. Nunca se muestra como guardado lo que no se guardó.
class PendientesPreferencias {
  const PendientesPreferencias({
    this.cambios = const {},
    this.guardando = false,
    this.errorAlGuardar,
  });

  /// `tipo` -> valor deseado, solo si difiere de lo guardado.
  final Map<String, bool> cambios;
  final bool guardando;
  final Object? errorAlGuardar;

  bool get hayPendientes => cambios.isNotEmpty;
}

class PendientesPreferenciasNotifier extends Notifier<PendientesPreferencias> {
  @override
  PendientesPreferencias build() => const PendientesPreferencias();

  void poner(PendientesPreferencias nuevo) => state = nuevo;
}

final pendientesPreferenciasProvider =
    NotifierProvider<PendientesPreferenciasNotifier, PendientesPreferencias>(
      PendientesPreferenciasNotifier.new,
    );

class PreferenciasAvisosController
    extends AsyncNotifier<List<PreferenciaAviso>> {
  List<PreferenciaAviso> _guardadas = const [];

  @override
  Future<List<PreferenciaAviso>> build() async {
    final lista = await ref
        .watch(preferenciasAvisosRepositoryProvider)
        .obtener();
    _guardadas = lista;
    final cambios = ref.read(pendientesPreferenciasProvider).cambios;
    return [
      for (final p in lista)
        cambios.containsKey(p.tipo) ? p.conActivo(activo: cambios[p.tipo]!) : p,
    ];
  }

  void reintentar() => ref.invalidateSelf();

  /// Cambia un interruptor. La seguridad no se apaga. El cambio queda
  /// pendiente de guardar.
  void cambiar(String tipo, {required bool activo}) {
    final actual = state.value;
    final preferencia = actual?.where((p) => p.tipo == tipo).firstOrNull;
    if (actual == null || preferencia == null || !preferencia.apagable) {
      return;
    }
    state = AsyncData([
      for (final p in actual)
        if (p.tipo == tipo) p.conActivo(activo: activo) else p,
    ]);
    final guardada = _guardadas.firstWhere((p) => p.tipo == tipo).activo;
    final pendientes = ref.read(pendientesPreferenciasProvider);
    final cambios = {...pendientes.cambios};
    if (guardada == activo) {
      cambios.remove(tipo);
    } else {
      cambios[tipo] = activo;
    }
    ref
        .read(pendientesPreferenciasProvider.notifier)
        .poner(PendientesPreferencias(cambios: cambios));
  }

  /// Descarta los cambios pendientes y vuelve a lo guardado.
  void descartar() {
    ref
        .read(pendientesPreferenciasProvider.notifier)
        .poner(const PendientesPreferencias());
    state = AsyncData(_guardadas);
  }

  /// Intenta guardar los pendientes. Devuelve `true` solo si el servidor los
  /// guardó; si no, siguen pendientes y se conserva el error.
  Future<bool> guardar() async {
    final actual = state.value;
    final pendientes = ref.read(pendientesPreferenciasProvider);
    if (actual == null || !pendientes.hayPendientes || pendientes.guardando) {
      return false;
    }
    final notificador = ref.read(pendientesPreferenciasProvider.notifier)
      ..poner(
        PendientesPreferencias(cambios: pendientes.cambios, guardando: true),
      );
    try {
      await ref.read(preferenciasAvisosRepositoryProvider).guardar(actual);
    } on Object catch (error) {
      notificador.poner(
        PendientesPreferencias(
          cambios: pendientes.cambios,
          errorAlGuardar: error,
        ),
      );
      return false;
    }
    _guardadas = actual;
    notificador.poner(const PendientesPreferencias());
    return true;
  }
}

final preferenciasAvisosControllerProvider =
    AsyncNotifierProvider<PreferenciasAvisosController, List<PreferenciaAviso>>(
      PreferenciasAvisosController.new,
      retry: (_, _) => null,
    );
