/// Contrato mínimo de red de la app (TT-MOB-08).
///
/// Los repositorios de `data/` piden con [PeticionApi] y reciben una
/// [RespuestaApi]; quién responde lo decide `clienteApiProvider`: hoy la API
/// simulada en memoria y, con TT-MOB-03, el cliente generado del contrato.
/// Aquí no se escribe ninguna llamada HTTP (principio 4, spec §8 D2).
library;

/// Una petición a la API. La ruta es la de la §4 de cada spec
/// (`/api/v1/…`); el origen lo pone la configuración.
final class PeticionApi {
  const PeticionApi({
    required this.metodo,
    required this.ruta,
    this.consulta = const [],
    this.encabezados = const {},
    this.cuerpo,
  });

  /// `GET`, `POST`…, en mayúsculas.
  final String metodo;

  final String ruta;

  /// Pares nombre-valor en el orden recibido; una lista y no un mapa para
  /// poder detectar parámetros repetidos.
  final List<(String, String)> consulta;

  final Map<String, String> encabezados;

  /// Cuerpo como texto JSON, o `null` si no lleva.
  final String? cuerpo;

  /// Valores de un parámetro de la consulta, en orden.
  List<String> valoresDe(String nombre) => [
    for (final (clave, valor) in consulta)
      if (clave == nombre) valor,
  ];

  /// Un encabezado sin distinguir mayúsculas, o `null` si no viene.
  String? encabezado(String nombre) => _buscar(encabezados, nombre);

  /// No incluye ruta, consulta, encabezados ni cuerpo (pueden llevar
  /// coordenadas o tokens).
  @override
  String toString() => 'PeticionApi';
}

/// Respuesta de la API: estado, encabezados y cuerpo como texto, para que el
/// repositorio la decodifique igual que una respuesta real.
final class RespuestaApi {
  const RespuestaApi({
    required this.estado,
    this.encabezados = const {},
    this.cuerpo = '',
  });

  final int estado;

  final Map<String, String> encabezados;

  final String cuerpo;

  /// Un encabezado sin distinguir mayúsculas, o `null` si no viene.
  String? encabezado(String nombre) => _buscar(encabezados, nombre);

  /// Tipo de contenido sin parámetros (`application/json`), en minúsculas.
  String? get tipoDeContenido =>
      encabezado('content-type')?.split(';').first.trim().toLowerCase();

  /// Solo el estado: el cuerpo puede traer datos de la persona.
  @override
  String toString() => 'RespuestaApi($estado)';
}

/// Quien responde las peticiones (simulación o cliente real).
abstract interface class ClienteApi {
  /// Lanza [ErrorDeRedApi] si no hubo respuesta (sin conexión o tiempo
  /// agotado). Un estado `4xx` o `5xx` llega como [RespuestaApi], no como
  /// excepción.
  Future<RespuestaApi> enviar(PeticionApi peticion);
}

/// No hubo respuesta (sin conexión o tiempo agotado). No guarda URL,
/// consulta ni cuerpo.
final class ErrorDeRedApi implements Exception {
  const ErrorDeRedApi();

  @override
  String toString() => 'ErrorDeRedApi';
}

/// Por qué la configuración de la API no es válida.
enum MotivoDeErrorDeConfiguracion {
  /// `KNOCK_API_URL` no es un origen permitido (§2, caso 01).
  urlNoPermitida,

  /// Compilación release sin `KNOCK_API_URL`.
  releaseSinUrl,

  /// `KNOCK_API_ESCENARIO` desconocido o usado en modo real.
  escenarioNoPermitido,

  /// Modo real sin el cliente real de TT-MOB-03.
  clienteRealNoDisponible,
}

/// La configuración de la API no permite arrancar. Nunca se cae en silencio a
/// la simulación y el mensaje no repite el valor recibido.
final class ErrorDeConfiguracionApi implements Exception {
  const ErrorDeConfiguracionApi(this.motivo);

  final MotivoDeErrorDeConfiguracion motivo;

  @override
  String toString() => 'ErrorDeConfiguracionApi(${motivo.name})';
}

String? _buscar(Map<String, String> encabezados, String nombre) {
  final buscado = nombre.toLowerCase();
  for (final MapEntry(:key, :value) in encabezados.entries) {
    if (key.toLowerCase() == buscado) {
      return value;
    }
  }
  return null;
}
