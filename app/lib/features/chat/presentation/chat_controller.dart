import 'dart:async';

import 'package:app/features/chat/chat_providers.dart';
import 'package:app/features/chat/domain/chat.dart';
import 'package:app/features/chat/domain/chat_hub.dart';
import 'package:app/features/chat/presentation/conversaciones_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EstadoChat {
  const EstadoChat({
    required this.conversacion,
    required this.mensajes,
    this.nextCursor,
    this.enviando = false,
    this.cargandoAnteriores = false,
    this.huboErrorAlCargarAnteriores = false,
  });

  final Conversacion conversacion;

  /// Más reciente primero.
  final List<Mensaje> mensajes;
  final String? nextCursor;
  final bool enviando;
  final bool cargandoAnteriores;
  final bool huboErrorAlCargarAnteriores;

  bool esMio(Mensaje m) => m.autorRol == conversacion.rol;

  EstadoChat copiar({
    List<Mensaje>? mensajes,
    String? nextCursor,
    bool? enviando,
    bool? cargandoAnteriores,
    bool? huboErrorAlCargarAnteriores,
    bool conservarCursor = true,
  }) => EstadoChat(
    conversacion: conversacion,
    mensajes: mensajes ?? this.mensajes,
    nextCursor: conservarCursor ? (nextCursor ?? this.nextCursor) : nextCursor,
    enviando: enviando ?? this.enviando,
    cargandoAnteriores: cargandoAnteriores ?? this.cargandoAnteriores,
    huboErrorAlCargarAnteriores:
        huboErrorAlCargarAnteriores ?? this.huboErrorAlCargarAnteriores,
  );
}

/// Detalle, historial con cursor, envío y marcado de leído de una conversación.
///
/// El envío va por `POST /conversaciones/{id}/mensajes`; el hub solo entrega
/// los mensajes de la otra persona (y repetidos de los propios, que se
/// descartan por `mensajeId`).
class ChatController extends AsyncNotifier<EstadoChat> {
  ChatController(this.conversacionId);

  final String conversacionId;

  @override
  Future<EstadoChat> build() async {
    final repo = ref.watch(conversacionesRepositoryProvider);
    final hub = ref.watch(chatHubProvider);

    ref.listen(eventosChatProvider, (_, evento) {
      final e = evento.value;
      if (e is MensajeConversacionRecibido &&
          e.conversacionId == conversacionId) {
        _agregar(e.mensaje, deLaOtraPersona: true);
      }
    });
    unawaited(hub.unirseAConversacion(conversacionId));
    ref.onDispose(() => unawaited(hub.salirDeConversacion(conversacionId)));

    final conversacion = await repo.obtener(conversacionId);
    final pagina = await repo.mensajes(conversacionId);
    final estado = EstadoChat(
      conversacion: conversacion,
      mensajes: pagina.items,
      nextCursor: pagina.nextCursor,
    );
    unawaited(_marcarLeido(estado.mensajes));
    return estado;
  }

  void reintentar() => ref.invalidateSelf();

  Future<void> _marcarLeido(List<Mensaje> mensajes) async {
    if (mensajes.isEmpty) {
      return;
    }
    try {
      await ref
          .read(conversacionesRepositoryProvider)
          .marcarLeido(conversacionId, hasta: mensajes.first.enviadoEn);
      ref
        ..invalidate(noLeidasChatProvider)
        ..invalidate(conversacionesControllerProvider);
    } on Object {
      // Mejor esfuerzo: el contador se corrige en la siguiente carga.
    }
  }

  void _agregar(Mensaje mensaje, {required bool deLaOtraPersona}) {
    final actual = state.value;
    if (actual == null ||
        actual.mensajes.any((m) => m.mensajeId == mensaje.mensajeId)) {
      return;
    }
    final nuevo = actual.copiar(mensajes: [mensaje, ...actual.mensajes]);
    state = AsyncData(nuevo);
    if (deLaOtraPersona && !nuevo.esMio(mensaje)) {
      unawaited(_marcarLeido(nuevo.mensajes));
    }
  }

  /// Envía un mensaje. Devuelve `null` si salió bien o el error (un `Failure`)
  /// para que la pantalla muestre el texto adecuado. Valida antes de llamar.
  Future<Object?> enviar(String texto) async {
    final actual = state.value;
    if (actual == null || actual.enviando) {
      return null;
    }
    final String limpio;
    try {
      limpio = validarTextoMensaje(texto);
    } on Object catch (e) {
      return e;
    }
    state = AsyncData(actual.copiar(enviando: true));
    try {
      final mensaje = await ref
          .read(conversacionesRepositoryProvider)
          .enviar(conversacionId, limpio);
      state = AsyncData((state.value ?? actual).copiar(enviando: false));
      _agregar(mensaje, deLaOtraPersona: false);
      return null;
    } on Object catch (e) {
      state = AsyncData((state.value ?? actual).copiar(enviando: false));
      return e;
    }
  }

  Future<void> cargarAnteriores() async {
    final actual = state.value;
    final cursor = actual?.nextCursor;
    if (actual == null || cursor == null || actual.cargandoAnteriores) {
      return;
    }
    state = AsyncData(
      actual.copiar(
        cargandoAnteriores: true,
        huboErrorAlCargarAnteriores: false,
      ),
    );
    try {
      final pagina = await ref
          .read(conversacionesRepositoryProvider)
          .mensajes(conversacionId, cursor: cursor);
      final vigente = state.value ?? actual;
      state = AsyncData(
        vigente.copiar(
          mensajes: [...vigente.mensajes, ...pagina.items],
          nextCursor: pagina.nextCursor,
          conservarCursor: false,
          cargandoAnteriores: false,
        ),
      );
    } on Object {
      state = AsyncData(
        (state.value ?? actual).copiar(
          cargandoAnteriores: false,
          huboErrorAlCargarAnteriores: true,
        ),
      );
    }
  }
}

final chatControllerProvider =
    AsyncNotifierProvider.family<ChatController, EstadoChat, String>(
      ChatController.new,
      retry: (_, _) => null,
    );
