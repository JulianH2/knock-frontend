import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app/features/inicio/presentation/spike/mapa_spike_screen.dart';

// DESECHABLE (TT-MOB-04): punto de entrada propio del spike de Google Maps.
// Se corre con `flutter run -t lib/main_spike_mapa.dart`. `lib/main.dart` no
// lo importa, así que no llega a la compilación de tienda. Se borra junto con
// `features/inicio/presentation/spike/` cuando HU-011 tenga datos reales.

void main() {
  runApp(const ProviderScope(child: SpikeMapaApp()));
}

/// App mínima que solo muestra la pantalla de prueba del mapa.
class SpikeMapaApp extends StatelessWidget {
  const SpikeMapaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Knock · spike mapa',
      home: MapaSpikeScreen(),
    );
  }
}
