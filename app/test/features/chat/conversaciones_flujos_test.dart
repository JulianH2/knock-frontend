import 'package:app/core/errores/failure.dart';
import 'package:app/features/chat/chat_providers.dart';
import 'package:app/features/chat/data/chat_de_prueba.dart';
import 'package:app/features/chat/domain/chat.dart';
import 'package:app/features/chat/domain/chat_hub.dart';
import 'package:app/features/chat/presentation/abrir_conversacion.dart';
import 'package:app/features/chat/presentation/conversaciones_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

Future<void> _montar(
  WidgetTester tester,
  ConversacionesRepositoryDePrueba repo, {
  ChatHubDePrueba? hub,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        conversacionesRepositoryProvider.overrideWithValue(repo),
        if (hub != null) chatHubProvider.overrideWithValue(hub),
      ],
      child: const MaterialApp(home: ConversacionesScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

/// Repositorio que lista bien la primera vez y falla después.
class _RepoQueFallaAlRefrescar extends ConversacionesRepositoryDePrueba {
  bool romper = false;

  @override
  Future<PaginaConversaciones> listar({String? cursor, int limite = 20}) {
    if (romper) {
      throw const ServicioNoDisponibleFailure();
    }
    return super.listar(cursor: cursor, limite: limite);
  }
}

void main() {
  group('lista de conversaciones', () {
    testWidgets('pull-to-refresh trae las conversaciones nuevas', (
      tester,
    ) async {
      final repo = ConversacionesRepositoryDePrueba();
      await _montar(tester, repo);
      expect(find.text('Contraparte de prueba'), findsNothing);
      await repo.crear(solicitudId: 's9', tecnicoId: 't1');
      await tester.fling(find.byType(ListView), const Offset(0, 400), 1000);
      await tester.pumpAndSettle();
      expect(find.text('Contraparte de prueba'), findsOneWidget);
      expect(find.text('Luis Prueba'), findsOneWidget);
    });

    testWidgets('pull-to-refresh en el estado vacío', (tester) async {
      final repo = ConversacionesRepositoryDePrueba(conversaciones: const []);
      await _montar(tester, repo);
      expect(find.text('Todavía no tienes conversaciones'), findsOneWidget);
      await repo.crear(solicitudId: 's9', tecnicoId: 't1');
      await tester.fling(find.byType(ListView), const Offset(0, 400), 1000);
      await tester.pumpAndSettle();
      expect(find.text('Contraparte de prueba'), findsOneWidget);
    });

    testWidgets('si el refresco falla conserva la lista y avisa', (
      tester,
    ) async {
      final repo = _RepoQueFallaAlRefrescar();
      await _montar(tester, repo);
      repo.romper = true;
      await tester.fling(find.byType(ListView), const Offset(0, 400), 1000);
      await tester.pumpAndSettle();
      expect(find.text('Luis Prueba'), findsOneWidget);
      expect(
        find.text('No pudimos actualizar. Intenta de nuevo.'),
        findsOneWidget,
      );
    });

    testWidgets('mensajeConversacion sube la conversación y su texto', (
      tester,
    ) async {
      final hub = ChatHubDePrueba();
      addTearDown(hub.desconectar);
      await _montar(tester, ConversacionesRepositoryDePrueba(), hub: hub);
      hub.emitir(
        MensajeConversacionRecibido(
          conversacionId: 'c1',
          mensaje: Mensaje(
            mensajeId: 'z',
            autorRol: 'tecnico',
            texto: 'Llegando en 5 minutos',
            contactoOculto: false,
            enviadoEn: DateTime.utc(2026, 11, 22),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Llegando en 5 minutos'), findsOneWidget);
    });

    testWidgets('al reconectar el hub se corrige el contador perdido', (
      tester,
    ) async {
      final hub = ChatHubDePrueba();
      addTearDown(hub.desconectar);
      final repo = ConversacionesRepositoryDePrueba();
      await _montar(tester, repo, hub: hub);
      expect(find.text('1 mensaje sin leer'), findsOneWidget);
      await repo.crear(solicitudId: 's9', tecnicoId: 't1');
      hub.emitir(const ConexionRestablecida());
      await tester.pumpAndSettle();
      expect(find.text('Contraparte de prueba'), findsOneWidget);
    });

    testWidgets('conversación cerrada y contraparte sin teléfono', (
      tester,
    ) async {
      await _montar(
        tester,
        ConversacionesRepositoryDePrueba(
          conversaciones: const [
            Conversacion(
              conversacionId: 'c2',
              solicitudId: 's2',
              rol: 'tecnico',
              contraparte: ContraparteChat(nombre: 'Ana'),
              servicio: 'Gas',
              estado: 'cerrada',
              motivoCierre: 'visita_terminada',
              contactoVisible: false,
              noLeidos: 0,
            ),
          ],
          mensajes: const {},
        ),
      );
      expect(find.text('Ana'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(find.textContaining('Cerrada'), findsOneWidget);
      expect(find.textContaining(RegExp(r'\d{10}')), findsNothing);
    });

    testWidgets('404 de ruta dice que la función aún no está disponible', (
      tester,
    ) async {
      await _montar(
        tester,
        ConversacionesRepositoryDePrueba(
          falla: const RutaNoDisponibleFailure(),
        ),
      );
      expect(
        find.text('Esta función todavía no está disponible.'),
        findsOneWidget,
      );
    });
  });

  group('abrir conversación desde solicitud y técnico', () {
    Future<void> montarConRuta(
      WidgetTester tester,
      ConversacionesRepositoryDePrueba repo,
    ) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const Scaffold(
              body: BotonAbrirChat(solicitudId: 's9', tecnicoId: 't1'),
            ),
          ),
          GoRoute(
            path: '/actividad/chats/:id',
            builder: (_, s) =>
                Scaffold(body: Text('chat ${s.pathParameters['id']}')),
          ),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [conversacionesRepositoryProvider.overrideWithValue(repo)],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('201 crea y navega al chat', (tester) async {
      final repo = ConversacionesRepositoryDePrueba();
      await montarConRuta(tester, repo);
      await tester.tap(find.text('Enviar mensaje'));
      await tester.pumpAndSettle();
      expect(find.text('chat c1000'), findsOneWidget);
    });

    testWidgets('200 abre la conversación que ya existía', (tester) async {
      final repo = ConversacionesRepositoryDePrueba();
      await repo.crear(solicitudId: 's9', tecnicoId: 't1');
      await montarConRuta(tester, repo);
      await tester.tap(find.text('Enviar mensaje'));
      await tester.pumpAndSettle();
      expect(find.text('chat c1000'), findsOneWidget);
    });

    testWidgets('409 conversation_closed explica y no navega', (tester) async {
      final repo = ConversacionesRepositoryDePrueba()
        ..fallaAlCrear = const ReglaDeNegocioFailure('conversation_closed');
      await montarConRuta(tester, repo);
      await tester.tap(find.text('Enviar mensaje'));
      await tester.pumpAndSettle();
      expect(find.text('Esta conversación ya está cerrada.'), findsOneWidget);
      expect(find.text('Enviar mensaje'), findsOneWidget);
    });

    testWidgets('503 se explica y el botón queda disponible', (tester) async {
      final repo = ConversacionesRepositoryDePrueba()
        ..fallaAlCrear = const ServicioNoDisponibleFailure();
      await montarConRuta(tester, repo);
      await tester.tap(find.text('Enviar mensaje'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'El servicio no está disponible por ahora. Intenta más tarde.',
        ),
        findsOneWidget,
      );
      expect(
        tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
        isNotNull,
      );
    });
  });
}
