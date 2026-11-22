import 'package:app/core/router/rutas.dart';
import 'package:app/core/widgets/estados.dart';
import 'package:app/features/dispositivos/presentation/registro_push_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Notificaciones push del dispositivo (KNOCK-60): activar, estado y el aviso
/// «no disponibles por ahora» cuando el servidor responde 503.
class NotificacionesScreen extends ConsumerWidget {
  const NotificacionesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registro = ref.watch(registroPushControllerProvider);
    final controlador = ref.read(registroPushControllerProvider.notifier);

    final Widget cuerpo = switch (registro.estado) {
      EstadoPush.registrando => const CargandoCentrado(
        etiqueta: 'Activando notificaciones',
      ),
      EstadoPush.noDisponible => const MensajeCentrado(
        texto: 'Las notificaciones no están disponibles por ahora.',
      ),
      EstadoPush.registrado => const MensajeCentrado(
        texto: 'Las notificaciones están activas en este dispositivo.',
      ),
      EstadoPush.sinPermiso => MensajeCentrado(
        texto:
            'No pudimos obtener el permiso de notificaciones de este '
            'dispositivo.',
        etiquetaAccion: 'Intentar de nuevo',
        alPulsar: controlador.registrar,
      ),
      EstadoPush.error => MensajeCentrado(
        texto: 'No pudimos activar las notificaciones.',
        etiquetaAccion: 'Intentar de nuevo',
        alPulsar: controlador.registrar,
      ),
      EstadoPush.sinRegistrar => MensajeCentrado(
        texto: 'Activa las notificaciones para enterarte de tus visitas.',
        etiquetaAccion: 'Activar notificaciones',
        alPulsar: controlador.registrar,
      ),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: Column(
        children: [
          Expanded(child: cuerpo),
          ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('Preferencias de avisos'),
            onTap: () => context.go(Rutas.preferenciasAvisos),
          ),
        ],
      ),
    );
  }
}
