import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app/core/router/rutas.dart';
import 'package:app/core/sesion/es_tecnico_provider.dart';
import 'package:app/core/widgets/pantalla_titulada.dart';
import 'package:app/features/cuenta/presentation/widgets/menu_de_prueba.dart';
import 'package:app/l10n/generado/app_localizations.dart';

/// Pestaña Mi cuenta: la entrada a Configuración (HU-052) y, solo fuera de
/// release, el interruptor de prueba del modo técnico.
class CuentaScreen extends ConsumerWidget {
  const CuentaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    return PantallaTitulada(
      titulo: textos.tabCuenta,
      cuerpo: ListView(
        children: [
          ListTile(
            leading: const ExcludeSemantics(
              child: Icon(Icons.settings_outlined),
            ),
            title: Text(textos.configuracionTitulo),
            trailing: const ExcludeSemantics(child: Icon(Icons.chevron_right)),
            onTap: () => context.go(Rutas.configuracion),
          ),
          // Se retira cuando la sesión real dé el rol (TT-MOB-01).
          if (ref.watch(interruptorDePruebaProvider)) const MenuDePrueba(),
        ],
      ),
    );
  }
}
