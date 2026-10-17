import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/core/sesion/es_tecnico_provider.dart';
import 'package:app/core/widgets/pantalla_titulada.dart';

/// Pestaña Mi cuenta. Vacía en TT-MOB-01, salvo el interruptor de prueba.
class CuentaScreen extends ConsumerWidget {
  const CuentaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PantallaTitulada(
      titulo: 'Mi cuenta',
      // El interruptor solo existe fuera de release (interruptorDePruebaProvider).
      // Se retira cuando la sesión real dé el rol.
      cuerpo: !ref.watch(interruptorDePruebaProvider)
          ? null
          : ListView(
              children: [
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
