import 'package:app/core/errores/failure.dart';
import 'package:app/features/visitas/data/visitas_mapper.dart';
import 'package:app/features/visitas/data/visitas_repository_de_prueba.dart';
import 'package:app/features/visitas/domain/visita.dart';
import 'package:app/features/visitas/domain/visita_acciones.dart';
import 'package:app/features/visitas/presentation/mensajes_visita.dart';
import 'package:flutter_test/flutter_test.dart';

Visita _v(String rol, String estado, {bool puedeLlegar = false, bool? avisa}) =>
    Visita(
      id: 'x',
      rol: rol,
      estado: estado,
      modalidad: 'domicilio',
      dia: 'd',
      hora: 'h',
      tope: 1,
      lugar: const VisitaLugar(tipo: 'domicilio'),
      puedeLlegar: puedeLlegar,
      puedeAvisar: avisa,
    );

void main() {
  group('validaciones del contrato', () {
    test('motivo de cancelar: 8 a 300 caracteres sin espacios sobrantes', () {
      expect(errorMotivoCancelacion('   '), isNotNull);
      expect(errorMotivoCancelacion('corto'), contains('al menos 8'));
      expect(errorMotivoCancelacion('  1234567  '), isNotNull);
      expect(errorMotivoCancelacion('12345678'), isNull);
      expect(errorMotivoCancelacion('x' * 300), isNull);
      expect(errorMotivoCancelacion('x' * 301), contains('como máximo 300'));
    });

    test('texto de no terminado: 8 a 500', () {
      expect(errorTextoNoTerminado(''), isNotNull);
      expect(errorTextoNoTerminado('1234567'), isNotNull);
      expect(errorTextoNoTerminado('x' * 500), isNull);
      expect(errorTextoNoTerminado('x' * 501), isNotNull);
    });

    test('código de llegada: exactamente cuatro dígitos', () {
      expect(errorCodigoLlegada('0042'), isNull);
      expect(errorCodigoLlegada('042'), isNotNull);
      expect(errorCodigoLlegada('00422'), isNotNull);
      expect(errorCodigoLlegada('12a4'), isNotNull);
      expect(errorCodigoLlegada('１２３４'), isNotNull);
    });

    test('precio: entero positivo dentro de int32', () {
      expect(errorPrecio(''), 'Escribe el precio.');
      expect(errorPrecio('12.5'), isNotNull);
      expect(errorPrecio('-3'), isNotNull);
      expect(errorPrecio('0'), isNotNull);
      expect(errorPrecio('2147483648'), isNotNull);
      expect(errorPrecio('450'), isNull);
    });

    test('descripción obligatoria, recomendación opcional, fotos 1 a 5', () {
      expect(errorDescripcionTrabajo(' '), isNotNull);
      expect(errorDescripcionTrabajo('Cambié la llave'), isNull);
      expect(errorRecomendacion(''), isNull);
      expect(errorRecomendacion('x' * 1001), isNotNull);
      expect(errorFotos(0), isNotNull);
      expect(errorFotos(1), isNull);
      expect(errorFotos(5), isNull);
      expect(errorFotos(6), isNotNull);
    });

    test('la reprogramación exige una fecha futura', () {
      final ahora = DateTime(2026, 11, 22, 10);
      expect(errorFechaReprogramacion(ahora, ahora), isNotNull);
      expect(
        errorFechaReprogramacion(
          ahora.subtract(const Duration(hours: 1)),
          ahora,
        ),
        isNotNull,
      );
      expect(
        errorFechaReprogramacion(ahora.add(const Duration(minutes: 1)), ahora),
        isNull,
      );
    });

    test('rango de la agenda: orden y 31 días como máximo', () {
      final d = DateTime(2026, 11, 1);
      expect(errorRangoAgenda(d, DateTime(2026, 10, 31)), isNotNull);
      expect(errorRangoAgenda(d, d), isNull);
      expect(errorRangoAgenda(d, DateTime(2026, 12, 2)), isNull);
      expect(errorRangoAgenda(d, DateTime(2026, 12, 3)), contains('31 días'));
    });
  });

  group('horarios', () {
    HorarioDia abierto(List<FranjaHorario> f) =>
        HorarioDia(dia: 'lunes', abierto: true, franjas: f);
    const f = FranjaHorario.new;

    test('día cerrado sin franjas; abierto con una o dos', () {
      expect(
        errorHorarioDia(const HorarioDia(dia: 'lunes', abierto: false)),
        isNull,
      );
      expect(
        errorHorarioDia(
          const HorarioDia(
            dia: 'lunes',
            abierto: false,
            franjas: [FranjaHorario(inicio: '09:00', fin: '10:00')],
          ),
        ),
        isNotNull,
      );
      expect(errorHorarioDia(abierto([])), isNotNull);
      expect(
        errorHorarioDia(abierto([f(inicio: '09:00', fin: '18:00')])),
        isNull,
      );
      expect(
        errorHorarioDia(
          abierto([
            f(inicio: '09:00', fin: '13:00'),
            f(inicio: '15:00', fin: '19:00'),
          ]),
        ),
        isNull,
      );
      expect(
        errorHorarioDia(
          abierto([
            f(inicio: '08:00', fin: '09:00'),
            f(inicio: '10:00', fin: '11:00'),
            f(inicio: '12:00', fin: '13:00'),
          ]),
        ),
        isNotNull,
      );
    });

    test('inicio anterior al fin, horas HH:mm válidas y sin traslapes', () {
      expect(
        errorHorarioDia(abierto([f(inicio: '10:00', fin: '10:00')])),
        isNotNull,
      );
      expect(
        errorHorarioDia(abierto([f(inicio: '18:00', fin: '09:00')])),
        isNotNull,
      );
      expect(
        errorHorarioDia(abierto([f(inicio: '9:00', fin: '10:00')])),
        isNotNull,
      );
      expect(
        errorHorarioDia(abierto([f(inicio: '09:00', fin: '24:00')])),
        isNotNull,
      );
      expect(
        errorHorarioDia(
          abierto([
            f(inicio: '09:00', fin: '13:00'),
            f(inicio: '12:00', fin: '15:00'),
          ]),
        ),
        contains('traslapar'),
      );
      expect(
        errorHorarioDia(
          abierto([
            f(inicio: '09:00', fin: '13:00'),
            f(inicio: '13:00', fin: '15:00'),
          ]),
        ),
        isNull,
      );
    });

    test('exige los siete días, cada uno una vez y en orden', () {
      expect(errorHorarios(horarioCerrado()), isNull);
      expect(
        () => errorHorarios(horarioCerrado().sublist(1)),
        throwsA(isA<DatosInvalidosFailure>()),
      );
      final repetido = horarioCerrado()
        ..[1] = const HorarioDia(dia: 'lunes', abierto: false);
      expect(
        () => errorHorarios(repetido),
        throwsA(isA<DatosInvalidosFailure>()),
      );
      final conError = horarioCerrado()
        ..[2] = const HorarioDia(
          dia: 'miercoles',
          abierto: true,
          franjas: [FranjaHorario(inicio: '10:00', fin: '09:00')],
        );
      expect(errorHorarios(conError), startsWith('Miércoles:'));
    });
  });

  group('AccionesVisita', () {
    test('cliente confirmada: reprogramar, cancelar y aviso; no llegada', () {
      final a = AccionesVisita(_v('cliente', 'confirmada', avisa: true));
      expect(a.reprogramar, isTrue);
      expect(a.cancelar, isTrue);
      expect(a.aviso, isTrue);
      expect(a.llegada, isFalse);
      expect(a.clienteAusente, isFalse);
      expect(a.terminar, isFalse);
    });

    test('el aviso necesita puedeAvisar y visita confirmada o en curso', () {
      expect(AccionesVisita(_v('cliente', 'confirmada')).aviso, isFalse);
      expect(
        AccionesVisita(_v('cliente', 'terminada', avisa: true)).aviso,
        isFalse,
      );
      expect(
        AccionesVisita(_v('tecnico', 'confirmada', avisa: true)).aviso,
        isFalse,
      );
    });

    test('técnico: llegada solo con puedeLlegar; ausente solo confirmada', () {
      expect(AccionesVisita(_v('tecnico', 'confirmada')).llegada, isFalse);
      final a = AccionesVisita(_v('tecnico', 'confirmada', puedeLlegar: true));
      expect(a.llegada, isTrue);
      expect(a.clienteAusente, isTrue);
      expect(a.terminar, isFalse);
    });

    test('en curso: el técnico termina y cotiza; el cliente decide', () {
      final t = AccionesVisita(_v('tecnico', 'en_curso'));
      expect(t.terminar, isTrue);
      expect(t.cotizacionFinal, isTrue);
      expect(t.decidirCotizacion, isFalse);
      final c = AccionesVisita(_v('cliente', 'en_curso'));
      expect(c.decidirCotizacion, isTrue);
      expect(c.terminar, isFalse);
    });

    test('terminada: el cliente reporta y da permiso; el técnico nada', () {
      final c = AccionesVisita(_v('cliente', 'terminada'));
      expect(c.noTerminado, isTrue);
      expect(c.permisoFotos, isTrue);
      expect(c.alguna, isTrue);
      expect(AccionesVisita(_v('tecnico', 'terminada')).alguna, isFalse);
    });

    test('cancelada o no presentada no ofrecen nada', () {
      expect(AccionesVisita(_v('cliente', 'cancelada')).alguna, isFalse);
      expect(AccionesVisita(_v('tecnico', 'no_presentado')).alguna, isFalse);
    });
  });

  group('mensajeDeErrorVisita', () {
    test('códigos de llegada y reglas genéricas', () {
      expect(
        mensajeDeErrorVisita(const ReglaDeNegocioFailure('wrong_code')),
        contains('código no es correcto'),
      );
      expect(
        mensajeDeErrorVisita(const ReglaDeNegocioFailure('visit_locked')),
        contains('bloqueada'),
      );
      expect(
        mensajeDeErrorVisita(const ReglaDeNegocioFailure('otra')),
        'La visita ya no permite esta acción.',
      );
      expect(
        mensajeDeErrorVisita(const RutaNoDisponibleFailure()),
        'Esta función todavía no está disponible.',
      );
      expect(
        mensajeDeErrorVisita(const ServicioNoDisponibleFailure()),
        contains('no está disponible'),
      );
      expect(
        mensajeDeErrorVisita(const DatosInvalidosFailure()),
        'Revisa los datos e intenta de nuevo.',
      );
    });
  });

  group('VisitasMapper (acciones)', () {
    test('aviso, término, no terminado, cotización y decisión', () {
      final aviso = VisitasMapper.aviso({
        'texto': 'Hola',
        'incluyeCodigo': false,
        'incluyeDireccion': false,
      });
      expect(aviso.texto, 'Hola');
      expect(aviso.incluyeCodigo, isFalse);
      expect(
        VisitasMapper.termino({
          'visitaId': 'v1',
          'estado': 'terminada',
          'terminadaEn': '2026-11-25T18:00:00Z',
        }).estado,
        'terminada',
      );
      expect(
        VisitasMapper.noTerminado({'visitaId': 'v1', 'estado': 'en_revision'})
            .estado,
        'en_revision',
      );
      final c = VisitasMapper.cotizacionFinal({
        'visitaId': 'v1',
        'precio': '450',
        'estado': 'pendiente',
        'venceEn': '2026-11-26T18:00:00Z',
      });
      expect(c.precio, 450);
      expect(
        VisitasMapper.decision({
          'visitaId': 'v1',
          'estado': 'rechazada',
          'resultado': 'solo_visita',
        }).resultado,
        'solo_visita',
      );
      expect(
        VisitasMapper.decision({
          'visitaId': 'v1',
          'estado': 'aprobada',
          'resultado': null,
        }).resultado,
        isNull,
      );
      expect(
        VisitasMapper.permisoFotos({'visitaId': 'v1', 'permiso': true}).permiso,
        isTrue,
      );
    });

    test('horarios ida y vuelta', () {
      final json = {
        'horarios': [
          {
            'dia': 'lunes',
            'abierto': true,
            'franjas': [
              {'inicio': '09:00', 'fin': '13:00'},
            ],
          },
          {'dia': 'martes', 'abierto': false, 'franjas': <Object?>[]},
        ],
      };
      final h = VisitasMapper.horarios(json);
      expect(
        h.first.franjas.single,
        const FranjaHorario(inicio: '09:00', fin: '13:00'),
      );
      expect(h.last.abierto, isFalse);
      expect(VisitasMapper.horariosAJson(h), json);
    });

    test('un campo faltante es DatosInvalidosFailure', () {
      expect(
        () => VisitasMapper.cotizacionFinal({'visitaId': 'v1'}),
        throwsA(isA<DatosInvalidosFailure>()),
      );
      expect(
        () => VisitasMapper.horarios({'horarios': 'x'}),
        throwsA(isA<DatosInvalidosFailure>()),
      );
    });
  });

  group('VisitasRepositoryDePrueba (reglas de las acciones)', () {
    test('tres códigos incorrectos bloquean la visita', () async {
      final repo = VisitasRepositoryDePrueba();
      for (var i = 0; i < 2; i++) {
        await expectLater(
          repo.llegada('t1', codigo: '0000'),
          throwsA(
            isA<ReglaDeNegocioFailure>().having(
              (e) => e.codigo,
              'codigo',
              'wrong_code',
            ),
          ),
        );
      }
      await expectLater(
        repo.llegada('t1', codigo: '0000'),
        throwsA(
          isA<ReglaDeNegocioFailure>().having(
            (e) => e.codigo,
            'codigo',
            'visit_locked',
          ),
        ),
      );
      await expectLater(
        repo.llegada('t1', codigo: '1234'),
        throwsA(isA<ReglaDeNegocioFailure>()),
      );
    });

    test('la llegada correcta deja la visita en curso', () async {
      final repo = VisitasRepositoryDePrueba();
      final v = await repo.llegada('t1', codigo: '1234');
      expect(v.estado, 'en_curso');
      expect(v.puedeLlegar, isFalse);
      expect(v.llegadaEn, isNotNull);
    });

    test('una sola cotización final y una sola vez no terminado', () async {
      final repo = VisitasRepositoryDePrueba();
      await repo.enviarCotizacionFinal(
        't2',
        precio: 500,
        descripcion: 'Trabajo',
      );
      await expectLater(
        repo.enviarCotizacionFinal('t2', precio: 500, descripcion: 'Trabajo'),
        throwsA(isA<ReglaDeNegocioFailure>()),
      );
      await repo.noTerminado('c2', texto: 'Quedó una fuga');
      await expectLater(
        repo.noTerminado('c2', texto: 'Quedó una fuga'),
        throwsA(isA<ReglaDeNegocioFailure>()),
      );
    });

    test('terminar exige fotos y estado en curso', () async {
      final repo = VisitasRepositoryDePrueba();
      await expectLater(
        repo.terminar('t2', descripcion: 'Listo', recomendacion: '', fotos: []),
        throwsA(isA<DatosInvalidosFailure>()),
      );
      await expectLater(
        repo.terminar(
          't1',
          descripcion: 'Listo',
          recomendacion: '',
          fotos: ['a'],
        ),
        throwsA(isA<ReglaDeNegocioFailure>()),
      );
    });
  });
}
