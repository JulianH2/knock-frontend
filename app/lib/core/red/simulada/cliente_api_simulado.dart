import 'package:app/core/red/cliente_api.dart';
import 'package:app/core/red/configuracion_api.dart';
import 'package:app/core/red/simulada/respuestas_simuladas.dart';

/// API simulada en memoria (spec §8 D1) con la forma de la §4 de
/// `GET /api/v1/oficios` y `GET /api/v1/colonias/en-punto`, con sus errores
/// por [escenario]. `POST /api/v1/auth/firebase` (§4 de HU-001) se agrega
/// cuando el líder revise el cambio de la spec (§8 D13); hasta entonces
/// responde `404` como cualquier ruta no simulada.
///
/// No hace llamadas de red, no registra nada y no guarda lo que recibe. Solo
/// la crea `clienteApiProvider`, y nunca en una compilación release.
class ClienteApiSimulado implements ClienteApi {
  ClienteApiSimulado({
    this.escenario = EscenarioApi.normal,
    this.demora = demoraLenta,
  });

  /// Demora del escenario [EscenarioApi.lento] (para ver el estado de carga).
  static const demoraLenta = Duration(seconds: 2);

  static const rutaOficios = '/api/v1/oficios';
  static const rutaColonia = '/api/v1/colonias/en-punto';

  /// Formato de `lat` y `lon` de la §4 de TT-API-07.
  static final _coordenada = RegExp(r'^-?\d{1,3}(\.\d{1,10})?$');
  static const _maximoCoordenada = 16;

  /// Segundos del `Retry-After` del escenario [EscenarioApi.limite].
  static const segundosDeEspera = '60';

  /// Escenario de las próximas peticiones. En la app es uno por ejecución
  /// (`KNOCK_API_ESCENARIO`); las pruebas lo cambian entre una petición y
  /// Reintentar (spec §8 D12).
  EscenarioApi escenario;

  final Duration demora;

  @override
  Future<RespuestaApi> enviar(PeticionApi peticion) async {
    final actual = escenario;
    if (actual == EscenarioApi.lento) {
      await Future<void>.delayed(demora);
    }
    if (actual == EscenarioApi.sinConexion) {
      throw const ErrorDeRedApi();
    }
    return switch ((peticion.metodo, peticion.ruta)) {
      ('GET', rutaOficios) => _oficios(actual),
      ('GET', rutaColonia) => _colonia(peticion, actual),
      _ => _problema(404, RespuestasSimuladas.noEncontrado),
    };
  }

  /// Ruta y escenario sin la petición: nada de lo recibido.
  @override
  String toString() => 'ClienteApiSimulado(${escenario.clave})';

  RespuestaApi _oficios(EscenarioApi escenario) => switch (escenario) {
    EscenarioApi.vacio => _json(RespuestasSimuladas.oficiosVacio),
    EscenarioApi.errorServidor => _problema(
      500,
      RespuestasSimuladas.errorInterno,
    ),
    _ => _json(RespuestasSimuladas.oficios),
  };

  RespuestaApi _colonia(PeticionApi peticion, EscenarioApi escenario) {
    const sinCache = {'cache-control': 'no-store'};
    if (escenario == EscenarioApi.limite) {
      return _problema(
        429,
        RespuestasSimuladas.demasiadasSolicitudes,
        encabezados: {...sinCache, 'retry-after': segundosDeEspera},
      );
    }
    if (escenario == EscenarioApi.errorServidor) {
      return _problema(
        500,
        RespuestasSimuladas.errorInterno,
        encabezados: sinCache,
      );
    }
    if (!_conSesion(peticion) || escenario == EscenarioApi.noAutorizado) {
      return _problema(
        401,
        RespuestasSimuladas.noAutorizado,
        encabezados: sinCache,
      );
    }
    final latValida = _coordenadaValida(peticion.valoresDe('lat'), 90);
    final lonValida = _coordenadaValida(peticion.valoresDe('lon'), 180);
    if (!latValida || !lonValida) {
      return _problema(
        422,
        RespuestasSimuladas.coordenadasInvalidas(
          lat: !latValida,
          lon: !lonValida,
        ),
        encabezados: sinCache,
      );
    }
    return _json(
      escenario == EscenarioApi.fueraDeCobertura
          ? RespuestasSimuladas.coloniaFueraDeCobertura
          : RespuestasSimuladas.coloniaEnCobertura,
      encabezados: sinCache,
    );
  }

  static bool _conSesion(PeticionApi peticion) {
    final valor = peticion.encabezado('authorization');
    if (valor == null || !valor.startsWith('Bearer ')) {
      return false;
    }
    return valor.substring('Bearer '.length).trim().isNotEmpty;
  }

  /// Un solo valor, con el formato de la §4 y dentro de `[-maximo, maximo]`.
  static bool _coordenadaValida(List<String> valores, double maximo) {
    if (valores.length != 1) {
      return false;
    }
    final valor = valores.single;
    if (valor.length > _maximoCoordenada || !_coordenada.hasMatch(valor)) {
      return false;
    }
    return double.parse(valor).abs() <= maximo;
  }

  static RespuestaApi _json(
    String cuerpo, {
    Map<String, String> encabezados = const {},
  }) => RespuestaApi(
    estado: 200,
    encabezados: {'content-type': TiposDeContenido.json, ...encabezados},
    cuerpo: cuerpo,
  );

  static RespuestaApi _problema(
    int estado,
    String cuerpo, {
    Map<String, String> encabezados = const {},
  }) => RespuestaApi(
    estado: estado,
    encabezados: {'content-type': TiposDeContenido.problema, ...encabezados},
    cuerpo: cuerpo,
  );
}
