import 'package:flutter/material.dart';

import 'package:app/core/widgets/pantalla_titulada.dart';
import 'package:app/l10n/generado/app_localizations.dart';

/// Pestaña Trabajo. Vacía en TT-MOB-01; su historia agrega el contenido.
class TrabajoScreen extends StatelessWidget {
  const TrabajoScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      PantallaTitulada(titulo: AppLocalizations.of(context).tabTrabajo);
}
