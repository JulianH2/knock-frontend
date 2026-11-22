import 'package:app/features/chat/domain/chat.dart';

/// Eventos que el hub `/hubs/chat` entrega a la app.
sealed class EventoChat {
  const EventoChat();
}

/// `mensajeConversacion`: llegó un mensaje a una conversación.
final class MensajeConversacionRecibido extends EventoChat {
  const MensajeConversacionRecibido({
    required this.conversacionId,
    required this.mensaje,
  });

  final String conversacionId;
  final Mensaje mensaje;
}

/// `noLeidos`: cambió el contador (mejor esfuerzo; la fuente de verdad es
/// `GET /conversaciones/no-leidas`).
final class NoLeidosActualizados extends EventoChat {
  const NoLeidosActualizados({
    required this.conversacionId,
    required this.noLeidos,
    required this.total,
  });

  final String conversacionId;
  final int noLeidos;
  final int total;
}

/// `mensaje`: chat de visita (spec 026). La pantalla de chat de la app usa el
/// de conversación; este evento queda disponible hasta confirmar el flujo.
final class MensajeVisitaRecibido extends EventoChat {
  const MensajeVisitaRecibido({
    required this.visitaId,
    required this.mensajeId,
    required this.texto,
    required this.enviadoEn,
  });

  final String visitaId;
  final String mensajeId;
  final String texto;
  final DateTime enviadoEn;
}

/// `ChatResult` de los métodos del hub.
class ResultadoHub {
  const ResultadoHub({
    required this.ok,
    this.codigo,
    this.reintentarEnSegundos,
  });

  final bool ok;

  /// `unauthorized`, `conversation_unavailable`, `unavailable`, `not_joined`,
  /// `invalid_message` o `message_limit`.
  final String? codigo;
  final int? reintentarEnSegundos;
}

/// Conexión SignalR con `/hubs/chat` (WebSocket y SSE; sin long-polling; token
/// en `access_token`; se cierra al vencer el token y hay que reconectar).
///
/// Es una interfaz porque el paquete de SignalR aún no está evaluado
/// (duda en Memoria). Mientras tanto la app usa `ChatHubInactivo` o el falso
/// de pruebas.
abstract interface class ChatHub {
  Stream<EventoChat> get eventos;

  Future<void> conectar();

  Future<void> desconectar();

  /// `UnirseAConversacion(conversacionId)`.
  Future<ResultadoHub> unirseAConversacion(String conversacionId);

  /// `SalirDeConversacion(conversacionId)`.
  Future<ResultadoHub> salirDeConversacion(String conversacionId);
}
