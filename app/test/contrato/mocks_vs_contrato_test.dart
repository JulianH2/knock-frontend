import 'dart:convert';

import 'package:app/core/red/cliente_api.dart';
import 'package:app/core/red/configuracion_api.dart';
import 'package:app/core/red/simulada/cliente_api_simulado.dart';
import 'package:flutter_test/flutter_test.dart';

import '../soporte/peticiones_simuladas.dart';
import 'validador_de_contrato.dart';

/// Cada respuesta simulada (petición × escenario) con su petición.
Future<List<(PeticionApi, RespuestaApi)>> _todasLasRespuestas() async {
  final respuestas = <(PeticionApi, RespuestaApi)>[];
  for (final escenario in EscenarioApi.values) {
    final cliente = ClienteApiSimulado(
      escenario: escenario,
      demora: Duration.zero,
    );
    for (final peticion in PeticionesSimuladas.todas()) {
      try {
        respuestas.add((peticion, await cliente.enviar(peticion)));
      } on ErrorDeRedApi {
        // `sin_conexion` no produce respuesta: no hay nada que comparar.
      }
    }
  }
  return respuestas;
}

RespuestaApi _alterada(
  RespuestaApi original,
  Object? Function(Object? json) cambio, {
  Map<String, String>? encabezados,
}) => RespuestaApi(
  estado: original.estado,
  encabezados: encabezados ?? original.encabezados,
  cuerpo: jsonEncode(cambio(jsonDecode(original.cuerpo))),
);

Map<String, Object?> _primerOficio(Object? json) =>
    (json! as List<Object?>).first! as Map<String, Object?>;

void main() {
  final tabla = TablaDeContrato.versionada();

  test('TC-TT-MOB-08-07 los mocks cumplen el contrato de la §4', () async {
    final respuestas = await _todasLasRespuestas();
    expect(respuestas, isNotEmpty);

    // Cada mock cumple su fila (y no hay mock sin fila).
    final cubiertas = <String>{};
    for (final (peticion, respuesta) in respuestas) {
      expect(tabla.errores(peticion, respuesta), isEmpty);
      cubiertas.add(
        TablaDeContrato.fila(peticion.metodo, peticion.ruta, respuesta.estado),
      );
    }
    // No hay fila sin mock.
    expect(cubiertas, tabla.filas);
    expect(tabla.filas, hasLength(7));

    // Cada endpoint dice contra qué versión de la §4 se escribió.
    for (final endpoint in tabla.endpoints) {
      final fuente = endpoint['fuente']! as Map<String, Object?>;
      expect(fuente['repo'], 'knock-backend');
      expect(fuente['rama'], 'origin/sprint-02');
      expect(fuente['commit'], matches(RegExp(r'^[0-9a-f]{7,40}$')));
      expect(
        fuente['spec'],
        matches(RegExp(r'^specs/TT-[A-Z]+-\d+-.+/spec\.md$')),
      );
    }

    // Regla de la §4 de TT-API-07 que el esquema no expresa: `colonia` es
    // `null` exactamente cuando `enCobertura` es `false`.
    for (final (peticion, respuesta) in respuestas) {
      if (peticion.ruta.endsWith('/en-punto') && respuesta.estado == 200) {
        final json = jsonDecode(respuesta.cuerpo) as Map<String, Object?>;
        expect(json['colonia'] == null, json['enCobertura'] == false);
      }
    }
  });

  test(
    'TC-TT-MOB-08-07 el comparador rechaza mocks alterados y filas sin mock',
    () async {
      final oficios = await ClienteApiSimulado().enviar(
        PeticionesSimuladas.oficios,
      );
      final colonia = await ClienteApiSimulado().enviar(
        PeticionesSimuladas.colonia(),
      );
      expect(tabla.errores(PeticionesSimuladas.oficios, oficios), isEmpty);

      final alterados = <String, (PeticionApi, RespuestaApi)>{
        'campo renombrado': (
          PeticionesSimuladas.oficios,
          _alterada(oficios, (json) {
            final oficio = _primerOficio(json);
            oficio['claves'] = oficio.remove('clave');
            return json;
          }),
        ),
        'tipo cambiado': (
          PeticionesSimuladas.oficios,
          _alterada(oficios, (json) {
            _primerOficio(json)['nombre'] = 7;
            return json;
          }),
        ),
        'campo extra': (
          PeticionesSimuladas.oficios,
          _alterada(oficios, (json) {
            _primerOficio(json)['precio'] = '100';
            return json;
          }),
        ),
        'campo obligatorio quitado': (
          PeticionesSimuladas.oficios,
          _alterada(oficios, (json) {
            _primerOficio(json).remove('modalidad');
            return json;
          }),
        ),
        'clave de más de 16': (
          PeticionesSimuladas.oficios,
          _alterada(oficios, (json) {
            _primerOficio(json)['clave'] = 'x' * 17;
            return json;
          }),
        ),
        'null donde no se permite': (
          PeticionesSimuladas.oficios,
          _alterada(oficios, (json) {
            _primerOficio(json)['nombre'] = null;
            return json;
          }),
        ),
        'Content-Type distinto': (
          PeticionesSimuladas.oficios,
          _alterada(
            oficios,
            (json) => json,
            encabezados: const {'content-type': 'text/plain'},
          ),
        ),
        'cp de 4 dígitos': (
          PeticionesSimuladas.colonia(),
          _alterada(colonia, (json) {
            ((json! as Map<String, Object?>)['colonia']!
                    as Map<String, Object?>)['cp'] =
                '0000';
            return json;
          }),
        ),
        'colonia sin no-store': (
          PeticionesSimuladas.colonia(),
          _alterada(
            colonia,
            (json) => json,
            encabezados: const {'content-type': 'application/json'},
          ),
        ),
        'estado sin fila': (
          PeticionesSimuladas.oficios,
          RespuestaApi(
            estado: 418,
            encabezados: oficios.encabezados,
            cuerpo: oficios.cuerpo,
          ),
        ),
      };
      for (final MapEntry(key: caso, value: (peticion, respuesta))
          in alterados.entries) {
        expect(tabla.errores(peticion, respuesta), isNotEmpty, reason: caso);
      }

      // Una fila agregada a la tabla que ningún mock produce queda sin cubrir.
      final conFilaDeMas = TablaDeContrato(
        jsonDecode(jsonEncode(tabla.json)) as Map<String, Object?>,
      );
      ((conFilaDeMas.endpoints.first['respuestas']!
          as Map<String, Object?>))['503'] = const {
        'contentType': 'application/problem+json',
      };
      final respuestas = await _todasLasRespuestas();
      final cubiertas = {
        for (final (peticion, respuesta) in respuestas)
          TablaDeContrato.fila(
            peticion.metodo,
            peticion.ruta,
            respuesta.estado,
          ),
      };
      expect(conFilaDeMas.filas.difference(cubiertas), {
        'GET /api/v1/oficios 503',
      });
    },
  );
}
