import 'package:app/core/red/cliente_api.dart';
import 'package:app/core/red/cliente_api_provider.dart';
import 'package:app/core/red/configuracion_api.dart';
import 'package:app/core/red/simulada/cliente_api_simulado.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

ConfiguracionApi _leer(
  String url, {
  String escenario = '',
  bool esRelease = false,
}) => ConfiguracionApi.desde(
  url: url,
  escenario: escenario,
  esRelease: esRelease,
);

Matcher _errorPor(MotivoDeErrorDeConfiguracion motivo) => throwsA(
  isA<ErrorDeConfiguracionApi>().having((e) => e.motivo, 'motivo', motivo),
);

/// El proveedor de un contenedor con esa configuración.
ProviderContainer _contenedor(ConfiguracionApi configuracion) {
  final contenedor = ProviderContainer(
    overrides: [configuracionApiProvider.overrideWithValue(configuracion)],
  );
  addTearDown(contenedor.dispose);
  return contenedor;
}

void main() {
  test('TC-TT-MOB-08-01 lee la URL base y el modo desde dart-define', () {
    // Sin valor fuera de release → simulado, escenario `normal`.
    final simulado = _leer('');
    expect(simulado.modo, ModoApi.simulado);
    expect(simulado.baseUrl, isNull);
    expect(simulado.escenario, EscenarioApi.normal);

    // Cada escenario de la §5 se acepta en modo simulado.
    for (final escenario in EscenarioApi.values) {
      expect(_leer('', escenario: escenario.clave).escenario, escenario);
    }
    expect(EscenarioApi.values.map((e) => e.clave), [
      'normal',
      'vacio',
      'error_servidor',
      'sin_conexion',
      'lento',
      'no_autorizado',
      'fuera_de_cobertura',
      'limite',
    ]);
    for (final desconocido in ['Normal', 'error', ' normal', 'otro']) {
      expect(
        () => _leer('', escenario: desconocido),
        _errorPor(MotivoDeErrorDeConfiguracion.escenarioNoPermitido),
        reason: desconocido,
      );
    }

    // `https://<host>[:puerto]` → real con ese origen (también en release).
    final real = _leer('https://api.ejemplo.invalid');
    expect(real.modo, ModoApi.real);
    expect(real.baseUrl, Uri.parse('https://api.ejemplo.invalid'));
    expect(
      _leer('https://api.ejemplo.invalid:8443/').baseUrl,
      Uri.parse('https://api.ejemplo.invalid:8443'),
    );
    expect(
      _leer('https://api.ejemplo.invalid', esRelease: true).modo,
      ModoApi.real,
    );

    // `http://` solo hacia hosts locales y fuera de release.
    for (final local in [
      'http://127.0.0.1:5000',
      'http://localhost:5000',
      'http://10.0.2.2:5000',
    ]) {
      final configuracion = _leer(local);
      expect(configuracion.modo, ModoApi.real, reason: local);
      expect(configuracion.baseUrl, Uri.parse(local));
      expect(
        () => _leer(local, esRelease: true),
        _errorPor(MotivoDeErrorDeConfiguracion.urlNoPermitida),
        reason: local,
      );
    }

    // Cualquier otro valor es un error explícito, nunca el modo simulado.
    for (final invalida in [
      'http://api.ejemplo.invalid',
      'http://192.168.0.10:5000',
      'ftp://api.ejemplo.invalid',
      'ws://localhost:5000',
      'https://usuario:clave@api.ejemplo.invalid',
      'https://api.ejemplo.invalid/api/v1',
      'https://api.ejemplo.invalid?x=1',
      'https://api.ejemplo.invalid?',
      'https://api.ejemplo.invalid#inicio',
      'https://',
      'api.ejemplo.invalid',
      '/api/v1',
      ' ',
      'https://api.ejemplo.invalid ',
      'https://api.ejemplo.invalid:0',
      'https://[::1',
    ]) {
      expect(
        () => _leer(invalida),
        _errorPor(MotivoDeErrorDeConfiguracion.urlNoPermitida),
        reason: invalida,
      );
    }

    // `KNOCK_API_ESCENARIO` solo en modo simulado.
    expect(
      () => _leer('https://api.ejemplo.invalid', escenario: 'normal'),
      _errorPor(MotivoDeErrorDeConfiguracion.escenarioNoPermitido),
    );

    // La configuración de las pruebas (sin `--dart-define`) es la simulada.
    expect(ConfiguracionApi.desdeEntorno().modo, ModoApi.simulado);
  });

  test('TC-TT-MOB-08-02 release nunca usa la API simulada y el modo real sin cliente falla', () {
    // Release sin URL (aunque venga escenario) → error, nunca simulado.
    for (final escenario in ['', 'normal', 'vacio']) {
      expect(
        () => _leer('', escenario: escenario, esRelease: true),
        _errorPor(MotivoDeErrorDeConfiguracion.releaseSinUrl),
        reason: escenario,
      );
    }

    // Modo real (en cualquier compilación) sin el cliente de TT-MOB-03:
    // el proveedor falla con `ErrorDeConfiguracionApi` y nunca entrega la
    // simulación.
    for (final esRelease in [false, true]) {
      final contenedor = _contenedor(
        _leer('https://api.ejemplo.invalid', esRelease: esRelease),
      );
      expect(
        () => contenedor.read(clienteApiProvider),
        throwsA(
          isA<ProviderException>().having(
            (e) => e.exception,
            'exception',
            isA<ErrorDeConfiguracionApi>().having(
              (e) => e.motivo,
              'motivo',
              MotivoDeErrorDeConfiguracion.clienteRealNoDisponible,
            ),
          ),
        ),
      );
    }
    expect(
      () => crearClienteApi(_leer('http://10.0.2.2:5000')),
      _errorPor(MotivoDeErrorDeConfiguracion.clienteRealNoDisponible),
    );

    // En modo simulado el proveedor entrega la simulación con su escenario.
    final cliente = _contenedor(_leer('', escenario: 'vacio'))
        .read(clienteApiProvider);
    expect(cliente, isA<ClienteApiSimulado>());
    expect((cliente as ClienteApiSimulado).escenario, EscenarioApi.vacio);
  });
}
