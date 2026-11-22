/// Rutas de las pestañas de la barra inferior (TT-MOB-01, spec §8 decisión 9).
abstract final class Rutas {
  static const inicio = '/inicio';
  static const explorar = '/explorar';
  static const actividad = '/actividad';
  static const trabajo = '/trabajo';
  static const cuenta = '/cuenta';

  /// Subruta de Explorar (TT-PRU-02): la pantalla cuelga de la rama Explorar y
  /// conserva la barra inferior.
  static const oficios = '/explorar/oficios';

  /// Subrutas de Actividad (KNOCK-105): bandeja de avisos.
  static const avisos = '/actividad/avisos';

  /// Subruta de Actividad (KNOCK-72): lista de conversaciones; el detalle
  /// cuelga de `chats/:id`.
  static const chats = '/actividad/chats';

  /// Subruta de Mi cuenta (KNOCK-105): preferencias de avisos.
  static const preferenciasAvisos = '/cuenta/preferencias-avisos';

  /// Subruta de Mi cuenta (KNOCK-60): notificaciones push del dispositivo.
  static const notificaciones = '/cuenta/notificaciones';
}

/// Devuelve a dónde redirigir, o `null` si la ubicación está permitida.
///
/// Sin el rol de técnico, `/trabajo` (y sus subrutas) lleva a Inicio.
String? redireccionPorRol({
  required bool esTecnico,
  required String ubicacion,
}) {
  final esRutaTrabajo =
      ubicacion == Rutas.trabajo || ubicacion.startsWith('${Rutas.trabajo}/');
  return !esTecnico && esRutaTrabajo ? Rutas.inicio : null;
}
