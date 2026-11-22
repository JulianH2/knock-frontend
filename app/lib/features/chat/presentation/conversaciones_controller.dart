import 'dart:async';

import 'package:app/features/chat/chat_providers.dart';
import 'package:app/features/chat/domain/chat.dart';
import 'package:app/features/chat/domain/chat_hub.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Total de no leídos para la insignia. Se vuelve a pedir cuando el hub avisa
/// (`noLeidos`): el GET es la fuente de verdad.
final noLeidasChatProvider = FutureProvider.autoDispose<int>((ref) {
  ref.listen(eventosChatProvider, (_, evento) {
    final e = evento.value;
    if (e is NoLeidosActualizados || e is ConexionRestablecida) {
      ref.invalidateSelf();
    }
  });
  return ref.watch(conversacionesRepositoryProvider).noLeidas();
}, retry: (_, _) => null);

class BandejaChats {
  const BandejaChats({
    required this.items,
    required this.totalNoLeidos,
    this.nextCursor,
    this.cargandoMas = false,
    this.huboErrorAlCargarMas = false,
  });

  final List<ConversacionItem> items;
  final int totalNoLeidos;
  final String? nextCursor;
  final bool cargandoMas;
  final bool huboErrorAlCargarMas;

  BandejaChats copiar({
    List<ConversacionItem>? items,
    int? totalNoLeidos,
    bool? cargandoMas,
    bool? huboErrorAlCargarMas,
  }) => BandejaChats(
    items: items ?? this.items,
    totalNoLeidos: totalNoLeidos ?? this.totalNoLeidos,
    nextCursor: nextCursor,
    cargandoMas: cargandoMas ?? this.cargandoMas,
    huboErrorAlCargarMas: huboErrorAlCargarMas ?? this.huboErrorAlCargarMas,
  );
}

/// Lista de conversaciones con cursor; el hub actualiza contadores y último
/// mensaje sin volver a pedir la lista.
class ConversacionesController extends AsyncNotifier<BandejaChats> {
  @override
  Future<BandejaChats> build() async {
    ref.listen(eventosChatProvider, (_, evento) {
      final e = evento.value;
      if (e != null) {
        _alEvento(e);
      }
    });
    final pagina = await ref.watch(conversacionesRepositoryProvider).listar();
    return BandejaChats(
      items: pagina.items,
      totalNoLeidos: pagina.totalNoLeidos,
      nextCursor: pagina.nextCursor,
    );
  }

  void reintentar() => ref.invalidateSelf();

  /// Pull-to-refresh: vuelve a pedir la primera página sin pasar por la
  /// pantalla de carga. Si falla, la lista actual se conserva y devuelve
  /// `false`.
  Future<bool> refrescar() async {
    try {
      final pagina = await ref.read(conversacionesRepositoryProvider).listar();
      if (!ref.mounted) {
        return true;
      }
      state = AsyncData(
        BandejaChats(
          items: pagina.items,
          totalNoLeidos: pagina.totalNoLeidos,
          nextCursor: pagina.nextCursor,
        ),
      );
      return true;
    } on Object {
      return false;
    }
  }

  void _alEvento(EventoChat evento) {
    final actual = state.value;
    if (actual == null) {
      return;
    }
    switch (evento) {
      case NoLeidosActualizados():
        state = AsyncData(
          actual.copiar(
            totalNoLeidos: evento.total,
            items: [
              for (final c in actual.items)
                if (c.conversacionId == evento.conversacionId)
                  c.copiar(noLeidos: evento.noLeidos)
                else
                  c,
            ],
          ),
        );
      case MensajeConversacionRecibido():
        final lista = [...actual.items];
        final i = lista.indexWhere(
          (c) => c.conversacionId == evento.conversacionId,
        );
        if (i < 0) {
          // Conversación que la lista aún no tiene: se vuelve a pedir.
          ref.invalidateSelf();
          return;
        }
        final c = lista.removeAt(i);
        lista.insert(
          0,
          c.copiar(
            ultimoMensaje: UltimoMensaje(
              texto: evento.mensaje.texto,
              enviadoEn: evento.mensaje.enviadoEn,
              autorRol: evento.mensaje.autorRol,
            ),
          ),
        );
        state = AsyncData(actual.copiar(items: lista));
      case ConexionRestablecida():
        // Los `noLeidos` de la caída pudieron perderse: se pone al día.
        unawaited(refrescar());
      case MensajeVisitaRecibido():
        break;
    }
  }

  Future<void> cargarMas() async {
    final actual = state.value;
    final cursor = actual?.nextCursor;
    if (actual == null || cursor == null || actual.cargandoMas) {
      return;
    }
    state = AsyncData(
      actual.copiar(cargandoMas: true, huboErrorAlCargarMas: false),
    );
    try {
      final pagina = await ref
          .read(conversacionesRepositoryProvider)
          .listar(cursor: cursor);
      state = AsyncData(
        BandejaChats(
          items: [...actual.items, ...pagina.items],
          totalNoLeidos: pagina.totalNoLeidos,
          nextCursor: pagina.nextCursor,
        ),
      );
    } on Object {
      state = AsyncData(
        actual.copiar(cargandoMas: false, huboErrorAlCargarMas: true),
      );
    }
  }
}

final conversacionesControllerProvider =
    AsyncNotifierProvider<ConversacionesController, BandejaChats>(
      ConversacionesController.new,
      retry: (_, _) => null,
    );
