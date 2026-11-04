import 'package:app/core/errores/failure.dart';
import 'package:app/features/oficios/domain/modalidad.dart';
import 'package:app/features/oficios/domain/oficio.dart';

/// Convierte el JSON del contrato de `GET /api/v1/oficios` (TT-PRU-01) en
/// entidades. Es el único punto que conoce la forma del contrato: cuando llegue
/// el cliente generado, solo cambia de dónde sale el JSON.
abstract final class OficioMapper {
  /// Una respuesta `200`: un arreglo de `{ clave, nombre, modalidad }`.
  ///
  /// Lanza [DatosInvalidosFailure] si no es un arreglo o si algún elemento no
  /// cumple el contrato. Conserva el orden recibido.
  static List<Oficio> listaDesdeContrato(Object? json) {
    if (json is! List<Object?>) {
      throw const DatosInvalidosFailure();
    }
    return [for (final elemento in json) desdeContrato(elemento)];
  }

  /// Un elemento del arreglo del contrato.
  static Oficio desdeContrato(Object? json) {
    if (json is! Map<Object?, Object?>) {
      throw const DatosInvalidosFailure();
    }
    return Oficio(
      clave: _textoNoVacio(json['clave']),
      nombre: _textoNoVacio(json['nombre']),
      modalidad: Modalidad.desdeTexto(_textoNoVacio(json['modalidad'])),
    );
  }

  static String _textoNoVacio(Object? valor) {
    if (valor is! String || valor.trim().isEmpty) {
      throw const DatosInvalidosFailure();
    }
    return valor;
  }
}
