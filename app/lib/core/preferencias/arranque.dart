import 'package:app/core/preferencias/almacen_preferencias.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Obtiene el almacén de preferencias antes del primer cuadro (HU-052).
///
/// Si el almacenamiento falla, la app abre con el almacén en memoria: no hay
/// nada que la persona pueda hacer, así que no se muestra ni se registra el
/// error (spec §8 decisión 5).
Future<AlmacenPreferencias> crearAlmacenDeArranque({
  Future<SharedPreferences> Function() obtener = SharedPreferences.getInstance,
}) async {
  try {
    return AlmacenPreferenciasShared(await obtener());
  } on Object {
    return AlmacenPreferenciasEnMemoria();
  }
}
