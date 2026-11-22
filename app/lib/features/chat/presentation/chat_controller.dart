import 'dart:async';

import 'package:app/core/errores/failure.dart';
import 'package:app/features/chat/chat_providers.dart';
import 'package:app/features/chat/domain/chat.dart';
import 'package:app/features/chat/domain/chat_hub.dart';
import 'package:app/features/chat/presentation/conversaciones_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado de un mensaje propio que aún no está confirmado por el servidor.
enum EstadoEnvio { enviando, fallido }

/// Mensaje propio en el aire (envío optimista). `localId` solo existe en el
/// teléfono; al confirmarse se reemplaza por el `Mensaje` del servidor.
class MensajePendiente {
  const MensajePendiente({
    required this.localId,
    required this.texto,
    required this.creadoEn,
    this.estado = EstadoEnvio.enviando,
    this.error,
  });

  final String localId;
  final String texto;
  final DateTime creadoEn;
  final EstadoEnvio estado;

  /// El `Failure` del último intento fallido.
  final Object? error;

  /// Con `content_rejected` o `conversation_closed` repetir no sirve.
  bool get reintentable {
    final e = error;
    return !(e is ReglaDeNegocioFailure &&
        (e.codigo == 'content_rejected' || e.codigo == 'conversation_closed'));
  }

  MensajePendiente con({EstadoEnvio? estado, Object? error}) =>
      MensajePendiente(
        localId: localId,
        texto: texto,
        creadoEn: creadoEn,
        estado: estado ?? this.estado,
        error: error,
      );
}

class EstadoChat {
  const EstadoChat({
    required this.conversacion,
    required this.mensajes,
    this.pendientes = const [],
    this.nextCursor,
    this.segundosEspera = 0,
    this.cargandoAnteriores = false,
    this.huboErrorAlCargarAnteriores = false,
  });

  final Conversacion conversacion;

  /// Más reciente primero.
  final List<Mensaje> mensajes;

  /// Propios sin confirmar, el más antiguo primero.
  final List<MensajePendiente> pendientes;
  final String? nextCursor;

  /// Cuenta regresiva por `message_limit` con `reintentarEnSegundos`.
  final int segundosEspera;
  final bool cargandoAnteriores;
  final bool huboErrorAlCargarAnteriores;

  bool get enviando => pendientes.any((p) => p.estado == EstadoEnvio.enviando);

  bool esMio(Mensaje m) => m.autorRol == conversacion.rol;

  EstadoChat copiar({
    Conversacion? conversacion,
    List<Mensaje>? mensajes,
    List<MensajePendiente>? pendientes,
    String? nextCursor,
    int? segundosEspera,
    bool? cargandoAnteriores,
    bool? huboErrorAlCargarAnteriores,
    bool conservarCursor = true,
  }) => EstadoChat(
    conversacion: conversacion ?? this.conversacion,
    mensajes: mensajes ?? this.mensajes,
    pendientes: pendientes ?? this.pendientes,
    nextCursor: conservarCursor ? (nextCursor ?? this.nextCursor) : nextCursor,
    segundosEspera: segundosEspera ?? this.segundosEspera,
    cargandoAnteriores: cargandoAnteriores ?? this.cargandoAnteriores,
    huboErrorAlCargarAnteriores:
        huboErrorAlCargarAnteriores ?? this.huboErrorAlCargarAnteriores,
  );
}

/// Detalle, historial con cursor, envío optimista y marcado de leído de una
/// conversación.
///
/// El envío va por `POST /conversaciones/{id}/mensajes`; el hub entrega los
/// mensajes de la otra persona y repetidos de los propios, que se descartan
/// por `mensajeId`. Un mensaje propio aparece al instante como pendiente
/// (`enviando`) y se confirma, o queda `fallido` con Reintentar.
class ChatController extends AsyncNotifier<EstadoChat> {
  ChatController(this.conversacionId);

  final String conversacionId;

  Timer? _cuentaRegresiva;
  DateTime? _ultimoLeido;
  bool _visible = true;
  int _consecutivo = 0;
  Future<void>? _ultimoEnvio;

  /// El último envío en curso; para esperar su final en las pruebas.
  @visibleForTesting
  Future<void>? get ultimoEnvio => _ultimoEnvio;

  @override
  Future<EstadoChat> build() async {
    final repo = ref.watch(conversacionesRepositoryProvider);
    final hub = ref.watch(chatHubProvider);

    ref.listen(eventosChatProvider, (_, evento) {
      final e = evento.value;
      if (e is MensajeConversacionRecibido &&
          e.conversacionId == conversacionId) {
        _agregar(e.mensaje, deLaOtraPersona: true);
      } else if (e is ConexionRestablecida) {
        unawaited(_ponerseAlDia());
      }
    });
    ref.onDispose(() {
      _cuentaRegresiva?.cancel();
      unawaited(hub.salirDeConversacion(conversacionId));
    });
    unawaited(hub.unirseAConversacion(conversacionId));

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

  /// La pantalla avisa si se está viendo (primer plano): solo se marca leído
  /// lo que la persona puede ver.
  void visible({required bool valor}) {
    _visible = valor;
    final actual = _vigente;
    if (valor && actual != null) {
      unawaited(_marcarLeido(actual.mensajes));
    }
  }

  void _poner(EstadoChat nuevo) {
    if (ref.mounted) {
      state = AsyncData(nuevo);
    }
  }

  EstadoChat? get _vigente => ref.mounted ? state.value : null;

  Future<void> _marcarLeido(List<Mensaje> mensajes) async {
    if (!_visible || mensajes.isEmpty) {
      return;
    }
    // `hasta` es el último mensaje confirmado que se ve, no el primero de la
    // lista, por si el hub entregó algo fuera de orden.
    final hasta = mensajes
        .map((m) => m.enviadoEn)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    final previo = _ultimoLeido;
    if (previo != null && !hasta.isAfter(previo)) {
      return;
    }
    _ultimoLeido = hasta;
    try {
      await ref
          .read(conversacionesRepositoryProvider)
          .marcarLeido(conversacionId, hasta: hasta);
      if (ref.mounted) {
        ref
          ..invalidate(noLeidasChatProvider)
          ..invalidate(conversacionesControllerProvider);
      }
    } on Object {
      // Mejor esfuerzo: se vuelve a intentar con el siguiente mensaje.
      _ultimoLeido = previo;
    }
  }

  /// Inserta respetando el orden por fecha (más reciente primero) y sin
  /// repetir `mensajeId` (REST y hub pueden entregar el mismo).
  List<Mensaje> _fusionar(List<Mensaje> actuales, Iterable<Mensaje> nuevos) {
    final lista = [...actuales];
    for (final m in nuevos) {
      if (lista.any((x) => x.mensajeId == m.mensajeId)) {
        continue;
      }
      final i = lista.indexWhere((x) => !x.enviadoEn.isAfter(m.enviadoEn));
      lista.insert(i < 0 ? lista.length : i, m);
    }
    return lista;
  }

  void _agregar(Mensaje mensaje, {required bool deLaOtraPersona}) {
    final actual = _vigente;
    if (actual == null ||
        actual.mensajes.any((m) => m.mensajeId == mensaje.mensajeId)) {
      return;
    }
    // Un mensaje propio que llega por el hub mientras su POST sigue en el
    // aire se deja para la respuesta del POST: evita verlo doble un instante.
    if (actual.esMio(mensaje) &&
        actual.pendientes.any(
          (p) => p.estado == EstadoEnvio.enviando && p.texto == mensaje.texto,
        )) {
      return;
    }
    final nuevo = actual.copiar(
      mensajes: _fusionar(actual.mensajes, [mensaje]),
    );
    _poner(nuevo);
    if (deLaOtraPersona && !nuevo.esMio(mensaje)) {
      unawaited(_marcarLeido(nuevo.mensajes));
    }
  }

  /// Tras reconectar el hub se piden los últimos mensajes por si alguno se
  /// perdió en la caída.
  Future<void> _ponerseAlDia() async {
    try {
      final pagina = await ref
          .read(conversacionesRepositoryProvider)
          .mensajes(conversacionId);
      final actual = _vigente;
      if (actual == null) {
        return;
      }
      final nuevo = actual.copiar(
        mensajes: _fusionar(actual.mensajes, pagina.items),
      );
      _poner(nuevo);
      unawaited(_marcarLeido(nuevo.mensajes));
    } on Object {
      // Mejor esfuerzo.
    }
  }

  /// Validación previa al envío: `null` si el texto sirve.
  Object? validar(String texto) {
    try {
      validarTextoMensaje(texto);
      return null;
    } on Object catch (e) {
      return e;
    }
  }

  bool get _bloqueado {
    final actual = _vigente;
    return actual == null ||
        actual.conversacion.cerrada ||
        actual.enviando ||
        actual.segundosEspera > 0;
  }

  /// Pone el mensaje en la conversación al instante y lo envía. Devuelve
  /// `false` (sin enviar nada) si el texto no es válido, ya hay un envío en
  /// curso, hay una espera por límite o la conversación está cerrada.
  bool enviar(String texto) {
    if (_bloqueado || validar(texto) != null) {
      return false;
    }
    final actual = _vigente!;
    final pendiente = MensajePendiente(
      localId: 'local-${_consecutivo++}',
      texto: validarTextoMensaje(texto),
      creadoEn: DateTime.now().toUtc(),
    );
    _poner(actual.copiar(pendientes: [...actual.pendientes, pendiente]));
    _ultimoEnvio = _despachar(pendiente);
    return true;
  }

  /// Repite un envío fallido. No hace nada si hay otro en curso o una espera.
  bool reintentarEnvio(String localId) {
    final actual = _vigente;
    if (actual == null || _bloqueado) {
      return false;
    }
    final i = actual.pendientes.indexWhere((p) => p.localId == localId);
    if (i < 0 ||
        actual.pendientes[i].estado != EstadoEnvio.fallido ||
        !actual.pendientes[i].reintentable) {
      return false;
    }
    final lista = [...actual.pendientes];
    lista[i] = lista[i].con(estado: EstadoEnvio.enviando);
    _poner(actual.copiar(pendientes: lista));
    _ultimoEnvio = _despachar(lista[i]);
    return true;
  }

  /// Quita un envío fallido.
  void descartar(String localId) {
    final actual = _vigente;
    if (actual == null) {
      return;
    }
    _poner(
      actual.copiar(
        pendientes: [
          for (final p in actual.pendientes)
            if (p.localId != localId) p,
        ],
      ),
    );
  }

  Future<void> _despachar(MensajePendiente pendiente) async {
    try {
      final mensaje = await ref
          .read(conversacionesRepositoryProvider)
          .enviar(conversacionId, pendiente.texto);
      final actual = _vigente;
      if (actual == null) {
        return;
      }
      _poner(
        actual.copiar(
          pendientes: [
            for (final p in actual.pendientes)
              if (p.localId != pendiente.localId) p,
          ],
          mensajes: _fusionar(actual.mensajes, [mensaje]),
        ),
      );
    } on Object catch (e) {
      final actual = _vigente;
      if (actual == null) {
        return;
      }
      final cerrada =
          e is ReglaDeNegocioFailure && e.codigo == 'conversation_closed';
      _poner(
        actual.copiar(
          conversacion: cerrada ? actual.conversacion.comoCerrada() : null,
          pendientes: [
            for (final p in actual.pendientes)
              if (p.localId == pendiente.localId)
                p.con(estado: EstadoEnvio.fallido, error: e)
              else
                p,
          ],
        ),
      );
      if (e is LimiteDePeticionesFailure &&
          e.codigo == 'message_limit' &&
          (e.reintentarEnSegundos ?? 0) > 0) {
        _iniciarEspera(e.reintentarEnSegundos!);
      }
    }
  }

  void _iniciarEspera(int segundos) {
    _cuentaRegresiva?.cancel();
    final actual = _vigente;
    if (actual == null) {
      return;
    }
    _poner(actual.copiar(segundosEspera: segundos));
    _cuentaRegresiva = Timer.periodic(const Duration(seconds: 1), (t) {
      final e = _vigente;
      if (e == null || e.segundosEspera <= 1) {
        t.cancel();
        if (e != null) {
          _poner(e.copiar(segundosEspera: 0));
        }
        return;
      }
      _poner(e.copiar(segundosEspera: e.segundosEspera - 1));
    });
  }

  Future<void> cargarAnteriores() async {
    final actual = _vigente;
    final cursor = actual?.nextCursor;
    if (actual == null || cursor == null || actual.cargandoAnteriores) {
      return;
    }
    _poner(
      actual.copiar(
        cargandoAnteriores: true,
        huboErrorAlCargarAnteriores: false,
      ),
    );
    try {
      final pagina = await ref
          .read(conversacionesRepositoryProvider)
          .mensajes(conversacionId, cursor: cursor);
      final vigente = _vigente ?? actual;
      _poner(
        vigente.copiar(
          mensajes: _fusionar(vigente.mensajes, pagina.items),
          nextCursor: pagina.nextCursor,
          conservarCursor: false,
          cargandoAnteriores: false,
        ),
      );
    } on Object {
      _poner(
        (_vigente ?? actual).copiar(
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
