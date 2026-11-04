import 'package:app/core/errores/failure.dart';
import 'package:app/features/oficios/data/oficio_mapper.dart';
import 'package:app/features/oficios/data/oficios_repository_de_prueba.dart';
import 'package:app/features/oficios/domain/modalidad.dart';
import 'package:app/features/oficios/domain/oficio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Ejemplo del contrato de TT-PRU-01 (§4 de su spec), tal como lo entrega la
/// API.
const _contrato = [
  {'clave': 'ele', 'nombre': 'Electricidad', 'modalidad': 'domicilio'},
  {'clave': 'mec', 'nombre': 'Mecánica', 'modalidad': 'taller'},
  {'clave': 'plo', 'nombre': 'Plomería', 'modalidad': 'domicilio'},
];

Matcher get _rechaza => throwsA(isA<DatosInvalidosFailure>());

void main() {
  group('TC-TT-PRU-02-07 mapeador del contrato', () {
    test('TC-TT-PRU-02-07 convierte el ejemplo del contrato en 3 oficios', () {
      final oficios = OficioMapper.listaDesdeContrato(_contrato);

      expect(oficios, const [
        Oficio(
          clave: 'ele',
          nombre: 'Electricidad',
          modalidad: Modalidad.domicilio,
        ),
        Oficio(clave: 'mec', nombre: 'Mecánica', modalidad: Modalidad.taller),
        Oficio(
          clave: 'plo',
          nombre: 'Plomería',
          modalidad: Modalidad.domicilio,
        ),
      ]);
    });

    test('TC-TT-PRU-02-07 una lista vacía es válida', () {
      expect(OficioMapper.listaDesdeContrato(const <Object?>[]), isEmpty);
    });

    test('TC-TT-PRU-02-07 rechaza lo que no es un arreglo', () {
      expect(() => OficioMapper.listaDesdeContrato(null), _rechaza);
      expect(() => OficioMapper.listaDesdeContrato('oficios'), _rechaza);
      expect(
        () => OficioMapper.listaDesdeContrato(const {'clave': 'x'}),
        _rechaza,
      );
    });

    test('TC-TT-PRU-02-07 rechaza un elemento que no es un objeto', () {
      expect(() => OficioMapper.listaDesdeContrato(const ['ele']), _rechaza);
      expect(() => OficioMapper.listaDesdeContrato(const [null]), _rechaza);
    });

    test('TC-TT-PRU-02-07 rechaza campos ausentes, vacíos o de otro tipo', () {
      const base = {
        'clave': 'ele',
        'nombre': 'Electricidad',
        'modalidad': 'taller',
      };
      for (final campo in ['clave', 'nombre', 'modalidad']) {
        final sin = {...base}..remove(campo);
        expect(
          () => OficioMapper.desdeContrato(sin),
          _rechaza,
          reason: 'sin $campo',
        );
        expect(
          () => OficioMapper.desdeContrato({...base, campo: ''}),
          _rechaza,
          reason: '$campo vacío',
        );
        expect(
          () => OficioMapper.desdeContrato({...base, campo: '   '}),
          _rechaza,
          reason: '$campo en blanco',
        );
        expect(
          () => OficioMapper.desdeContrato({...base, campo: 7}),
          _rechaza,
          reason: '$campo numérico',
        );
        expect(
          () => OficioMapper.desdeContrato({...base, campo: null}),
          _rechaza,
          reason: '$campo nulo',
        );
      }
    });

    test('TC-TT-PRU-02-07 un solo elemento inválido rechaza toda la lista', () {
      expect(
        () => OficioMapper.listaDesdeContrato(const [
          {'clave': 'ele', 'nombre': 'Electricidad', 'modalidad': 'domicilio'},
          {'clave': 'mec', 'nombre': 'Mecánica'},
        ]),
        _rechaza,
      );
    });

    test(
      'TC-TT-PRU-02-07 el rechazo no expone detalles ni datos recibidos',
      () {
        try {
          OficioMapper.desdeContrato(const {'clave': 'secreto-123'});
          fail('debió rechazar');
        } on DatosInvalidosFailure catch (error) {
          expect(error.toString(), 'DatosInvalidosFailure');
          expect(error.toString(), isNot(contains('secreto')));
        }
      },
    );

    test('TC-TT-PRU-02-07 el repositorio de prueba entrega el contrato por el mapeador', () async {
      final desdeRepositorio = await const OficiosRepositoryDePrueba().listar();

      expect(contratoOficiosDePrueba, _contrato);
      expect(desdeRepositorio, OficioMapper.listaDesdeContrato(_contrato));
      expect(desdeRepositorio.map((o) => o.nombre), [
        'Electricidad',
        'Mecánica',
        'Plomería',
      ]);
    });
  });
}
