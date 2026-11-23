import 'package:app/core/errores/failure.dart';
import 'package:app/features/chat/chat_providers.dart';
import 'package:app/features/chat/data/chat_de_prueba.dart';
import 'package:app/features/chat/data/chat_mapper.dart';
import 'package:app/features/chat/domain/chat.dart';
import 'package:app/features/chat/domain/chat_hub.dart';
import 'package:app/features/chat/presentation/chat_screen.dart';
import 'package:app/features/chat/presentation/conversaciones_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _montar(
  WidgetTester tester,
  ConversacionesRepositoryDePrueba repo, {
  required Widget home,
  ChatHubDePrueba? hub,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        conversacionesRepositoryProvider.overrideWithValue(repo),
        if (hub != null) chatHubProvider.overrideWithValue(hub),
      ],
      child: MaterialApp(home: home),
    ),
  );
  await tester.pumpAndSettle();
}

const _chat = ChatScreen(conversacionId: 'c1');

Conversacion _cerrada() => const Conversacion(
  conversacionId: 'c1',
  solicitudId: 's1',
  rol: 'cliente',
  contraparte: ContraparteChat(nombre: 'Luis Prueba'),
  servicio: 'Plomería',
  estado: 'cerrada',
  motivoCierre: 'visita_terminada',
  contactoVisible: false,
  noLeidos: 0,
);

Mensaje _mensaje(int n) => Mensaje(
  mensajeId: 'p$n',
  autorRol: 'tecnico',
  texto: 'Mensaje $n',
  contactoOculto: false,
  enviadoEn: DateTime.utc(2026, 11, 20, 10, n % 60),
);

void main() {
  group('ChatMapper', () {
    test('lee conversación, mensajes y eventos del hub', () {
      final c = ChatMapper.conversacion({
        'conversacionId': 'c1',
        'solicitudId': 's1',
        'rol': 'tecnico',
        'contraparte': {'nombre': 'Ana', 'fotoUrl': null},
        'servicio': 'Electricidad',
        'estado': 'abierta',
        'contactoVisible': false,
        'avisoSeguridad': true,
        'noLeidos': 2,
      });
      expect(c.cerrada, isFalse);
      expect(c.avisoSeguridad, isNotNull);
      expect(c.visitaId, isNull);

      final e = ChatMapper.evento('noLeidos', {
        'conversacionId': 'c1',
        'noLeidos': 3,
        'total': 5,
      });
      expect(e, isA<NoLeidosActualizados>());
      expect((e! as NoLeidosActualizados).total, 5);

      final m = ChatMapper.evento('mensajeConversacion', {
        'conversacionId': 'c1',
        'mensajeId': 'm9',
        'autorRol': 'cliente',
        'texto': 'Hola',
        'contactoOculto': true,
        'enviadoEn': '2026-11-20T10:00:00Z',
      });
      expect(
        (m! as MensajeConversacionRecibido).mensaje.contactoOculto,
        isTrue,
      );
      expect(ChatMapper.evento('otro', <String, Object?>{}), isNull);
    });

    test('un mensaje sin texto es DatosInvalidosFailure', () {
      expect(
        () => ChatMapper.mensaje({'mensajeId': '1'}),
        throwsA(isA<DatosInvalidosFailure>()),
      );
    });
  });

  group('validarTextoMensaje', () {
    test('quita espacios y rechaza vacío', () {
      expect(validarTextoMensaje('  hola '), 'hola');
      expect(() => validarTextoMensaje('  '), throwsA(isA<Failure>()));
    });

    test('acepta 1000 caracteres y rechaza 1001', () {
      expect(validarTextoMensaje('a' * 1000), isNotEmpty);
      expect(() => validarTextoMensaje('a' * 1001), throwsA(isA<Failure>()));
    });

    test('también cuenta el tope de 4096 bytes', () {
      // 1000 caracteres de 3 bytes = 3000 bytes: caben.
      expect(validarTextoMensaje('€' * 1000), isNotEmpty);
      // Cada emoji ocupa 2 unidades UTF-16: 501 superan los 1000 caracteres.
      expect(() => validarTextoMensaje('😀' * 501), throwsA(isA<Failure>()));
    });

    test('rechaza caracteres de control salvo el salto de línea', () {
      expect(validarTextoMensaje('hola\nmundo'), 'hola\nmundo');
      expect(() => validarTextoMensaje('ho\u0000la'), throwsA(isA<Failure>()));
      expect(() => validarTextoMensaje('ho\tla'), throwsA(isA<Failure>()));
    });
  });

  group('ConversacionesScreen', () {
    testWidgets('lista con contador de no leídos', (tester) async {
      await _montar(
        tester,
        ConversacionesRepositoryDePrueba(),
        home: const ConversacionesScreen(),
      );
      expect(find.text('Luis Prueba'), findsOneWidget);
      expect(find.text('1 mensaje sin leer'), findsOneWidget);
      expect(find.byType(Badge), findsOneWidget);
    });

    testWidgets('vacío', (tester) async {
      await _montar(
        tester,
        ConversacionesRepositoryDePrueba(conversaciones: const []),
        home: const ConversacionesScreen(),
      );
      expect(find.text('Todavía no tienes conversaciones'), findsOneWidget);
    });

    testWidgets('error 503 con Reintentar', (tester) async {
      await _montar(
        tester,
        ConversacionesRepositoryDePrueba(
          falla: const ServicioNoDisponibleFailure(),
        ),
        home: const ConversacionesScreen(),
      );
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('el evento noLeidos del hub actualiza el contador', (
      tester,
    ) async {
      final hub = ChatHubDePrueba();
      addTearDown(hub.desconectar);
      await _montar(
        tester,
        ConversacionesRepositoryDePrueba(),
        home: const ConversacionesScreen(),
        hub: hub,
      );
      hub.emitir(
        const NoLeidosActualizados(conversacionId: 'c1', noLeidos: 4, total: 4),
      );
      await tester.pumpAndSettle();
      expect(find.text('4 mensajes sin leer'), findsOneWidget);
    });
  });

  group('ChatScreen', () {
    testWidgets('muestra el historial, une el hub y marca leído', (
      tester,
    ) async {
      final hub = ChatHubDePrueba();
      addTearDown(hub.desconectar);
      final repo = ConversacionesRepositoryDePrueba();
      await _montar(tester, repo, home: _chat, hub: hub);
      expect(find.text('Hola, tengo una fuga en la cocina.'), findsOneWidget);
      expect(find.text('Puedo ir mañana a las 10.'), findsOneWidget);
      expect(hub.unidas, ['c1']);
      expect(repo.marcadosLeidos, [DateTime.utc(2026, 11, 21, 18, 5)]);
    });

    testWidgets('enviar agrega el mensaje y limpia el campo', (tester) async {
      await _montar(tester, ConversacionesRepositoryDePrueba(), home: _chat);
      await tester.enterText(find.byType(TextField), 'Gracias');
      await tester.pump();
      await tester.tap(find.byTooltip('Enviar'));
      await tester.pumpAndSettle();
      expect(find.text('Gracias'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
    });

    testWidgets('un mensaje del hub aparece una sola vez', (tester) async {
      final hub = ChatHubDePrueba();
      addTearDown(hub.desconectar);
      await _montar(
        tester,
        ConversacionesRepositoryDePrueba(),
        home: _chat,
        hub: hub,
      );
      final nuevo = _mensaje(7);
      final evento = MensajeConversacionRecibido(
        conversacionId: 'c1',
        mensaje: nuevo,
      );
      hub.emitir(evento);
      hub.emitir(evento);
      await tester.pumpAndSettle();
      expect(find.text('Mensaje 7'), findsOneWidget);
    });

    for (final caso in <(String, Failure, String)>[
      (
        'content_rejected',
        const ReglaDeNegocioFailure('content_rejected'),
        mensajesDeErrorChat['content_rejected']!,
      ),
      (
        'message_limit',
        const LimiteDePeticionesFailure(codigo: 'message_limit'),
        mensajesDeErrorChat['message_limit']!,
      ),
      (
        'conversation_closed',
        const ReglaDeNegocioFailure('conversation_closed'),
        mensajesDeErrorChat['conversation_closed']!,
      ),
      (
        'moderation_unavailable',
        const ServicioNoDisponibleFailure(codigo: 'moderation_unavailable'),
        mensajesDeErrorChat['moderation_unavailable']!,
      ),
      (
        'market_unavailable',
        const ServicioNoDisponibleFailure(codigo: 'market_unavailable'),
        mensajesDeErrorChat['market_unavailable']!,
      ),
    ]) {
      testWidgets('el error ${caso.$1} se explica bajo el mensaje fallido', (
        tester,
      ) async {
        await _montar(
          tester,
          ConversacionesRepositoryDePrueba(fallaAlEnviar: caso.$2),
          home: _chat,
        );
        await tester.enterText(find.byType(TextField), 'Hola de nuevo');
        await tester.pump();
        await tester.tap(find.byTooltip('Enviar'));
        await tester.pumpAndSettle();
        expect(find.textContaining(caso.$3), findsWidgets);
        expect(find.text('Hola de nuevo'), findsOneWidget);
        expect(find.textContaining('No se envió'), findsOneWidget);
      });
    }

    testWidgets('conversación cerrada: sin campo de texto', (tester) async {
      await _montar(
        tester,
        ConversacionesRepositoryDePrueba(conversaciones: [_cerrada()]),
        home: _chat,
      );
      expect(find.byType(TextField), findsNothing);
      expect(find.text('Esta conversación ya está cerrada.'), findsOneWidget);
    });

    testWidgets('404 al abrir una conversación ajena', (tester) async {
      await _montar(
        tester,
        ConversacionesRepositoryDePrueba(conversaciones: const []),
        home: _chat,
      );
      expect(find.text('No encontramos lo que buscabas.'), findsOneWidget);
    });

    testWidgets('carga mensajes anteriores con el cursor al llegar arriba', (
      tester,
    ) async {
      final repo = ConversacionesRepositoryDePrueba(
        mensajes: {
          'c1': [for (var i = 40; i >= 1; i--) _mensaje(i)],
        },
      );
      await _montar(tester, repo, home: _chat);
      expect(find.text('Mensaje 1'), findsNothing);
      await tester.scrollUntilVisible(
        find.text('Mensaje 1'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Mensaje 1'), findsOneWidget);
      expect(find.text('Cargar mensajes anteriores'), findsNothing);
    });
  });
}
