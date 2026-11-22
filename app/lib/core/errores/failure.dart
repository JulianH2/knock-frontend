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
///
/// `codigo` conserva el `code` del ProblemDetails cuando la API lo manda (por
/// ejemplo `moderation_unavailable`); sin él, es un 503 genérico.
final class ServicioNoDisponibleFailure extends Failure {
  const ServicioNoDisponibleFailure({this.codigo});

  final String? codigo;
}

/// La ruta no existe todavía en el gateway o en el servicio (404 de ruta, no
/// de recurso). No es un error de la app: la pantalla dice que la función aún
/// no está disponible.
final class RutaNoDisponibleFailure extends Failure {
  const RutaNoDisponibleFailure();
}

/// El recurso pedido no existe o no es de la persona (404 de recurso).
final class NoEncontradoFailure extends Failure {
  const NoEncontradoFailure();
}

/// Demasiadas peticiones (429).
final class LimiteDePeticionesFailure extends Failure {
  const LimiteDePeticionesFailure({this.codigo});

  final String? codigo;
}

/// Regla de negocio rechazada por la API (409 o 422) con su `code` de dominio,
/// por ejemplo `content_rejected` o `conversation_closed`.
final class ReglaDeNegocioFailure extends Failure {
  const ReglaDeNegocioFailure(this.codigo);

  final String codigo;
}
