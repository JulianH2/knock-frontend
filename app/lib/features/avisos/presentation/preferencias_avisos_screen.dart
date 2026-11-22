import 'package:app/core/widgets/estados.dart';
import 'package:app/features/avisos/avisos_providers.dart';
import 'package:app/features/avisos/domain/preferencias_avisos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Preferencias de avisos. Los cambios viven solo en pantalla: guardar (`PUT`,
/// spec 037) todavía no tiene ruta, y la pantalla lo dice.
class PreferenciasAvisosController
    extends AsyncNotifier<List<PreferenciaAviso>> {
  @override
  Future<List<PreferenciaAviso>> build() =>
      ref.watch(preferenciasAvisosRepositoryProvider).obtener();

  void reintentar() => ref.invalidateSelf();

  /// Cambia un interruptor en pantalla. La seguridad no se apaga.
  void cambiar(String tipo, {required bool activo}) {
    final actual = state.value;
    if (actual == null) {
      return;
    }
    state = AsyncData([
      for (final p in actual)
        if (p.tipo == tipo) p.conActivo(activo: activo) else p,
    ]);
  }
}

final preferenciasAvisosControllerProvider =
    AsyncNotifierProvider<PreferenciasAvisosController, List<PreferenciaAviso>>(
      PreferenciasAvisosController.new,
      retry: (_, _) => null,
    );

const _nombres = {
  'seguridad': 'Seguridad',
  'visita': 'Visitas',
  'mensaje': 'Mensajes',
  'promocion': 'Promociones',
};

class PreferenciasAvisosScreen extends ConsumerWidget {
  const PreferenciasAvisosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(preferenciasAvisosControllerProvider);
    final controlador = ref.read(preferenciasAvisosControllerProvider.notifier);

    final Widget cuerpo;
    if (estado.isLoading) {
      cuerpo = const CargandoCentrado(etiqueta: 'Cargando preferencias');
    } else if (estado.hasError) {
      cuerpo = MensajeCentrado(
        texto: mensajeDeError(
          estado.error!,
          porDefecto: 'No pudimos cargar tus preferencias',
        ),
        etiquetaAccion: 'Reintentar',
        alPulsar: controlador.reintentar,
      );
    } else if (estado.requireValue.isEmpty) {
      cuerpo = const MensajeCentrado(texto: 'No hay preferencias que mostrar');
    } else {
      cuerpo = ListView(
        children: [
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text(
              'Guardar tus cambios estará disponible pronto. Por ahora los '
              'cambios no se conservan al salir.',
            ),
          ),
          for (final p in estado.requireValue)
            SwitchListTile(
              key: ValueKey(p.tipo),
              title: Text(_nombres[p.tipo] ?? p.tipo),
              subtitle: p.apagable
                  ? null
                  : const Text('Los avisos de seguridad no se pueden apagar'),
              value: p.activo,
              onChanged: p.apagable
                  ? (valor) => controlador.cambiar(p.tipo, activo: valor)
                  : null,
            ),
        ],
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Preferencias de avisos')),
      body: cuerpo,
    );
  }
}
