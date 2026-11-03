/// Cuerpos ficticios de la API simulada, como texto JSON literal (spec §8
/// D4), con la forma de la §4 de cada spec del backend (fuentes y commits en
/// `app/test/contrato/contrato_s4.json`). Ningún dato es real.
library;

/// Tipos de contenido de la §4.
abstract final class TiposDeContenido {
  static const json = 'application/json';
  static const problema = 'application/problem+json';
}

abstract final class RespuestasSimuladas {
  /// `GET /api/v1/oficios` `200`: el ejemplo de la §4 de TT-PRU-01.
  static const oficios = '''
[
  { "clave": "ele", "nombre": "Electricidad", "modalidad": "domicilio" },
  { "clave": "mec", "nombre": "Mecánica", "modalidad": "taller" },
  { "clave": "plo", "nombre": "Plomería", "modalidad": "domicilio" }
]''';

  /// `GET /api/v1/oficios` `200` sin oficios activos.
  static const oficiosVacio = '[]';

  /// `GET /api/v1/colonias/en-punto` `200` dentro de la cobertura. Colonia
  /// inventada.
  static const coloniaEnCobertura = '''
{
  "enCobertura": true,
  "colonia": {
    "id": "000000000000000000000001",
    "nombre": "Colonia Simulada Centro",
    "cp": "00000",
    "municipio": "Municipio de Prueba"
  }
}''';

  /// `GET /api/v1/colonias/en-punto` `200` fuera de la cobertura.
  static const coloniaFueraDeCobertura =
      '{ "enCobertura": false, "colonia": null }';

  static const noAutorizado =
      '{ "type": "about:blank", "title": "No autorizado", "status": 401 }';

  static const noEncontrado =
      '{ "type": "about:blank", "title": "No encontrado", "status": 404 }';

  static const demasiadasSolicitudes =
      '{ "type": "about:blank", "title": "Demasiadas solicitudes", '
      '"status": 429 }';

  /// `500` genérico: sin `detail`, traza ni excepción.
  static const errorInterno =
      '{ "type": "about:blank", "title": "Error interno", "status": 500 }';

  /// `422` de colonia por punto con los parámetros rechazados. El mensaje es
  /// fijo: nunca repite las coordenadas recibidas.
  static String coordenadasInvalidas({required bool lat, required bool lon}) {
    const mensaje = '["Valor no válido."]';
    final errores = [
      if (lat) '"lat": $mensaje',
      if (lon) '"lon": $mensaje',
    ].join(', ');
    return '{ "type": "about:blank", "title": "Datos no válidos", '
        '"status": 422, "errors": { $errores } }';
  }
}
