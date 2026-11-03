import 'package:app/app.dart';
import 'package:app/core/red/cliente_api_provider.dart';
import 'package:app/core/red/configuracion_api.dart';
import 'package:app/core/red/simulada/cliente_api_simulado.dart';
import 'package:app/core/router/app_router.dart';
import 'package:app/core/router/rutas.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// La app completa sin sobreescribir el repositorio de oficios: solo, si se
/// pide, el escenario de la API simulada (spec §8 D12).
Future<ProviderContainer> _montar(
  WidgetTester tester, {
  String? escenario,
}) async {
  final contenedor = ProviderContainer(
    overrides: [
      if (escenario != null)
        configuracionApiProvider.overrideWithValue(
          ConfiguracionApi.desde(
            url: '',
            escenario: escenario,
            esRelease: false,
          ),
        ),
    ],
  );
  addTearDown(contenedor.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: contenedor, child: const KnockApp()),
  );
  await tester.pumpAndSettle();
  return contenedor;
}

/// Monta la app y navega a la pantalla de oficios, ya asentada.
Future<ProviderContainer> _abrirOficios(
  WidgetTester tester, {
  String? escenario,
}) async {
  final contenedor = await _montar(tester, escenario: escenario);
  contenedor.read(appRouterProvider).go(Rutas.oficios);
  await tester.pumpAndSettle();
  return contenedor;
}

void main() {
  testWidgets(
    'TC-TT-MOB-08-09 la pantalla de oficios corre contra la API simulada',
    (tester) async {
      final contenedor = await _abrirOficios(tester);

      // Proveedores por defecto: modo simulado, escenario normal.
      expect(contenedor.read(configuracionApiProvider).modo, ModoApi.simulado);
      expect(contenedor.read(clienteApiProvider), isA<ClienteApiSimulado>());
      expect(find.text('Electricidad'), findsOneWidget);
      expect(find.text('Mecánica'), findsOneWidget);
      expect(find.text('Plomería'), findsOneWidget);
    },
  );

  testWidgets(
    'TC-TT-MOB-08-09 con error_servidor se ve el error y Reintentar trae la lista',
    (tester) async {
      final contenedor = await _abrirOficios(
        tester,
        escenario: 'error_servidor',
      );

      expect(find.text('No pudimos cargar los oficios'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
      expect(find.text('Electricidad'), findsNothing);

      (contenedor.read(clienteApiProvider) as ClienteApiSimulado).escenario =
          EscenarioApi.normal;
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();

      expect(find.text('No pudimos cargar los oficios'), findsNothing);
      expect(find.text('Electricidad'), findsOneWidget);
      expect(find.text('Plomería'), findsOneWidget);
    },
  );

  testWidgets('TC-TT-MOB-08-09 con vacio se ve el estado vacío', (
    tester,
  ) async {
    await _abrirOficios(tester, escenario: 'vacio');

    expect(find.text('Todavía no hay oficios disponibles'), findsOneWidget);
    expect(find.text('Electricidad'), findsNothing);
  });

  testWidgets('TC-TT-MOB-08-09 con lento se ve la carga y luego la lista', (
    tester,
  ) async {
    final contenedor = await _montar(tester, escenario: 'lento');
    contenedor.read(appRouterProvider).go(Rutas.oficios);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.bySemanticsLabel('Cargando oficios'), findsOneWidget);
    expect(find.text('Electricidad'), findsNothing);

    await tester.pump(ClienteApiSimulado.demoraLenta);
    await tester.pumpAndSettle();
    expect(find.text('Electricidad'), findsOneWidget);
  });
}
