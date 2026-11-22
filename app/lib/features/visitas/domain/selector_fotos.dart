import 'package:app/core/errores/failure.dart';

/// Elige y sube las fotos del trabajo (1 a 5, privadas del técnico) y devuelve
/// lo que espera `POST /visitas/{id}/terminar` en `fotos`. La subida real usa
/// `POST /imagenes/subidas` y necesita el selector de imágenes del sistema,
/// que aún no está en la app: ver `visitas_providers.dart`.
abstract interface class SelectorFotos {
  /// Pide hasta `maximo` fotos. Cancelar devuelve una lista vacía.
  Future<List<String>> elegir({required int maximo});
}

/// Mientras no exista la subida de imágenes: dice que no está disponible.
class SelectorFotosNoDisponible implements SelectorFotos {
  const SelectorFotosNoDisponible();

  @override
  Future<List<String>> elegir({required int maximo}) =>
      Future.error(const RutaNoDisponibleFailure());
}
