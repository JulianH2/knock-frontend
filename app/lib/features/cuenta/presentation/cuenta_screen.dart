import 'package:app/core/router/rutas.dart';
import 'package:app/core/sesion/es_tecnico_provider.dart';
import 'package:app/core/widgets/pantalla_titulada.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Pestaña Mi cuenta: accesos a las preferencias de avisos y, fuera de
/// release, el interruptor de prueba del rol.
class CuentaScreen extends ConsumerWidget {
  const CuentaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PantallaTitulada(
      titulo: 'Mi cuenta',
      cuerpo: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notificaciones'),
            onTap: () => context.go(Rutas.notificaciones),
          ),
          ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('Preferencias de avisos'),
            onTap: () => context.go(Rutas.preferenciasAvisos),
          ),
          // El interruptor solo existe fuera de release (interruptorDePruebaProvider).
          // Se retira cuando la sesión real dé el rol.
          if (ref.watch(interruptorDePruebaProvider))
            SwitchListTile(
              title: const Text('Modo técnico (prueba)'),
              value: ref.watch(esTecnicoProvider),
              onChanged: (valor) => ref
                  .read(esTecnicoProvider.notifier)
                  .cambiar(esTecnico: valor),
            ),
        ],
      ),
    );
  }
}
