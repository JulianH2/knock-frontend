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
