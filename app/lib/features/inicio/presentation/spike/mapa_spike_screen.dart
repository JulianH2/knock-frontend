import 'package:flutter/material.dart';

import 'package:app/features/inicio/domain/punto_mapa.dart';
import 'package:app/features/inicio/presentation/mapa/boton_mi_ubicacion.dart';
import 'package:app/features/inicio/presentation/mapa/mapa_con_pines.dart';
import 'package:app/features/inicio/presentation/mapa/mi_ubicacion_controller.dart';
import 'package:app/features/inicio/presentation/spike/pines_de_prueba.dart';

// DESECHABLE (TT-MOB-04): se borra cuando HU-011 tenga datos reales. Solo se
// abre con `flutter run -t lib/main_spike_mapa.dart`; ni `main.dart` ni el
// router la importan.

/// Pantalla de prueba del spike: mapa a pantalla completa con 50 pines
/// ficticios agrupados y el botón «Mi ubicación».
class MapaSpikeScreen extends StatefulWidget {
  const MapaSpikeScreen({super.key});

  /// Texto que deja claro que los pines no son reales.
  static const avisoDatosDePrueba = 'Datos de prueba';

  @override
  State<MapaSpikeScreen> createState() => _MapaSpikeScreenState();
}

class _MapaSpikeScreenState extends State<MapaSpikeScreen> {
  final List<PuntoMapa> _pines = pinesDePrueba();
  CamaraMapa? _camara;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: MapaConPines(
              puntos: _pines,
              centro: centroTulaDeAllende,
              alCrearCamara: (camara) => setState(() => _camara = camara),
            ),
          ),
          const SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Text(
                      MapaSpikeScreen.avisoDatosDePrueba,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: BotonMiUbicacion(camara: _camara),
    );
  }
}
