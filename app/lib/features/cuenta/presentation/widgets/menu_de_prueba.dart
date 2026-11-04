import 'package:app/core/sesion/es_tecnico_provider.dart';
import 'package:app/l10n/generado/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Control de prueba de Mi cuenta: el interruptor «Modo técnico (prueba)».
///
/// Solo se muestra fuera de release (`interruptorDePruebaProvider`) y lo
/// reemplaza el rol de la sesión real (TT-MOB-01). Tema e idioma están en
/// Configuración (HU-052).
class MenuDePrueba extends ConsumerWidget {
  const MenuDePrueba({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => SwitchListTile(
    title: Text(AppLocalizations.of(context).pruebaModoTecnico),
    value: ref.watch(esTecnicoProvider),
    onChanged: (valor) =>
        ref.read(esTecnicoProvider.notifier).cambiar(esTecnico: valor),
  );
}
