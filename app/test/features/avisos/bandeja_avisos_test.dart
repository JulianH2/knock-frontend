import 'dart:async';

import 'package:app/core/errores/failure.dart';
import 'package:app/features/avisos/avisos_providers.dart';
import 'package:app/features/avisos/data/avisos_repository_de_prueba.dart';
import 'package:app/features/avisos/domain/aviso.dart';
import 'package:app/features/avisos/domain/destino_aviso.dart';
import 'package:app/features/avisos/presentation/avisos_controller.dart';
import 'package:app/features/avisos/presentation/avisos_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

Aviso _aviso(
  int n, {
  bool leido = false,
  Map<String, Object?>? destino,
  String rol = 'cliente',
}) => Aviso(
  id: 'x$n',
  tipo: 'visita',
  comoRol: rol,
  titulo: 'Aviso $n',
  texto: 'Texto $n',
  leido: leido,
  destino: destino,
  creadoEn: DateTime.utc(2026, 11, 1, n % 24),
);

/// Repositorio que falla solo al marcar y deja controlar cuándo responde.
class _RepoControlado extends AvisosRepositoryDePrueba {
  _RepoControlado({super.avisos});

  Completer<void>? puerta;
  Failure? errorAlMarcar;
  Failure? errorAlListar;
  int listados = 0;

  @override
  Future<PaginaAvisos> listar({
    String? cursor,
    int limite = 20,
    FiltroAvisos filtro = const FiltroAvisos(),
  }) {
    listados++;
    final error = errorAlListar;
    if (error != null && listados > 1) {
      return Future.error(error);
    }
    return super.listar(cursor: cursor, limite: limite, filtro: filtro);
  }

  @override
  Future<void> marcarLeido(String id) async {
    await puerta?.future;
    if (errorAlMarcar != null) {
      throw errorAlMarcar!;
    }
    return super.marcarLeido(id);
  }

  @override
  Future<void> marcarTodosLeidos() async {
    await puerta?.future;
    if (errorAlMarcar != null) {
      throw errorAlMarcar!;
    }
    return super.marcarTodosLeidos();
  }
}

Future<ProviderContainer> _montar(
  WidgetTester tester,
  AvisosRepositoryDePrueba repo, {
  Widget? home,
  GoRouter? router,
}) async {
  final contenedor = ProviderContainer(
    overrides: [avisosRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(contenedor.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: contenedor,
      child: router != null
          ? MaterialApp.router(routerConfig: router)
          : MaterialApp(home: home ?? const AvisosScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return contenedor;
}

void main() {
  group('DestinoAviso', () {
    test('resuelve visita y conversación a rutas de la app', () {
      expect(
        DestinoAviso.ruta({'tipo': 'visita', 'id': 'v-1'}),
        '/actividad/agenda/v-1',
      );
      expect(
        DestinoAviso.ruta({'recurso': 'conversacion', 'id': 'c_2'}),
        '/actividad/chats/c_2',
      );
    });

    test('un destino desconocido, vacío o con id peligroso da null', () {
      expect(DestinoAviso.ruta(null), isNull);
      expect(DestinoAviso.ruta({'tipo': 'otra', 'id': '1'}), isNull);
      expect(DestinoAviso.ruta({'tipo': 'visita'}), isNull);
      expect(DestinoAviso.ruta({'tipo': 'visita', 'id': 7}), isNull);
      expect(DestinoAviso.ruta({'tipo': 'visita', 'id': '../x'}), isNull);
      expect(DestinoAviso.ruta({'tipo': 'visita', 'id': 'a/b'}), isNull);
    });
  });

  group('marcar leído (optimista)', () {
    testWidgets('el contador baja al tocar y se confirma con la API', (
      tester,
    ) async {
      final repo = _RepoControlado(avisos: [_aviso(1), _aviso(2)]);
      final c = await _montar(tester, repo);
      expect(c.read(contadorAvisosProvider).value?.cantidad, 2);

      repo.puerta = Completer<void>();
      await tester.tap(find.text('Aviso 1'));
      await tester.pump();
      // Antes de que responda la API ya se ve leído y el contador bajó.
      expect(find.byIcon(Icons.notifications_none), findsOneWidget);
      expect(c.read(contadorAvisosProvider).value?.cantidad, 1);

      repo.puerta!.complete();
      await tester.pumpAndSettle();
      expect(c.read(contadorAvisosProvider).value?.cantidad, 1);
    });

    testWidgets('si la API falla se deshace el aviso y el contador', (
      tester,
    ) async {
      final repo = _RepoControlado(avisos: [_aviso(1)])
        ..errorAlMarcar = const ServicioNoDisponibleFailure();
      final c = await _montar(tester, repo);
      await tester.tap(find.text('Aviso 1'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.notifications_active), findsOneWidget);
      expect(c.read(contadorAvisosProvider).value?.cantidad, 1);
      expect(
        find.text(
          'El servicio no está disponible por ahora. Intenta más tarde.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('un 404 de aviso se deshace con el texto de no encontrado', (
      tester,
    ) async {
      final repo = _RepoControlado(avisos: [_aviso(1)])
        ..errorAlMarcar = const NoEncontradoFailure();
      await _montar(tester, repo);
      await tester.tap(find.text('Aviso 1'));
      await tester.pumpAndSettle();
      expect(find.text('No encontramos lo que buscabas.'), findsOneWidget);
    });

    testWidgets('con 99+ el contador se mantiene hasta recargar', (
      tester,
    ) async {
      final repo = _RepoControlado(
        avisos: [for (var i = 0; i < 120; i++) _aviso(i)],
      );
      final c = await _montar(tester, repo);
      expect(c.read(contadorAvisosProvider).value?.etiqueta, '99+');
      await tester.tap(find.text('Aviso 0'));
      await tester.pumpAndSettle();
      // Hay 119 no leídos: sigue siendo 99+.
      expect(c.read(contadorAvisosProvider).value?.etiqueta, '99+');
    });
  });

  group('marcar todos', () {
    testWidgets('pide confirmación y Cancelar no cambia nada', (tester) async {
      final repo = _RepoControlado(avisos: [_aviso(1), _aviso(2)]);
      final c = await _montar(tester, repo);
      await tester.tap(find.byTooltip('Marcar todos como leídos'));
      await tester.pumpAndSettle();
      expect(find.text('Todos tus avisos quedarán como leídos.'), findsOne);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.notifications_active), findsNWidgets(2));
      expect(c.read(contadorAvisosProvider).value?.cantidad, 2);
    });

    testWidgets('confirmar pone el contador en cero', (tester) async {
      final repo = _RepoControlado(avisos: [_aviso(1), _aviso(2)]);
      final c = await _montar(tester, repo);
      await tester.tap(find.byTooltip('Marcar todos como leídos'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Marcar todos'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.notifications_active), findsNothing);
      expect(c.read(contadorAvisosProvider).value?.cantidad, 0);
    });

    testWidgets('si falla se deshace y avisa', (tester) async {
      final repo = _RepoControlado(avisos: [_aviso(1), _aviso(2)])
        ..errorAlMarcar = const LimiteDePeticionesFailure();
      final c = await _montar(tester, repo);
      await tester.tap(find.byTooltip('Marcar todos como leídos'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Marcar todos'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.notifications_active), findsNWidgets(2));
      expect(c.read(contadorAvisosProvider).value?.cantidad, 2);
      expect(
        find.text(
          'Hiciste muchas peticiones. Espera un momento e intenta de nuevo.',
        ),
        findsOneWidget,
      );
    });
  });

  group('destino del aviso', () {
    GoRouter enrutador(AvisosRepositoryDePrueba repo) => GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const AvisosScreen()),
        GoRoute(
          path: '/actividad/agenda/:id',
          builder: (_, e) =>
              Scaffold(body: Text('Visita ${e.pathParameters['id']}')),
        ),
      ],
    );

    testWidgets('abre la visita del destino y marca leído', (tester) async {
      final repo = AvisosRepositoryDePrueba(
        avisos: [
          _aviso(1, destino: {'tipo': 'visita', 'id': 'v9'}),
        ],
      );
      final c = await _montar(tester, repo, router: enrutador(repo));
      await tester.tap(find.text('Aviso 1'));
      await tester.pumpAndSettle();
      expect(find.text('Visita v9'), findsOneWidget);
      expect(
        c.read(avisosControllerProvider).value!.items.single.leido,
        isTrue,
      );
    });

    testWidgets('destino desconocido: marca leído y avisa sin navegar', (
      tester,
    ) async {
      final repo = AvisosRepositoryDePrueba(
        avisos: [
          _aviso(1, destino: {'tipo': 'futuro', 'id': '1'}),
        ],
      );
      await _montar(tester, repo, router: enrutador(repo));
      await tester.tap(find.text('Aviso 1'));
      await tester.pumpAndSettle();
      expect(find.text('No pudimos abrir lo que indica el aviso'), findsOne);
      expect(find.byIcon(Icons.notifications_none), findsOneWidget);
    });

    testWidgets('sin destino solo marca leído', (tester) async {
      final repo = AvisosRepositoryDePrueba(avisos: [_aviso(1)]);
      await _montar(tester, repo, router: enrutador(repo));
      await tester.tap(find.text('Aviso 1'));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
      expect(find.byIcon(Icons.notifications_none), findsOneWidget);
    });
  });

  group('estados de la bandeja', () {
    testWidgets('pull to refresh recarga la lista', (tester) async {
      final repo = _RepoControlado(avisos: [_aviso(1)]);
      await _montar(tester, repo);
      expect(repo.listados, 1);
      await tester.fling(find.text('Aviso 1'), const Offset(0, 400), 1000);
      await tester.pumpAndSettle();
      expect(repo.listados, 2);
    });

    testWidgets('si el refresh falla conserva la lista y avisa', (
      tester,
    ) async {
      final repo = _RepoControlado(avisos: [_aviso(1)])
        ..errorAlListar = const ServicioNoDisponibleFailure();
      await _montar(tester, repo);
      await tester.fling(find.text('Aviso 1'), const Offset(0, 400), 1000);
      await tester.pumpAndSettle();
      expect(find.text('Aviso 1'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('429 al cargar muestra el texto de límite y Reintentar', (
      tester,
    ) async {
      await _montar(
        tester,
        AvisosRepositoryDePrueba(falla: const LimiteDePeticionesFailure()),
      );
      expect(
        find.text(
          'Hiciste muchas peticiones. Espera un momento e intenta de nuevo.',
        ),
        findsOneWidget,
      );
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('vacío con filtro dice que no hay avisos con los filtros', (
      tester,
    ) async {
      await _montar(
        tester,
        AvisosRepositoryDePrueba(avisos: [_aviso(1, leido: true)]),
      );
      await tester.tap(find.text('No leídos'));
      await tester.pumpAndSettle();
      expect(find.text('No hay avisos con estos filtros'), findsOneWidget);
    });

    testWidgets('el filtro dura toda la sesión aunque se cierre la pantalla', (
      tester,
    ) async {
      final repo = AvisosRepositoryDePrueba(
        avisos: [_aviso(1), _aviso(2, leido: true)],
      );
      final c = await _montar(tester, repo);
      await tester.tap(find.text('Como técnico'));
      await tester.pumpAndSettle();
      expect(c.read(filtroAvisosProvider).comoRol, 'tecnico');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: const MaterialApp(home: SizedBox()),
        ),
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: const MaterialApp(home: AvisosScreen()),
        ),
      );
      await tester.pumpAndSettle();
      final chip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'Como técnico'),
      );
      expect(chip.selected, isTrue);
    });

    testWidgets('si falla cargar más conserva lo cargado y ofrece Reintentar', (
      tester,
    ) async {
      final repo = _RepoControlado(
        avisos: [for (var i = 0; i < 25; i++) _aviso(i)],
      )..errorAlListar = const ServicioNoDisponibleFailure();
      await _montar(tester, repo);
      await tester.scrollUntilVisible(
        find.text('No pudimos cargar más avisos'),
        300,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      expect(find.text('Reintentar'), findsOneWidget);
      expect(
        find.text('Aviso 0'),
        findsNothing,
      ); // sigue la lista, fuera de vista
      final llamadas = repo.listados;
      // No insiste solo: sin tocar Reintentar no hay más llamadas.
      await tester.pump(const Duration(seconds: 30));
      expect(repo.listados, llamadas);
    });
  });

  group('InsigniaAvisos', () {
    testWidgets('muestra el número y 99+ si masDe99', (tester) async {
      final repo = AvisosRepositoryDePrueba(
        avisos: [for (var i = 0; i < 120; i++) _aviso(i)],
      );
      await _montar(
        tester,
        repo,
        home: const Scaffold(
          body: InsigniaAvisos(hijo: Icon(Icons.notifications)),
        ),
      );
      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('sin no leídos no hay insignia', (tester) async {
      await _montar(
        tester,
        AvisosRepositoryDePrueba(avisos: [_aviso(1, leido: true)]),
        home: const Scaffold(
          body: InsigniaAvisos(hijo: Icon(Icons.notifications)),
        ),
      );
      expect(find.byType(Badge), findsNothing);
    });
  });
}
