import 'package:app/features/visitas/data/visitas_repository_de_prueba.dart';
import 'package:app/features/visitas/domain/selector_fotos.dart';
import 'package:app/features/visitas/domain/visita.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Raíz de composición de visitas y agenda (KNOCK-119/122). Datos de prueba
/// hasta que exista el cliente HTTP; muchas rutas aún no están en el gateway
/// (404), por eso todo pasa por `VisitasRepository`. Es el único punto que
/// cambia al conectar la API.
final visitasRepositoryProvider = Provider<VisitasRepository>(
  (ref) => VisitasRepositoryDePrueba(),
);

/// Selector y subida de fotos del trabajo. Sin selector de imágenes en la app
/// ni paquete aprobado, hoy dice que no está disponible.
final selectorFotosProvider = Provider<SelectorFotos>(
  (ref) => const SelectorFotosNoDisponible(),
);

/// Reloj de la pantalla de visitas (se reemplaza en las pruebas).
final relojVisitasProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

/// Rango elegido para la agenda; `null` usa el de la API (hoy y 14 días).
class RangoAgendaNotifier extends Notifier<DateTimeRange?> {
  @override
  DateTimeRange? build() => null;

  void cambiar(DateTimeRange? rango) => state = rango;
}

final rangoAgendaProvider =
    NotifierProvider<RangoAgendaNotifier, DateTimeRange?>(
      RangoAgendaNotifier.new,
    );
