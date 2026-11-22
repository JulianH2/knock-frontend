import 'package:app/core/errores/failure.dart';

/// Lectura estricta de JSON del contrato: lo que no cuadra es
/// `DatosInvalidosFailure`, nunca una excepción de tipos.
abstract final class LecturaJson {
  static final _digitos = RegExp(r'^-?(0|[1-9][0-9]*)$');

  static Map<String, Object?> objeto(Object? valor) {
    if (valor is Map<String, Object?>) {
      return valor;
    }
    throw const DatosInvalidosFailure();
  }

  static Map<String, Object?>? objetoONulo(Object? valor) =>
      valor == null ? null : objeto(valor);

  static List<Object?> lista(Object? valor) {
    if (valor is List<Object?>) {
      return valor;
    }
    throw const DatosInvalidosFailure();
  }

  /// Página con cursor: la lista `items` convertida con `item` y el cursor
  /// siguiente (`claveCursor`, nulo al final).
  static (List<T>, String?) pagina<T>(
    Object? json,
    T Function(Object?) item,
    String claveCursor,
  ) {
    final mapa = objeto(json);
    return (
      [for (final i in lista(mapa['items'])) item(i)],
      textoONulo(mapa[claveCursor]),
    );
  }

  /// Texto obligatorio y no vacío.
  static String texto(Object? valor) {
    if (valor is String && valor.isNotEmpty) {
      return valor;
    }
    throw const DatosInvalidosFailure();
  }

  static String? textoONulo(Object? valor) {
    if (valor == null) {
      return null;
    }
    if (valor is String) {
      return valor;
    }
    throw const DatosInvalidosFailure();
  }

  static bool booleano(Object? valor) {
    if (valor is bool) {
      return valor;
    }
    throw const DatosInvalidosFailure();
  }

  static bool? booleanoONulo(Object? valor) =>
      valor == null ? null : booleano(valor);

  /// Entero que el contrato puede mandar como número o como cadena de dígitos.
  static int entero(Object? valor) {
    if (valor is int) {
      return valor;
    }
    if (valor is String && _digitos.hasMatch(valor)) {
      final convertido = int.tryParse(valor);
      if (convertido != null) {
        return convertido;
      }
    }
    throw const DatosInvalidosFailure();
  }

  static int? enteroONulo(Object? valor) =>
      valor == null ? null : entero(valor);

  static DateTime fecha(Object? valor) {
    if (valor is String) {
      final convertida = DateTime.tryParse(valor);
      if (convertida != null) {
        return convertida;
      }
    }
    throw const DatosInvalidosFailure();
  }
}
