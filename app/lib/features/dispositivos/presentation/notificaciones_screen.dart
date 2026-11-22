import 'package:app/core/router/rutas.dart';
import 'package:app/core/widgets/estados.dart';
import 'package:app/features/dispositivos/domain/permiso_notificaciones.dart';
import 'package:app/features/dispositivos/presentation/registro_push_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Notificaciones push del dispositivo (KNOCK-60): explicación previa, permiso
/// (denegado, bloqueado → Ajustes), registro, y la pantalla de estado del
/// dispositivo con los casos 503, 409, 429 y token inválido.
class NotificacionesScreen extends ConsumerStatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  ConsumerState<NotificacionesScreen> createState() =>
      _NotificacionesScreenState();
}

class _NotificacionesScreenState extends ConsumerState<NotificacionesScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(
      () =>
          ref.read(registroPushControllerProvider.notifier).refrescarPermiso(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Al volver de Ajustes se vuelve a leer el permiso.
  @override
  void didChangeAppLifecycleState(AppLifecycleState estado) {
    if (estado == AppLifecycleState.resumed) {
      ref.read(registroPushControllerProvider.notifier).refrescarPermiso();
    }
  }

  @override
  Widget build(BuildContext context) {
    final registro = ref.watch(registroPushControllerProvider);
    final controlador = ref.read(registroPushControllerProvider.notifier);

    final Widget cuerpo = switch (registro.estado) {
      EstadoPush.registrando => const CargandoCentrado(
        etiqueta: 'Activando notificaciones',
      ),
      EstadoPush.explicacionPrevia => _Estado(
        icono: Icons.notifications_active_outlined,
        texto:
            'Te avisaremos cuando un técnico confirme una visita o te '
            'escriba. Para eso necesitamos tu permiso para enviarte '
            'notificaciones.',
        acciones: [
          FilledButton(
            onPressed: controlador.aceptarExplicacion,
            child: const Text('Continuar'),
          ),
          TextButton(
            onPressed: controlador.rechazarExplicacion,
            child: const Text('Ahora no'),
          ),
        ],
      ),
      EstadoPush.noDisponible => _Estado(
        icono: Icons.notifications_off_outlined,
        texto: 'Las notificaciones no están disponibles por ahora.',
        acciones: [
          TextButton(
            onPressed: controlador.reintentarManual,
            child: const Text('Volver a comprobar'),
          ),
        ],
      ),
      EstadoPush.registrado => _Estado(
        icono: Icons.notifications_active,
        texto: 'Las notificaciones están activas en este dispositivo.',
        acciones: [
          TextButton(
            onPressed: controlador.darDeBaja,
            child: const Text('Dejar de recibir en este dispositivo'),
          ),
        ],
      ),
      EstadoPush.permisoDenegado => _Estado(
        icono: Icons.block,
        texto:
            'No diste permiso para las notificaciones. Sin él no podremos '
            'avisarte de tus visitas.',
        acciones: [
          FilledButton(
            onPressed: controlador.aceptarExplicacion,
            child: const Text('Pedir permiso de nuevo'),
          ),
        ],
      ),
      EstadoPush.permisoBloqueado => _Estado(
        icono: Icons.block,
        texto:
            'Las notificaciones están bloqueadas para Knock. Actívalas en los '
            'Ajustes del dispositivo.',
        acciones: [
          FilledButton(
            onPressed: controlador.abrirAjustes,
            child: const Text('Abrir ajustes'),
          ),
        ],
      ),
      EstadoPush.sinToken => _Estado(
        icono: Icons.error_outline,
        texto: 'No pudimos obtener el identificador de este dispositivo.',
        acciones: [
          FilledButton(
            onPressed: controlador.reintentarManual,
            child: const Text('Intentar de nuevo'),
          ),
        ],
      ),
      EstadoPush.tokenInvalido => _Estado(
        icono: Icons.error_outline,
        texto:
            'El identificador de este dispositivo no es válido. Podemos '
            'pedir uno nuevo.',
        acciones: [
          FilledButton(
            onPressed: controlador.reintentarManual,
            child: const Text('Obtener uno nuevo'),
          ),
        ],
      ),
      EstadoPush.conflicto => _Estado(
        icono: Icons.sync_problem,
        texto:
            'No pudimos registrar este dispositivo porque ya está en uso. '
            'Intenta de nuevo en un momento.',
        acciones: [
          FilledButton(
            onPressed: controlador.reintentarManual,
            child: const Text('Intentar de nuevo'),
          ),
        ],
      ),
      EstadoPush.limite => _Estado(
        icono: Icons.hourglass_top,
        texto:
            'Hiciste muchas peticiones. Espera un momento e intenta de '
            'nuevo.',
        acciones: [
          FilledButton(
            onPressed: controlador.reintentarManual,
            child: const Text('Intentar de nuevo'),
          ),
        ],
      ),
      EstadoPush.error => _Estado(
        icono: Icons.error_outline,
        texto: 'No pudimos activar las notificaciones.',
        acciones: [
          FilledButton(
            onPressed: controlador.reintentarManual,
            child: const Text('Intentar de nuevo'),
          ),
        ],
      ),
      EstadoPush.sinRegistrar => _Estado(
        icono: Icons.notifications_none,
        texto: 'Activa las notificaciones para enterarte de tus visitas.',
        acciones: [
          FilledButton(
            onPressed: controlador.registrar,
            child: const Text('Activar notificaciones'),
          ),
        ],
      ),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: Column(
        children: [
          Expanded(child: cuerpo),
          ListTile(
            leading: const Icon(Icons.phone_android),
            title: const Text('Permiso del sistema'),
            subtitle: Text(_textoPermiso(registro.permiso)),
          ),
          ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('Preferencias de avisos'),
            onTap: () {
              final enrutador = GoRouter.maybeOf(context);
              enrutador?.go(Rutas.preferenciasAvisos);
            },
          ),
        ],
      ),
    );
  }
}

String _textoPermiso(EstadoPermiso? permiso) => switch (permiso) {
  null => 'Sin comprobar',
  EstadoPermiso.noPreguntado => 'Aún no se ha pedido',
  EstadoPermiso.concedido => 'Concedido',
  EstadoPermiso.denegado => 'Denegado',
  EstadoPermiso.denegadoPermanente => 'Bloqueado en Ajustes',
};

class _Estado extends StatelessWidget {
  const _Estado({
    required this.icono,
    required this.texto,
    required this.acciones,
  });

  final IconData icono;
  final String texto;
  final List<Widget> acciones;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          Icon(icono, size: 48),
          Text(texto, textAlign: TextAlign.center),
          ...acciones,
        ],
      ),
    ),
  );
}
