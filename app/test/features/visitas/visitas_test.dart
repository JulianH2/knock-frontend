import 'package:app/core/errores/failure.dart';
import 'package:app/features/visitas/data/visitas_mapper.dart';
import 'package:app/features/visitas/data/visitas_repository_de_prueba.dart';
import 'package:app/features/visitas/domain/visita.dart';
import 'package:app/features/visitas/presentation/agenda_screen.dart';
import 'package:app/features/visitas/presentation/visita_screen.dart';
import 'package:app/features/visitas/visitas_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _montar(
  WidgetTester tester,
  VisitasRepositoryDePrueba repo,
  Widget home,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [visitasRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(home: home),
    ),
  );
  await tester.pumpAndSettle();
}

const _visita = VisitaScreen(visitaId: 'v1');

void main() {
  group('VisitasMapper', () {
    test('lee la visita con enteros como cadena y campos nulos', () {
      final v = VisitasMapper.visita({
        'id': 'v1',
        'rol': 'cliente',
        'estado': 'confirmada',
        'modalidad': 'domicilio',
        'dia': 'Lunes',
        'hora': '10:00',
        'precio': '350',
        'tope': 500,
        'tecnico': {
          'nombre': 'Luis',
          'fotoUrl': null,
          'verificado': true,
          'nivelVerificacion': 'basico',
          'telefono': null,
          'whatsapp': null,
        },
        'cliente': {'colonia': 'Centro'},
        'lugar': {'tipo': 'domicilio_cliente', 'direccion': null},
        'codigo': null,
        'codigoVenceEn': null,
        'motivoCodigo': null,
        'reglaSeguridad': null,
        'puedeAvisar': null,
        'puedeLlegar': false,
        'llegadaEn': null,
      });
      expect(v.precio, 350);
      expect(v.tope, 500);
      expect(v.coloniaCliente, 'Centro');
      expect(v.codigo, isNull);
    });

    test('agenda, reprogramación, cancelación y ausencia', () {
      final a = VisitasMapper.agenda({
        'items': [
          {
            'id': 'v1',
            'estado': 'confirmada',
            'modalidad': 'taller',
            'fechaHora': '2026-11-25T16:00:00Z',
            'dia': 'Miércoles',
            'hora': '10:00',
            'precio': null,
          },
        ],
        'nextCursor': null,
      });
      expect(a.items.single.precio, isNull);
      expect(a.nextCursor, isNull);

      final r = VisitasMapper.respuesta({
        'visitaId': 'v1',
        'aceptada': true,
        'fechaHora': '2026-11-25T16:00:00Z',
        'reprogramaciones': '2',
      });
      expect(r.reprogramaciones, 2);
      expect(
        VisitasMapper.cancelacion({
          'visitaId': 'v1',
          'estado': 'cancelada',
          'tardia': true,
        }).tardia,
        isTrue,
      );
      expect(
        VisitasMapper.ausencia({
          'visitaId': 'v1',
          'estado': 'x',
          'quienFalto': 'cliente',
        }).quienFalto,
        'cliente',
      );
    });

    test('un precio inválido es DatosInvalidosFailure', () {
      expect(
        () => VisitasMapper.agendaItem({
          'id': 'v1',
          'estado': 'x',
          'modalidad': 'y',
          'fechaHora': '2026-11-25T16:00:00Z',
          'dia': 'd',
          'hora': 'h',
          'precio': 'abc',
        }),
        throwsA(isA<DatosInvalidosFailure>()),
      );
    });
  });

  test('validarMotivoCancelacion exige un motivo', () {
    expect(validarMotivoCancelacion(' cambio de planes '), 'cambio de planes');
    expect(() => validarMotivoCancelacion('  '), throwsA(isA<Failure>()));
  });

  group('AgendaScreen', () {
    testWidgets('lista las visitas', (tester) async {
      await _montar(tester, VisitasRepositoryDePrueba(), const AgendaScreen());
      expect(find.textContaining('Miércoles 25 de noviembre'), findsOneWidget);
      expect(find.textContaining('A domicilio'), findsOneWidget);
    });

    testWidgets('vacío', (tester) async {
      await _montar(
        tester,
        VisitasRepositoryDePrueba(visitas: const []),
        const AgendaScreen(),
      );
      expect(find.text('No tienes visitas programadas'), findsOneWidget);
    });

    testWidgets('404 de ruta no es un error de la app', (tester) async {
      await _montar(
        tester,
        VisitasRepositoryDePrueba(falla: const RutaNoDisponibleFailure()),
        const AgendaScreen(),
      );
      expect(
        find.text('Esta función todavía no está disponible.'),
        findsOneWidget,
      );
    });

    testWidgets('503 con Reintentar', (tester) async {
      await _montar(
        tester,
        VisitasRepositoryDePrueba(falla: const ServicioNoDisponibleFailure()),
        const AgendaScreen(),
      );
      expect(find.text('Reintentar'), findsOneWidget);
    });
  });

  group('VisitaScreen', () {
    testWidgets('muestra el detalle sin teléfono ni dirección del cliente', (
      tester,
    ) async {
      await _montar(tester, VisitasRepositoryDePrueba(), _visita);
      expect(find.text('Estado: Confirmada'), findsOneWidget);
      expect(find.text('Técnico: Luis Prueba (verificado)'), findsOneWidget);
      expect(find.text('Colonia: Colonia Ficticia'), findsOneWidget);
    });

    testWidgets('cancelar pide motivo y cancela', (tester) async {
      final repo = VisitasRepositoryDePrueba();
      await _montar(tester, repo, _visita);
      await tester.scrollUntilVisible(
        find.text('Cancelar visita'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Cancelar visita'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Cambio de planes');
      await tester.tap(find.widgetWithText(FilledButton, 'Cancelar visita'));
      await tester.pumpAndSettle();
      expect(repo.acciones, ['cancelar:v1']);
      expect(find.text('Visita cancelada.'), findsOneWidget);
      expect(find.text('Estado: Cancelada'), findsOneWidget);
    });

    testWidgets('«no se presentó» confirma y registra', (tester) async {
      final repo = VisitasRepositoryDePrueba();
      await _montar(tester, repo, _visita);
      await tester.tap(find.text('El técnico no se presentó'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();
      expect(repo.acciones, ['ausente:v1']);
      expect(
        find.text('Registramos que el técnico no se presentó.'),
        findsOneWidget,
      );
    });

    testWidgets('responder a un nuevo horario', (tester) async {
      final repo = VisitasRepositoryDePrueba();
      await _montar(tester, repo, _visita);
      await tester.tap(find.text('Responder a un nuevo horario'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aceptar'));
      await tester.pumpAndSettle();
      expect(repo.acciones, ['respuesta:v1:true']);
      expect(find.text('Aceptaste el nuevo horario.'), findsOneWidget);
    });

    testWidgets('reprogramar elige fecha y hora', (tester) async {
      final repo = VisitasRepositoryDePrueba();
      await _montar(tester, repo, _visita);
      await tester.tap(find.text('Reprogramar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(repo.acciones, ['reprogramar:v1']);
      expect(find.textContaining('Propusiste el'), findsOneWidget);
    });

    testWidgets('una acción sin ruta en el gateway avisa sin romper', (
      tester,
    ) async {
      await _montar(
        tester,
        VisitasRepositoryDePrueba(
          fallaAcciones: const RutaNoDisponibleFailure(),
        ),
        _visita,
      );
      await tester.tap(find.text('El técnico no se presentó'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();
      expect(
        find.text('Esta función todavía no está disponible.'),
        findsOneWidget,
      );
      expect(find.text('Estado: Confirmada'), findsOneWidget);
    });

    testWidgets('409 dice que la visita ya no permite la acción', (
      tester,
    ) async {
      await _montar(
        tester,
        VisitasRepositoryDePrueba(
          fallaAcciones: const ReglaDeNegocioFailure('visit_state'),
        ),
        _visita,
      );
      await tester.tap(find.text('Responder a un nuevo horario'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rechazar'));
      await tester.pumpAndSettle();
      expect(find.text('La visita ya no permite esta acción.'), findsOneWidget);
    });

    testWidgets('visita inexistente muestra no encontrada', (tester) async {
      await _montar(
        tester,
        VisitasRepositoryDePrueba(),
        const VisitaScreen(visitaId: 'zzz'),
      );
      expect(find.text('No encontramos lo que buscabas.'), findsOneWidget);
    });
  });
}
