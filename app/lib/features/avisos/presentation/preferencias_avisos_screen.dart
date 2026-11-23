import 'package:app/core/widgets/estados.dart';
import 'package:app/features/avisos/presentation/preferencias_avisos_controller.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _nombres = {
  'seguridad': 'Seguridad',
  'visita': 'Visitas',
  'mensaje': 'Mensajes',
  'promocion': 'Promociones',
};

/// Preferencias de avisos (KNOCK-105). Los interruptores cambian al instante
/// y quedan «pendientes de guardar» hasta que `PUT /me/preferencias-avisos`
/// responde bien; si falla, la pantalla lo dice sin simular que se guardó.
class PreferenciasAvisosScreen extends ConsumerWidget {
  const PreferenciasAvisosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(preferenciasAvisosControllerProvider);
    final pendientes = ref.watch(pendientesPreferenciasProvider);
    final controlador = ref.read(preferenciasAvisosControllerProvider.notifier);

    final Widget cuerpo;
    if (estado.isLoading && !estado.hasValue) {
      cuerpo = const CargandoCentrado(etiqueta: 'Cargando preferencias');
    } else if (estado.hasError && !estado.hasValue) {
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
          if (pendientes.hayPendientes)
            _BannerPendiente(pendientes: pendientes)
          else
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Elige qué avisos quieres recibir.'),
            ),
          for (final p in estado.requireValue)
            SwitchListTile(
              key: ValueKey(p.tipo),
              title: Text(_nombres[p.tipo] ?? p.tipo),
              subtitle: p.apagable
                  ? null
                  : const Text('Los avisos de seguridad no se pueden apagar'),
              value: p.activo,
              onChanged: p.apagable && !pendientes.guardando
                  ? (valor) => controlador.cambiar(p.tipo, activo: valor)
                  : null,
            ),
          if (pendientes.hayPendientes)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                spacing: 12,
                children: [
                  OutlinedButton(
                    onPressed: pendientes.guardando
                        ? null
                        : controlador.descartar,
                    child: const Text('Descartar cambios'),
                  ),
                  FilledButton(
                    onPressed: pendientes.guardando
                        ? null
                        : () => _guardar(context, controlador),
                    child: Text(
                      pendientes.guardando ? 'Guardando...' : 'Guardar cambios',
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Preferencias de avisos')),
      body: cuerpo,
    );
  }

  Future<void> _guardar(
    BuildContext context,
    PreferenciasAvisosController controlador,
  ) async {
    final mensajero = ScaffoldMessenger.of(context);
    final bien = await controlador.guardar();
    if (bien) {
      mensajero.showSnackBar(
        const SnackBar(content: Text('Preferencias guardadas')),
      );
    }
  }
}

class _BannerPendiente extends StatelessWidget {
  const _BannerPendiente({required this.pendientes});

  final PendientesPreferencias pendientes;

  @override
  Widget build(BuildContext context) {
    final error = pendientes.errorAlGuardar;
    final texto = error == null
        ? 'Tienes cambios pendientes de guardar.'
        : '${mensajeDeError(error, porDefecto: 'No pudimos guardar tus cambios.')} '
              'Tus cambios siguen pendientes y se pierden si cierras la app.';
    return ListTile(
      leading: const Icon(Icons.pending_outlined),
      title: Text(texto),
    );
  }
}
