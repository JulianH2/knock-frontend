/// Estado del permiso de notificaciones del sistema.
enum EstadoPermiso {
  /// Aún no se le ha pedido a la persona.
  noPreguntado,
  concedido,

  /// Dijo que no, pero el sistema todavía deja volver a preguntar.
  denegado,

  /// Dijo que no y el sistema ya no pregunta: solo desde Ajustes.
  denegadoPermanente,
}

/// Permiso de notificaciones del dispositivo. La implementación real llega con
/// el paquete de push (sin agregar paquetes por ahora); el flujo ya depende
/// solo de esta interfaz.
abstract interface class PermisoNotificaciones {
  Future<EstadoPermiso> estado();

  /// Muestra el diálogo del sistema y devuelve el resultado.
  Future<EstadoPermiso> solicitar();

  /// Abre los Ajustes de la app. Devuelve `false` si no se pudo abrir.
  Future<bool> abrirAjustes();
}
