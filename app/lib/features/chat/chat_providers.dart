import 'dart:async';

import 'package:app/features/chat/data/chat_de_prueba.dart';
import 'package:app/features/chat/domain/chat.dart';
import 'package:app/features/chat/domain/chat_hub.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Raíz de composición del chat (KNOCK-72/73). Datos de prueba hasta que
/// exista el cliente HTTP contra el gateway.
final conversacionesRepositoryProvider = Provider<ConversacionesRepository>(
  (ref) => ConversacionesRepositoryDePrueba(),
);

/// Hub de chat. `ChatHubInactivo` hasta que se evalúe el paquete de SignalR;
/// la implementación real solo cambia esta línea.
final chatHubProvider = Provider<ChatHub>((ref) {
  const hub = ChatHubInactivo();
  unawaited(hub.conectar());
  ref.onDispose(() => unawaited(hub.desconectar()));
  return hub;
});

/// Eventos del hub como flujo de Riverpod.
final eventosChatProvider = StreamProvider<EventoChat>(
  (ref) => ref.watch(chatHubProvider).eventos,
);
