import 'package:app/core/errores/failure.dart';
import 'package:app/core/red/cliente_api.dart';
import 'package:app/core/red/configuracion_api.dart';
import 'package:app/core/red/simulada/cliente_api_simulado.dart';
import 'package:app/features/oficios/data/oficios_repository_api.dart';
import 'package:app/features/oficios/domain/modalidad.dart';
import 'package:app/features/oficios/domain/oficio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Doble escrito a mano: responde siempre lo mismo y guarda lo que recibió.
class _ClienteFijo implements ClienteApi {
  _ClienteFijo(this._respuesta);

  final Future<RespuestaApi> Function() _respuesta;
  final peticiones = <PeticionApi>[];

  @override
  Future<RespuestaApi> enviar(PeticionApi peticion) {
    peticiones.add(peticion);
    return _respuesta();
  }
}

_ClienteFijo _responde(
  int estado,
  String cuerpo, {
  String tipo = 'application/json',
}) => _ClienteFijo(
  () async => RespuestaApi(
    estado: estado,
    encabezados: {'Content-Type': tipo},
    cuerpo: cuerpo,
  ),
);

Future<Object?> _errorDe(ClienteApi cliente) async {
  try {
    final oficios = await OficiosRepositoryApi(cliente).listar();
    return oficios;
  } on Failure catch (failure) {
    return failure;
  }
}

void main() {
  test('TC-TT-MOB-08-08 el repositorio de oficios traduce la API a entidades y Failure', () async {
    // 200 de la simulación → los 3 oficios por `OficioMapper`, en orden.
    final oficios = await OficiosRepositoryApi(ClienteApiSimulado()).listar();
    expect(oficios, const [
      Oficio(
        clave: 'ele',
        nombre: 'Electricidad',
        modalidad: Modalidad.domicilio,
      ),
      Oficio(clave: 'mec', nombre: 'Mecánica', modalidad: Modalidad.taller),
      Oficio(clave: 'plo', nombre: 'Plomería', modalidad: Modalidad.domicilio),
    ]);
    expect(
      await OficiosRepositoryApi(
        ClienteApiSimulado(escenario: EscenarioApi.vacio),
      ).listar(),
      isEmpty,
    );

    // Pide la ruta de la §4 con GET.
    final espia = _responde(200, '[]');
    await OficiosRepositoryApi(espia).listar();
    expect(espia.peticiones.single.metodo, 'GET');
    expect(espia.peticiones.single.ruta, '/api/v1/oficios');
    // Acepta parámetros en el Content-Type.
    expect(
      await OficiosRepositoryApi(
        _responde(200, '[]', tipo: 'application/json; charset=utf-8'),
      ).listar(),
      isEmpty,
    );

    // 5xx y error de red → servicio no disponible.
    expect(
      await _errorDe(ClienteApiSimulado(escenario: EscenarioApi.errorServidor)),
      isA<ServicioNoDisponibleFailure>(),
    );
    expect(
      await _errorDe(ClienteApiSimulado(escenario: EscenarioApi.sinConexion)),
      isA<ServicioNoDisponibleFailure>(),
    );
    for (final estado in [500, 502, 503, 302]) {
      expect(
        await _errorDe(_responde(estado, '', tipo: 'application/problem+json')),
        isA<ServicioNoDisponibleFailure>(),
        reason: '$estado',
      );
    }

    // Cualquier 4xx → solicitud rechazada con su estado.
    for (final estado in [400, 401, 404, 422, 429, 499]) {
      expect(
        await _errorDe(
          _responde(estado, '{}', tipo: 'application/problem+json'),
        ),
        SolicitudRechazadaFailure(estado),
        reason: '$estado',
      );
    }

    // 200 fuera de contrato → datos inválidos.
    for (final (cuerpo, tipo) in [
      ('{}', 'application/json'),
      (
        '[{"nombre": "Electricidad", "modalidad": "domicilio"}]',
        'application/json',
      ),
      (
        '[{"clave": "ele", "nombre": 7, "modalidad": "domicilio"}]',
        'application/json',
      ),
      ('no es json', 'application/json'),
      ('', 'application/json'),
      ('null', 'application/json'),
      ('[]', 'text/plain'),
      ('[]', 'application/problem+json'),
    ]) {
      expect(
        await _errorDe(_responde(200, cuerpo, tipo: tipo)),
        isA<DatosInvalidosFailure>(),
        reason: '$cuerpo $tipo',
      );
    }
    expect(
      await _errorDe(
        _ClienteFijo(() async => const RespuestaApi(estado: 200, cuerpo: '[]')),
      ),
      isA<DatosInvalidosFailure>(),
      reason: 'sin Content-Type',
    );
  });
}
