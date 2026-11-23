import 'dart:async';

import 'package:app/core/errores/failure.dart';
import 'package:app/features/chat/chat_providers.dart';
import 'package:app/features/chat/data/chat_de_prueba.dart';
import 'package:app/features/chat/domain/chat.dart';
import 'package:app/features/chat/domain/chat_hub.dart';
import 'package:app/features/chat/presentation/chat_controller.dart';
import 'package:app/features/chat/presentation/chat_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
      child: const MaterialApp(home: ChatScreen(conversacionId: 'c1')),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _escribirYEnviar(WidgetTester tester, String texto) async {
  await tester.enterText(find.byType(TextField), texto);
  await tester.pump();
  await tester.tap(find.byTooltip('Enviar'));
  await tester.pump();
}

bool _botonEnviarActivo(WidgetTester tester) =>
    tester.widget<IconButton>(find.byType(IconButton)).onPressed != null;

Mensaje _deLaOtraPersona(String id, DateTime cuando) => Mensaje(
  mensajeId: id,
  autorRol: 'tecnico',
  texto: 'Texto $id',
  contactoOculto: false,
  enviadoEn: cuando,
);

ProviderContainer _contenedor(
  ConversacionesRepositoryDePrueba repo,
  ChatHub hub,
) {
  final c = ProviderContainer(
    overrides: [
      conversacionesRepositoryProvider.overrideWithValue(repo),
      chatHubProvider.overrideWithValue(hub),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  group('envío optimista', () {
    testWidgets('muestra «Enviando…», no permite doble envío y se confirma', (
      tester,
    ) async {
      final espera = Completer<void>();
      final repo = ConversacionesRepositoryDePrueba(
        esperaAlEnviar: espera.future,
      );
      await _montar(tester, repo);
      await _escribirYEnviar(tester, 'Voy en camino');

      expect(find.text('Enviando…'), findsOneWidget);
      expect(find.text('Voy en camino'), findsOneWidget);
      expect(_botonEnviarActivo(tester), isFalse);

      // Segundo intento mientras el primero sigue en el aire.
      await tester.enterText(find.byType(TextField), 'Otro');
      await tester.pump();
      expect(_botonEnviarActivo(tester), isFalse);
      expect(repo.enviosIntentados, 1);

      espera.complete();
      await tester.pumpAndSettle();
      expect(find.text('Enviando…'), findsNothing);
      expect(find.textContaining('Enviado'), findsWidgets);
      expect(find.text('Voy en camino'), findsOneWidget);
    });

    testWidgets('un fallo deja el mensaje con Reintentar y reenvía', (
      tester,
    ) async {
      final repo = ConversacionesRepositoryDePrueba(
        fallaAlEnviar: const ServicioNoDisponibleFailure(),
      );
      await _montar(tester, repo);
      await _escribirYEnviar(tester, 'Hola');
      await tester.pumpAndSettle();
      expect(find.textContaining('No se envió'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);

      repo.fallaAlEnviar = null;
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();
      expect(find.textContaining('No se envió'), findsNothing);
      expect(find.text('Hola'), findsOneWidget);
      expect(repo.enviosIntentados, 2);
    });

    testWidgets('Descartar quita el mensaje fallido', (tester) async {
      final repo = ConversacionesRepositoryDePrueba(
        fallaAlEnviar: const ServicioNoDisponibleFailure(),
      );
      await _montar(tester, repo);
      await _escribirYEnviar(tester, 'Hola');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Descartar'));
      await tester.pumpAndSettle();
      expect(find.text('Hola'), findsNothing);
    });

    testWidgets('content_rejected no ofrece Reintentar', (tester) async {
      final repo = ConversacionesRepositoryDePrueba(
        fallaAlEnviar: const ReglaDeNegocioFailure('content_rejected'),
      );
      await _montar(tester, repo);
      await _escribirYEnviar(tester, 'Mensaje raro');
      await tester.pumpAndSettle();
      expect(find.text('Reintentar'), findsNothing);
      expect(find.text('Descartar'), findsOneWidget);
    });

    testWidgets(
      'message_limit con espera: cuenta regresiva y luego reintento',
      (tester) async {
        final repo = ConversacionesRepositoryDePrueba(
          fallaAlEnviar: const LimiteDePeticionesFailure(
            codigo: 'message_limit',
            reintentarEnSegundos: 3,
          ),
        );
        await _montar(tester, repo);
        await _escribirYEnviar(tester, 'Uno');
        await tester.pump();
        expect(
          find.textContaining('Podrás enviar otro en 3 s'),
          findsOneWidget,
        );
        expect(
          tester
              .widget<TextButton>(find.widgetWithText(TextButton, 'Reintentar'))
              .onPressed,
          isNull,
        );

        await tester.pump(const Duration(seconds: 1));
        expect(find.textContaining('en 2 s'), findsOneWidget);
        await tester.pump(const Duration(seconds: 2));
        expect(find.textContaining('Podrás enviar otro'), findsNothing);

        repo.fallaAlEnviar = null;
        await tester.tap(find.text('Reintentar'));
        await tester.pumpAndSettle();
        expect(find.textContaining('No se envió'), findsNothing);
      },
    );

    testWidgets('conversation_closed al enviar cierra la conversación', (
      tester,
    ) async {
      final repo = ConversacionesRepositoryDePrueba(
        fallaAlEnviar: const ReglaDeNegocioFailure('conversation_closed'),
      );
      await _montar(tester, repo);
      await _escribirYEnviar(tester, 'Hola');
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNothing);
    });
  });

  group('validación del texto', () {
    testWidgets('vacío o solo espacios no se puede enviar', (tester) async {
      await _montar(tester, ConversacionesRepositoryDePrueba());
      expect(_botonEnviarActivo(tester), isFalse);
      await tester.enterText(find.byType(TextField), '   ');
      await tester.pump();
      expect(_botonEnviarActivo(tester), isFalse);
    });

    testWidgets('más de 1000 caracteres muestra el error y bloquea el envío', (
      tester,
    ) async {
      final repo = ConversacionesRepositoryDePrueba();
      await _montar(tester, repo);
      await tester.enterText(find.byType(TextField), 'ñ' * 1001);
      await tester.pump();
      expect(find.textContaining('demasiado largo'), findsOneWidget);
      expect(_botonEnviarActivo(tester), isFalse);
      expect(repo.enviosIntentados, 0);

      await tester.enterText(find.byType(TextField), 'ñ' * 1000);
      await tester.pump();
      expect(find.textContaining('demasiado largo'), findsNothing);
      expect(_botonEnviarActivo(tester), isTrue);
    });

    testWidgets('recorta los espacios de los extremos al enviar', (
      tester,
    ) async {
      await _montar(tester, ConversacionesRepositoryDePrueba());
      await _escribirYEnviar(tester, '   hola   ');
      await tester.pumpAndSettle();
      expect(find.text('hola'), findsOneWidget);
    });
  });

  group('avisos de la pantalla', () {
    testWidgets(
      'el aviso de seguridad se ve siempre con el texto por omisión',
      (tester) async {
        await _montar(
          tester,
          ConversacionesRepositoryDePrueba(
            conversaciones: const [
              Conversacion(
                conversacionId: 'c1',
                solicitudId: 's1',
                rol: 'cliente',
                contraparte: ContraparteChat(nombre: 'Luis'),
                servicio: 'Plomería',
                estado: 'abierta',
                contactoVisible: false,
                noLeidos: 0,
              ),
            ],
          ),
        );
        expect(find.text(avisoSeguridadPorOmision), findsOneWidget);
        expect(find.textContaining('no pagues por adelantado'), findsOneWidget);
      },
    );

    testWidgets('contactoOculto se marca en el mensaje', (tester) async {
      await _montar(
        tester,
        ConversacionesRepositoryDePrueba(
          mensajes: {
            'c1': [
              Mensaje(
                mensajeId: 'x1',
                autorRol: 'tecnico',
                texto: 'Llámame al [oculto]',
                contactoOculto: true,
                enviadoEn: DateTime.utc(2026, 11, 21, 10),
              ),
            ],
          },
        ),
      );
      expect(find.text('Se ocultó un dato de contacto'), findsOneWidget);
    });

    testWidgets('sin mensajes: invita a escribir el primero', (tester) async {
      await _montar(
        tester,
        ConversacionesRepositoryDePrueba(mensajes: {'c1': []}),
      );
      expect(find.text('Escribe el primer mensaje'), findsOneWidget);
    });

    testWidgets('mensaje nuevo con el historial arriba: aviso para bajar', (
      tester,
    ) async {
      final hub = ChatHubDePrueba();
      addTearDown(hub.desconectar);
      final repo = ConversacionesRepositoryDePrueba(
        mensajes: {
          'c1': [
            for (var i = 40; i >= 1; i--)
              Mensaje(
                mensajeId: 'p$i',
                autorRol: 'tecnico',
                texto: 'Mensaje $i',
                contactoOculto: false,
                enviadoEn: DateTime.utc(2026, 11, 20, 10, i),
              ),
          ],
        },
      );
      await _montar(tester, repo, hub: hub);
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, 600));
      await tester.pumpAndSettle();

      hub.emitir(
        MensajeConversacionRecibido(
          conversacionId: 'c1',
          mensaje: _deLaOtraPersona('nuevo', DateTime.utc(2026, 11, 22)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Mensajes nuevos'), findsOneWidget);
      await tester.tap(find.text('Mensajes nuevos'));
      await tester.pumpAndSettle();
      expect(find.text('Mensajes nuevos'), findsNothing);
      expect(find.text('Texto nuevo'), findsOneWidget);
    });
  });

  group('marcar leído y mensajes del hub', () {
    test('hasta es el mensaje más reciente y no se repite', () async {
      final hub = ChatHubDePrueba();
      addTearDown(hub.desconectar);
      final repo = ConversacionesRepositoryDePrueba();
      final c = _contenedor(repo, hub);
      c.listen(chatControllerProvider('c1'), (_, _) {});
      await c.read(chatControllerProvider('c1').future);
      await Future<void>.delayed(Duration.zero);
      expect(repo.marcadosLeidos, [DateTime.utc(2026, 11, 21, 18, 5)]);

      // Un mensaje viejo fuera de orden no cambia `hasta` ni vuelve a marcar.
      hub.emitir(
        MensajeConversacionRecibido(
          conversacionId: 'c1',
          mensaje: _deLaOtraPersona('viejo', DateTime.utc(2026, 11, 21, 17)),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(repo.marcadosLeidos, hasLength(1));

      hub.emitir(
        MensajeConversacionRecibido(
          conversacionId: 'c1',
          mensaje: _deLaOtraPersona('nuevo', DateTime.utc(2026, 11, 21, 19)),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(repo.marcadosLeidos.last, DateTime.utc(2026, 11, 21, 19));
      final mensajes = c.read(chatControllerProvider('c1')).requireValue;
      expect(mensajes.mensajes.map((m) => m.mensajeId), [
        'nuevo',
        'm2',
        'm1',
        'viejo',
      ]);
    });

    test('en segundo plano no marca; al volver al primer plano sí', () async {
      final hub = ChatHubDePrueba();
      addTearDown(hub.desconectar);
      final repo = ConversacionesRepositoryDePrueba();
      final c = _contenedor(repo, hub);
      c.listen(chatControllerProvider('c1'), (_, _) {});
      final notificador = c.read(chatControllerProvider('c1').notifier)
        ..visible(valor: false);
      await c.read(chatControllerProvider('c1').future);
      await Future<void>.delayed(Duration.zero);
      expect(repo.marcadosLeidos, isEmpty);
      notificador.visible(valor: true);
      await Future<void>.delayed(Duration.zero);
      expect(repo.marcadosLeidos, hasLength(1));
    });

    test('el mensaje propio por REST y por hub no se duplica', () async {
      final hub = ChatHubDePrueba();
      addTearDown(hub.desconectar);
      final repo = ConversacionesRepositoryDePrueba();
      final c = _contenedor(repo, hub);
      c.listen(chatControllerProvider('c1'), (_, _) {});
      await c.read(chatControllerProvider('c1').future);
      final notificador = c.read(chatControllerProvider('c1').notifier);
      expect(notificador.enviar('Hola'), isTrue);
      await notificador.ultimoEnvio;
      final enviado = c
          .read(chatControllerProvider('c1'))
          .requireValue
          .mensajes
          .first;
      hub.emitir(
        MensajeConversacionRecibido(conversacionId: 'c1', mensaje: enviado),
      );
      await Future<void>.delayed(Duration.zero);
      final estado = c.read(chatControllerProvider('c1')).requireValue;
      expect(
        estado.mensajes.where((m) => m.mensajeId == enviado.mensajeId),
        hasLength(1),
      );
      expect(estado.pendientes, isEmpty);
    });

    test('un mensaje propio del hub durante el POST espera al POST', () async {
      final hub = ChatHubDePrueba();
      addTearDown(hub.desconectar);
      final espera = Completer<void>();
      final repo = ConversacionesRepositoryDePrueba(
        esperaAlEnviar: espera.future,
      );
      final c = _contenedor(repo, hub);
      c.listen(chatControllerProvider('c1'), (_, _) {});
      await c.read(chatControllerProvider('c1').future);
      final notificador = c.read(chatControllerProvider('c1').notifier);
      notificador.enviar('Hola');
      hub.emitir(
        MensajeConversacionRecibido(
          conversacionId: 'c1',
          mensaje: Mensaje(
            mensajeId: 'm1000',
            autorRol: 'cliente',
            texto: 'Hola',
            contactoOculto: false,
            enviadoEn: DateTime.utc(2026, 11, 22),
          ),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(
        c.read(chatControllerProvider('c1')).requireValue.mensajes,
        hasLength(2),
      );
      espera.complete();
      await notificador.ultimoEnvio;
      expect(
        c.read(chatControllerProvider('c1')).requireValue.mensajes,
        hasLength(3),
      );
    });

    test('al reconectar el hub se recuperan los mensajes perdidos', () async {
      final hub = ChatHubDePrueba();
      addTearDown(hub.desconectar);
      final repo = ConversacionesRepositoryDePrueba();
      final c = _contenedor(repo, hub);
      c.listen(chatControllerProvider('c1'), (_, _) {});
      await c.read(chatControllerProvider('c1').future);
      repo.llegaMensaje('c1', _deLaOtraPersona('perdido', DateTime.utc(2027)));
      hub.emitir(const ConexionRestablecida());
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(
        c
            .read(chatControllerProvider('c1'))
            .requireValue
            .mensajes
            .first
            .mensajeId,
        'perdido',
      );
    });

    test('enviar devuelve false con texto inválido y sin enviar', () async {
      final hub = ChatHubDePrueba();
      addTearDown(hub.desconectar);
      final repo = ConversacionesRepositoryDePrueba();
      final c = _contenedor(repo, hub);
      c.listen(chatControllerProvider('c1'), (_, _) {});
      await c.read(chatControllerProvider('c1').future);
      final notificador = c.read(chatControllerProvider('c1').notifier);
      expect(notificador.enviar('  '), isFalse);
      expect(notificador.enviar('ñ' * 1001), isFalse);
      expect(notificador.validar('x'), isNull);
      expect(repo.enviosIntentados, 0);
    });
  });

  group('ConversacionesRepositoryDePrueba.crear', () {
    test(
      '201 la primera vez, 200 si ya existía y 409 si está cerrada',
      () async {
        final repo = ConversacionesRepositoryDePrueba();
        final nueva = await repo.crear(solicitudId: 's9', tecnicoId: 't1');
        expect(nueva.nueva, isTrue);
        final otra = await repo.crear(solicitudId: 's9', tecnicoId: 't1');
        expect(otra.nueva, isFalse);
        expect(
          otra.conversacion.conversacionId,
          nueva.conversacion.conversacionId,
        );

        final cerrada = ConversacionesRepositoryDePrueba(
          conversaciones: [
            const Conversacion(
              conversacionId: 'c7',
              solicitudId: 's7',
              rol: 'cliente',
              contraparte: ContraparteChat(nombre: 'Ana'),
              servicio: 'Gas',
              estado: 'cerrada',
              motivoCierre: 'visita_terminada',
              contactoVisible: false,
              noLeidos: 0,
            ),
          ],
        );
        expect(
          () => cerrada.crear(solicitudId: 's7', tecnicoId: 't1'),
          throwsA(
            isA<ReglaDeNegocioFailure>().having(
              (e) => e.codigo,
              'codigo',
              'conversation_closed',
            ),
          ),
        );
      },
    );
  });
}
