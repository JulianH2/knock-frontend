import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/core/sesion/es_tecnico_provider.dart';
import 'package:app/core/widgets/pantalla_titulada.dart';
import 'package:app/features/cuenta/presentation/widgets/menu_de_prueba.dart';
import 'package:app/l10n/generado/app_localizations.dart';

/// Pestaña Mi cuenta. Vacía, salvo el menú de prueba (rol, tema e idioma).
class CuentaScreen extends ConsumerWidget {
  const CuentaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PantallaTitulada(
      titulo: AppLocalizations.of(context).tabCuenta,
      // El menú solo existe fuera de release (interruptorDePruebaProvider).
      // Se retira cuando la sesión real dé el rol y HU-052 traiga Configuración.
      cuerpo: ref.watch(interruptorDePruebaProvider)
          ? const MenuDePrueba()
          : null,
    );
  }
}
