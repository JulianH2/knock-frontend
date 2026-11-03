import 'package:app/core/errores/failure.dart';
import 'package:app/core/red/cliente_api.dart';
import 'package:app/core/red/configuracion_api.dart';
import 'package:app/core/red/simulada/cliente_api_simulado.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../soporte/codigo_fuente.dart';
import '../../soporte/peticiones_simuladas.dart';

final _registro = RegExp(r'\b(print|debugPrint|log|debugPrintStack)\s*\(');

/// Formas de dato real que no pueden aparecer en los mocks.
final _formasDeDatoReal = <String, RegExp>{
  'celular de 10 dígitos': RegExp(r'(?<![0-9])[0-9]{10}(?![0-9])'),
  'CURP': RegExp(r'[A-Z]{4}[0-9]{6}[HM][A-Z]{5}[A-Z0-9][0-9]'),
  'correo': RegExp(r'[\w.+-]+@[\w-]+\.[\w.-]+'),
  'JWT': RegExp('eyJ'),
  'URL fuera de *.invalid': RegExp(
    r'https?://(?![a-z0-9.-]+\.invalid(?:[:/"\s]|$))',
  ),
};

/// Lo que no puede mostrar el `toString()` de un error.
const _prohibidoEnErrores = [
  '://',
  'ejemplo',
  'usuario',
  'clave',
  '20.0543',
  '-99.3401',
  'simulado-',
  'Bearer',
  'firebase',
  '{',
];

void main() {
  test('TC-TT-MOB-08-11 la red no registra ni expone datos y los mocks son ficticios', () async {
    // 1. Sin registros en la red ni en el repositorio de oficios.
    final codigo = [
      ...archivosBajo('lib/core/red'),
      ...archivosBajo('lib/features/oficios/data'),
    ];
    expect(codigo, isNotEmpty);
    for (final (:ruta, :texto) in codigo) {
      expect(_registro.hasMatch(sinComentarios(texto)), isFalse, reason: ruta);
    }

    // 2. Los errores y valores de red no muestran URL, coordenadas, tokens
    // ni cuerpo.
    final textos = <String>[
      const ErrorDeRedApi().toString(),
      for (final motivo in MotivoDeErrorDeConfiguracion.values)
        ErrorDeConfiguracionApi(motivo).toString(),
      const DatosInvalidosFailure().toString(),
      const ServicioNoDisponibleFailure().toString(),
      const SolicitudRechazadaFailure(422).toString(),
      PeticionesSimuladas.colonia().toString(),
      (await ClienteApiSimulado().enviar(PeticionesSimuladas.colonia()))
          .toString(),
      ConfiguracionApi.desde(
        url: 'https://api.ejemplo.invalid',
        escenario: '',
        esRelease: false,
      ).toString(),
    ];
    for (final url in [
      'https://usuario:clave@api.ejemplo.invalid',
      'http://api.ejemplo.invalid/ruta?lat=20.0543&lon=-99.3401',
    ]) {
      try {
        ConfiguracionApi.desde(url: url, escenario: '', esRelease: false);
        fail('$url debió rechazarse');
      } on ErrorDeConfiguracionApi catch (error) {
        textos.add(error.toString());
      }
    }
    for (final texto in textos) {
      for (final prohibido in _prohibidoEnErrores) {
        expect(texto, isNot(contains(prohibido)), reason: texto);
      }
    }

    // 3. Los mocks y la tabla no tienen datos con forma de dato real, ni
    // en el código ni en las respuestas que se generan.
    final fuentes = [
      ...archivosBajo('lib/core/red/simulada'),
      ...archivosBajo('test/contrato', extensiones: const {'.json'}),
      for (final escenario in EscenarioApi.values)
        if (escenario != EscenarioApi.sinConexion)
          for (final peticion in PeticionesSimuladas.todas())
            (
              ruta: '${escenario.clave} ${peticion.ruta}',
              texto: (await ClienteApiSimulado(
                escenario: escenario,
                demora: Duration.zero,
              ).enviar(peticion)).cuerpo,
            ),
    ];
    expect(fuentes.length, greaterThan(3));
    for (final (:ruta, :texto) in fuentes) {
      for (final MapEntry(key: forma, value: patron)
          in _formasDeDatoReal.entries) {
        expect(patron.hasMatch(texto), isFalse, reason: '$forma en $ruta');
      }
    }

    // Los patrones sí detectan datos con esa forma (no aceptan todo).
    for (final (forma, ejemplo) in [
      ('celular de 10 dígitos', '"telefono": "5500000000"'),
      ('CURP', 'XEXX010101HNEXXXA4'),
      ('correo', 'persona@correo.example'),
      ('JWT', 'eyJhbGciOi'),
      ('URL fuera de *.invalid', 'https://api.knock.example/x'),
    ]) {
      expect(
        _formasDeDatoReal[forma]!.hasMatch(ejemplo),
        isTrue,
        reason: forma,
      );
    }
    expect(
      _formasDeDatoReal['URL fuera de *.invalid']!.hasMatch(
        'https://api.ejemplo.invalid/x',
      ),
      isFalse,
    );
  });
}
