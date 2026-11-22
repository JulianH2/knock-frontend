import 'dart:async';

import 'package:app/features/chat/data/chat_mapper.dart';
import 'package:app/features/chat/domain/chat_hub.dart';

/// Token con el que se abre la conexión. `venceEn` permite reconectar con uno
/// nuevo antes de que el servidor cierre la conexión (el hub la cierra cuando
/// vence el JWT).
class TokenHub {
  const TokenHub(this.valor, {this.venceEn});

  final String valor;
  final DateTime? venceEn;
}

/// Mensaje que el servidor empuja: nombre del evento y su argumento JSON.
class MensajeDeHub {
  const MensajeDeHub(this.nombre, this.argumento);

  final String nombre;
  final Object? argumento;
}

/// Capa mínima sobre SignalR. La implementación real (paquete de SignalR, aún
/// sin evaluar) solo tiene que cumplir esto: WebSocket y SSE de respaldo, sin
/// long-polling, con el token en `access_token`.
abstract interface class TransporteHub {
  Stream<MensajeDeHub> get recibidos;

  /// Se emite cuando la conexión se cae o el servidor la cierra.
  Stream<Object?> get cierres;

  Future<void> iniciar(String token);

  Future<void> detener();

  /// Invoca un método del hub y devuelve su `ChatResult` en JSON.
  Future<Object?> invocar(String metodo, List<Object?> argumentos);
}

/// Transporte que no conecta nunca: la implementación real queda inactiva
/// hasta decidir el paquete de SignalR.
class TransporteHubInactivo implements TransporteHub {
  const TransporteHubInactivo();

  @override
  Stream<MensajeDeHub> get recibidos => const Stream<MensajeDeHub>.empty();

  @override
  Stream<Object?> get cierres => const Stream<Object?>.empty();

  @override
  Future<void> iniciar(String token) =>
      Future<void>.error(StateError('transporte inactivo'));

  @override
  Future<void> detener() async {}

  @override
  Future<Object?> invocar(String metodo, List<Object?> argumentos) =>
      Future<Object?>.error(StateError('transporte inactivo'));
}

/// Espera antes del intento `n` (desde 1): 1, 2, 4, 8, 16 y 30 s como tope.
Duration retardoDeReconexion(int intento) {
  final segundos = 1 << (intento - 1).clamp(0, 5);
  return Duration(seconds: segundos > 30 ? 30 : segundos);
}

/// Cliente de `/hubs/chat` detrás de `ChatHub`.
///
/// - Recuerda a qué salas quiere estar unida la app y se vuelve a unir tras
///   cada reconexión.
/// - Reconecta con espera creciente cuando se cae la conexión.
/// - Pide un token nuevo en cada conexión y se reconecta poco antes de que el
///   actual venza.
/// - Entrega los eventos ya traducidos y avisa `ConexionRestablecida` después
///   de volver a conectar, para que las pantallas se pongan al día por REST.
class ChatHubCliente implements ChatHub {
  ChatHubCliente({
    required this.transporte,
    required this.obtenerToken,
    Future<void> Function(Duration)? esperar,
    DateTime Function()? ahora,
    this.margenDeToken = const Duration(seconds: 30),
  }) : _esperar = esperar ?? Future<void>.delayed,
       _ahora = ahora ?? (() => DateTime.now().toUtc());

  final TransporteHub transporte;
  final Future<TokenHub?> Function() obtenerToken;
  final Future<void> Function(Duration) _esperar;
  final DateTime Function() _ahora;
  final Duration margenDeToken;

  final StreamController<EventoChat> _eventos =
      StreamController<EventoChat>.broadcast();
  final Set<String> _conversaciones = {};
  final Set<String> _visitas = {};
  StreamSubscription<MensajeDeHub>? _recibidos;
  StreamSubscription<Object?>? _cierres;
  Timer? _vencimiento;
  bool _quiereConexion = false;
  bool _conectado = false;
  bool _ignorarCierre = false;
  Future<void>? _conexionEnCurso;
  bool _huboConexion = false;

  bool get conectado => _conectado;

  @override
  Stream<EventoChat> get eventos => _eventos.stream;

  @override
  Future<void> conectar() {
    _quiereConexion = true;
    return _conexionEnCurso ??= _conectarConReintentos().whenComplete(
      () => _conexionEnCurso = null,
    );
  }

  @override
  Future<void> desconectar() async {
    _quiereConexion = false;
    _vencimiento?.cancel();
    await _recibidos?.cancel();
    await _cierres?.cancel();
    _recibidos = null;
    _cierres = null;
    _conectado = false;
    await transporte.detener();
    if (!_eventos.isClosed) {
      await _eventos.close();
    }
  }

  /// Cierra la conexión actual y abre otra con un token nuevo.
  Future<void> renovarSesion() async {
    if (!_quiereConexion) {
      return;
    }
    _ignorarCierre = true;
    _vencimiento?.cancel();
    _conectado = false;
    try {
      await transporte.detener();
    } on Object {
      // Ya estaba caída; se abre una nueva de todos modos.
    } finally {
      _ignorarCierre = false;
    }
    await conectar();
  }

  Future<void> _conectarConReintentos() async {
    var intento = 0;
    while (_quiereConexion) {
      try {
        final token = await obtenerToken();
        if (token == null) {
          throw StateError('sin sesión');
        }
        await transporte.iniciar(token.valor);
        if (!_quiereConexion) {
          await transporte.detener();
          return;
        }
        _conectado = true;
        await _suscribir();
        _programarVencimiento(token);
        await _volverAUnirse();
        if (_huboConexion && !_eventos.isClosed) {
          _eventos.add(const ConexionRestablecida());
        }
        _huboConexion = true;
        return;
      } on Object {
        _conectado = false;
        intento++;
        await _esperar(retardoDeReconexion(intento));
      }
    }
  }

  Future<void> _suscribir() async {
    await _recibidos?.cancel();
    await _cierres?.cancel();
    _recibidos = transporte.recibidos.listen((m) {
      try {
        final evento = ChatMapper.evento(m.nombre, m.argumento);
        if (evento != null && !_eventos.isClosed) {
          _eventos.add(evento);
        }
      } on Object {
        // Un evento mal formado no tumba la conexión: se descarta.
      }
    });
    _cierres = transporte.cierres.listen((_) {
      if (_ignorarCierre || !_conectado) {
        return;
      }
      _conectado = false;
      _vencimiento?.cancel();
      if (_quiereConexion) {
        unawaited(conectar());
      }
    });
  }

  void _programarVencimiento(TokenHub token) {
    _vencimiento?.cancel();
    final vence = token.venceEn;
    if (vence == null) {
      return;
    }
    var espera = vence.difference(_ahora()) - margenDeToken;
    if (espera.isNegative) {
      espera = Duration.zero;
    }
    _vencimiento = Timer(espera, () => unawaited(renovarSesion()));
  }

  Future<void> _volverAUnirse() async {
    for (final id in [..._conversaciones]) {
      await _unir('UnirseAConversacion', id, _conversaciones);
    }
    for (final id in [..._visitas]) {
      await _unir('UnirseAVisita', id, _visitas);
    }
  }

  Future<ResultadoHub> _unir(
    String metodo,
    String id,
    Set<String> deseadas,
  ) async {
    deseadas.add(id);
    final resultado = await _invocar(metodo, [id]);
    // Si el servidor dice que esa sala no es de la persona, no se insiste.
    if (!resultado.ok &&
        (resultado.codigo == 'unauthorized' ||
            resultado.codigo == 'conversation_unavailable')) {
      deseadas.remove(id);
    }
    return resultado;
  }

  Future<ResultadoHub> _invocar(String metodo, List<Object?> args) async {
    if (!_conectado) {
      return const ResultadoHub(ok: false, codigo: 'unavailable');
    }
    try {
      return ChatMapper.resultadoHub(await transporte.invocar(metodo, args));
    } on Object {
      return const ResultadoHub(ok: false, codigo: 'unavailable');
    }
  }

  @override
  Future<ResultadoHub> unirseAConversacion(String conversacionId) =>
      _unir('UnirseAConversacion', conversacionId, _conversaciones);

  @override
  Future<ResultadoHub> salirDeConversacion(String conversacionId) {
    _conversaciones.remove(conversacionId);
    return _invocar('SalirDeConversacion', [conversacionId]);
  }

  @override
  Future<ResultadoHub> unirseAVisita(String visitaId) =>
      _unir('UnirseAVisita', visitaId, _visitas);

  @override
  Future<ResultadoHub> salirDeVisita(String visitaId) {
    _visitas.remove(visitaId);
    return _invocar('SalirDeVisita', [visitaId]);
  }

  @override
  Future<ResultadoHub> enviarMensajeVisita(String visitaId, String texto) =>
      _invocar('EnviarMensaje', [visitaId, texto]);
}
