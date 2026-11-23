import 'package:app/core/errores/failure.dart';
import 'package:app/features/avisos/avisos_providers.dart';
import 'package:app/features/avisos/data/avisos_mapper.dart';
import 'package:app/features/avisos/data/avisos_repository_de_prueba.dart';
import 'package:app/features/avisos/domain/aviso.dart';
import 'package:app/features/avisos/presentation/avisos_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Aviso _aviso(int n, {bool leido = false, String rol = 'cliente'}) => Aviso(
  id: 'x$n',
  tipo: 'visita',
  comoRol: rol,
  titulo: 'Aviso $n',
  texto: 'Texto $n',
  leido: leido,
  creadoEn: DateTime.utc(2026, 11, 1, n % 24),
);

Future<void> _montar(
  WidgetTester tester,
  AvisosRepositoryDePrueba repo, {
  Widget home = const AvisosScreen(),
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [avisosRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(home: home),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('AvisosMapper', () {
    test('lee la página, el contador y las preferencias del contrato', () {
      final pagina = AvisosMapper.pagina({
        'items': [
          {
            'id': '1',
            'tipo': 'visita',
            'comoRol': 'tecnico',
            'titulo': 'T',
            'texto': 'X',
            'destino': null,
            'leido': false,
            'creadoEn': '2026-11-20T10:00:00Z',
          },
        ],
        'siguienteCursor': 'abc',
      });
      expect(pagina.items.single.comoRol, 'tecnico');
      expect(pagina.siguienteCursor, 'abc');

      final contador = AvisosMapper.contador({
        'cantidad': '99',
        'masDe99': true,
      });
      expect(contador.etiqueta, '99+');

      final prefs = AvisosMapper.preferencias({
        'tipos': [
          {'tipo': 'seguridad', 'activo': false, 'apagable': false},
        ],
      });
      expect(prefs.single.activo, isTrue, reason: 'seguridad siempre activa');
    });

    test('un campo ausente es DatosInvalidosFailure', () {
      expect(
        () => AvisosMapper.aviso({'id': '1'}),
        throwsA(isA<DatosInvalidosFailure>()),
      );
    });
  });

  group('contador', () {
    test('muestra el número, y 99+ solo con masDe99', () {
      expect(const ContadorAvisos(cantidad: 7, masDe99: false).etiqueta, '7');
      expect(const ContadorAvisos(cantidad: 99, masDe99: true).etiqueta, '99+');
      expect(
        const ContadorAvisos(cantidad: 0, masDe99: false).hayNoLeidos,
        isFalse,
      );
    });

    test('el repositorio de prueba topa en 99', () async {
      final repo = AvisosRepositoryDePrueba(
        avisos: [for (var i = 0; i < 120; i++) _aviso(i)],
      );
      final c = await repo.contador();
      expect(c.cantidad, 99);
      expect(c.masDe99, isTrue);
    });
  });

  group('AvisosScreen', () {
    testWidgets('lista los avisos y marca uno como leído al tocarlo', (
      tester,
    ) async {
      await _montar(tester, AvisosRepositoryDePrueba(avisos: [_aviso(1)]));
      expect(find.text('Aviso 1'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_active), findsOneWidget);

      await tester.tap(find.text('Aviso 1'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.notifications_none), findsOneWidget);
    });

    testWidgets('marcar todos como leídos', (tester) async {
      await _montar(
        tester,
        AvisosRepositoryDePrueba(avisos: [_aviso(1), _aviso(2)]),
      );
      await tester.tap(find.byTooltip('Marcar todos como leídos'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Marcar todos'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.notifications_active), findsNothing);
      expect(find.byIcon(Icons.notifications_none), findsNWidgets(2));
    });

    testWidgets('estado vacío', (tester) async {
      await _montar(tester, AvisosRepositoryDePrueba(avisos: const []));
      expect(find.text('No tienes avisos'), findsOneWidget);
    });

    testWidgets('error 503 con Reintentar', (tester) async {
      await _montar(
        tester,
        AvisosRepositoryDePrueba(falla: const ServicioNoDisponibleFailure()),
      );
      expect(
        find.text(
          'El servicio no está disponible por ahora. Intenta más tarde.',
        ),
        findsOneWidget,
      );
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('carga la página siguiente con el cursor al desplazar', (
      tester,
    ) async {
      await _montar(
        tester,
        AvisosRepositoryDePrueba(
          avisos: [for (var i = 0; i < 25; i++) _aviso(i)],
        ),
      );
      expect(find.text('Aviso 24'), findsNothing);
      await tester.scrollUntilVisible(
        find.text('Aviso 24'),
        300,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      expect(find.text('Aviso 24'), findsOneWidget);
    });

    testWidgets('el filtro «No leídos» pide solo los no leídos', (
      tester,
    ) async {
      await _montar(
        tester,
        AvisosRepositoryDePrueba(avisos: [_aviso(1), _aviso(2, leido: true)]),
      );
      expect(find.text('Aviso 2'), findsOneWidget);
      await tester.tap(find.text('No leídos'));
      await tester.pumpAndSettle();
      expect(find.text('Aviso 2'), findsNothing);
      expect(find.text('Aviso 1'), findsOneWidget);
    });
  });
}
