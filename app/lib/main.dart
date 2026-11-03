import 'package:app/app.dart';
import 'package:app/core/preferencias/almacen_preferencias.dart';
import 'package:app/core/preferencias/arranque.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Espera las preferencias guardadas detrás de la pantalla de arranque nativa
/// para que el primer cuadro ya tenga el idioma y el tema (HU-052, CA5).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final almacen = await crearAlmacenDeArranque();
  runApp(
    ProviderScope(
      overrides: [almacenPreferenciasProvider.overrideWithValue(almacen)],
      child: const KnockApp(),
    ),
  );
}
