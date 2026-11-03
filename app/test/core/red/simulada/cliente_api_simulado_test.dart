import 'dart:convert';

import 'package:app/core/red/cliente_api.dart';
import 'package:app/core/red/configuracion_api.dart';
import 'package:app/core/red/simulada/cliente_api_simulado.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../soporte/peticiones_simuladas.dart';

Object? _json(RespuestaApi respuesta) => jsonDecode(respuesta.cuerpo);

Future<RespuestaApi> _enviar(
  PeticionApi peticion, [
  EscenarioApi escenario = EscenarioApi.normal,
]) => ClienteApiSimulado(escenario: escenario).enviar(peticion);

/// Un ProblemDetails genérico con ese estado y sin detalles técnicos.
void _esProblema(RespuestaApi respuesta, int estado) {
  expect(respuesta.estado, estado);
  expect(respuesta.tipoDeContenido, 'application/problem+json');
  final json = _json(respuesta)! as Map<String, Object?>;
  expect(json['type'], isA<String>());
  expect(json['title'], isA<String>());
  expect(json['status'], estado);
  for (final tecnico in ['detail', 'exception', 'stackTrace', 'trace']) {
    expect(json.containsKey(tecnico), isFalse, reason: tecnico);
  }
}

PeticionApi _colonia(String lat, String lon) =>
    PeticionesSimuladas.colonia(consulta: [('lat', lat), ('lon', lon)]);

void main() {
  test(
    'TC-TT-MOB-08-03 simula GET oficios con el ejemplo del contrato',
    () async {
      final respuesta = await _enviar(PeticionesSimuladas.oficios);

      expect(respuesta.estado, 200);
      expect(respuesta.encabezado('Content-Type'), 'application/json');
      // Igual al ejemplo de la §4 de TT-PRU-01, en ese orden.
      expect(_json(respuesta), [
        {'clave': 'ele', 'nombre': 'Electricidad', 'modalidad': 'domicilio'},
        {'clave': 'mec', 'nombre': 'Mecánica', 'modalidad': 'taller'},
        {'clave': 'plo', 'nombre': 'Plomería', 'modalidad': 'domicilio'},
      ]);

      // Ruta o método no simulados: 404 ProblemDetails, nunca un 200 vacío.
      for (final peticion in const [
        PeticionApi(metodo: 'POST', ruta: '/api/v1/oficios'),
        PeticionApi(metodo: 'GET', ruta: '/api/v1/me'),
        // Aún no simulado: espera la revisión de la spec (§8 D13).
        PeticionApi(metodo: 'POST', ruta: '/api/v1/auth/firebase'),
        PeticionApi(metodo: 'GET', ruta: '/api/v9/oficios'),
        PeticionApi(metodo: 'GET', ruta: '/api/v1/oficios/'),
      ]) {
        _esProblema(await _enviar(peticion), 404);
      }
    },
  );

  test('TC-TT-MOB-08-04 simula vacío, 5xx, sin conexión y lentitud', () async {
    final vacio = await _enviar(
      PeticionesSimuladas.oficios,
      EscenarioApi.vacio,
    );
    expect(vacio.estado, 200);
    expect(vacio.tipoDeContenido, 'application/json');
    expect(_json(vacio), isEmpty);

    final error = await _enviar(
      PeticionesSimuladas.oficios,
      EscenarioApi.errorServidor,
    );
    _esProblema(error, 500);

    await expectLater(
      _enviar(PeticionesSimuladas.oficios, EscenarioApi.sinConexion),
      throwsA(isA<ErrorDeRedApi>()),
    );

    const demora = Duration(milliseconds: 150);
    final reloj = Stopwatch()..start();
    final lenta = await ClienteApiSimulado(
      escenario: EscenarioApi.lento,
      demora: demora,
    ).enviar(PeticionesSimuladas.oficios);
    expect(reloj.elapsed, greaterThanOrEqualTo(demora));
    expect(lenta.estado, 200);
    expect(_json(lenta), hasLength(3));
    expect(ClienteApiSimulado.demoraLenta, const Duration(seconds: 2));

    // Un escenario que no aplica a oficios lo deja en `normal`.
    final otro = await _enviar(
      PeticionesSimuladas.oficios,
      EscenarioApi.limite,
    );
    expect(otro.estado, 200);
    expect(_json(otro), hasLength(3));
  });

  test(
    'TC-TT-MOB-08-06 simula la colonia por punto con 401, 422 y 429',
    () async {
      void sinCacheNiCoordenadas(RespuestaApi respuesta, List<String> valores) {
        expect(respuesta.encabezado('Cache-Control'), 'no-store');
        expect(respuesta.encabezado('ETag'), isNull);
        for (final valor in valores) {
          expect(respuesta.cuerpo, isNot(contains(valor)), reason: valor);
        }
      }

      final ok = await _enviar(PeticionesSimuladas.colonia());
      expect(ok.estado, 200);
      expect(ok.tipoDeContenido, 'application/json');
      expect(_json(ok), {
        'enCobertura': true,
        'colonia': {
          'id': '000000000000000000000001',
          'nombre': 'Colonia Simulada Centro',
          'cp': '00000',
          'municipio': 'Municipio de Prueba',
        },
      });
      sinCacheNiCoordenadas(ok, ['20.0543', '-99.3401']);

      // Límites incluidos y 10 decimales.
      for (final (lat, lon) in [
        ('90', '180'),
        ('-90', '-180'),
        ('0', '0'),
        ('20.0543210987', '-99.1234567890'),
      ]) {
        expect((await _enviar(_colonia(lat, lon))).estado, 200, reason: lat);
      }

      final fuera = await _enviar(
        PeticionesSimuladas.colonia(),
        EscenarioApi.fueraDeCobertura,
      );
      expect(fuera.estado, 200);
      expect(_json(fuera), {'enCobertura': false, 'colonia': null});
      sinCacheNiCoordenadas(fuera, ['20.0543', '-99.3401']);

      for (final sinSesion in [
        PeticionesSimuladas.colonia(conSesion: false),
        const PeticionApi(
          metodo: 'GET',
          ruta: '/api/v1/colonias/en-punto',
          consulta: [('lat', '20.0543'), ('lon', '-99.3401')],
          encabezados: {'Authorization': 'Bearer '},
        ),
        const PeticionApi(
          metodo: 'GET',
          ruta: '/api/v1/colonias/en-punto',
          consulta: [('lat', '20.0543'), ('lon', '-99.3401')],
          encabezados: {'Authorization': 'Basic abc'},
        ),
      ]) {
        final respuesta = await _enviar(sinSesion);
        _esProblema(respuesta, 401);
        sinCacheNiCoordenadas(respuesta, ['20.0543', '-99.3401']);
      }

      // Cada valor mal formado, repetido, ausente o fuera de rango → 422 con
      // el parámetro rechazado y sin repetir lo recibido.
      final latInvalidas = [
        '20,05',
        '1e2',
        '+20.05',
        ' 20.05',
        '20.05 ',
        '90.0000000001',
        '-90.5',
        '20.05432109876',
        '1234',
        '0x14',
        'NaN',
        'Infinity',
        '',
        '1,000.5',
      ];
      for (final lat in latInvalidas) {
        final respuesta = await _enviar(_colonia(lat, '-99.3401'));
        _esProblema(respuesta, 422);
        final errores =
            (_json(respuesta)! as Map<String, Object?>)['errors']!
                as Map<String, Object?>;
        expect(errores.keys, ['lat'], reason: lat);
        sinCacheNiCoordenadas(respuesta, [
          if (lat.trim().isNotEmpty) lat,
          '-99.3401',
        ]);
      }
      for (final lon in ['180.1', '-181', '99,5', '1E2']) {
        final respuesta = await _enviar(_colonia('20.0543', lon));
        _esProblema(respuesta, 422);
        final errores =
            (_json(respuesta)! as Map<String, Object?>)['errors']!
                as Map<String, Object?>;
        expect(errores.keys, ['lon'], reason: lon);
      }
      for (final consulta in [
        const [('lat', '20.05'), ('lat', '21.0'), ('lon', '-99.34')],
        const [('lon', '-99.34')],
        const <(String, String)>[],
      ]) {
        final respuesta = await _enviar(
          PeticionesSimuladas.colonia(consulta: consulta),
        );
        _esProblema(respuesta, 422);
        expect(
          ((_json(respuesta)! as Map<String, Object?>)['errors']!
                  as Map<String, Object?>)
              .containsKey('lat'),
          isTrue,
        );
      }
      // Un parámetro desconocido se ignora.
      final conOtro = await _enviar(
        PeticionesSimuladas.colonia(
          consulta: const [('lat', '20.05'), ('lon', '-99.34'), ('x', '1')],
        ),
      );
      expect(conOtro.estado, 200);

      final limite = await _enviar(
        PeticionesSimuladas.colonia(),
        EscenarioApi.limite,
      );
      _esProblema(limite, 429);
      expect(limite.encabezado('Retry-After'), matches(RegExp(r'^\d+$')));
      sinCacheNiCoordenadas(limite, ['20.0543', '-99.3401']);

      final error = await _enviar(
        PeticionesSimuladas.colonia(),
        EscenarioApi.errorServidor,
      );
      _esProblema(error, 500);
      sinCacheNiCoordenadas(error, ['20.0543', '-99.3401']);
    },
  );
}
