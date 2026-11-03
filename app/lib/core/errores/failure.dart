/// Error tipado de la app (constitución: los errores de la API y de los datos
/// llegan a la interfaz como `Failure`, nunca como excepciones crudas).
///
/// No lleva mensajes técnicos, URLs ni datos: la pantalla decide el texto que
/// ve la persona. TT-MOB-03 lo amplía con los ProblemDetails de la API.
sealed class Failure implements Exception {
  const Failure();

  @override
  String toString() => runtimeType.toString();
}

/// Los datos recibidos no cumplen el contrato (campo ausente, vacío o de otro
/// tipo).
final class DatosInvalidosFailure extends Failure {
  const DatosInvalidosFailure();
}

/// No se pudo obtener la información (sin conexión o servicio no disponible).
final class ServicioNoDisponibleFailure extends Failure {
  const ServicioNoDisponibleFailure();
}

/// La API rechazó la petición con un estado `4xx` (TT-MOB-08, spec §8 D7).
/// TT-MOB-03 lo amplía con el ProblemDetails y el catálogo de mensajes.
final class SolicitudRechazadaFailure extends Failure {
  const SolicitudRechazadaFailure(this.estado);

  /// Estado HTTP recibido (`400` a `499`).
  final int estado;

  @override
  bool operator ==(Object other) =>
      other is SolicitudRechazadaFailure && other.estado == estado;

  @override
  int get hashCode => estado.hashCode;
}
