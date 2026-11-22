import 'dart:async';

import 'package:app/core/errores/failure.dart';
import 'package:app/features/chat/domain/chat.dart';
import 'package:app/features/chat/domain/chat_hub.dart';

/// Conversaciones ficticias en memoria con el comportamiento del contrato.
/// `falla` rompe toda llamada; `fallaAlEnviar` solo el envío.
class ConversacionesRepositoryDePrueba implements ConversacionesRepository {
  ConversacionesRepositoryDePrueba({
    List<Conversacion>? conversaciones,
    Map<String, List<Mensaje>>? mensajes,
    this.falla,
    this.fallaAlEnviar,
    DateTime Function()? ahora,
  }) : _conversaciones = [...conversaciones ?? _ficticias],
       _mensajes = {
         for (final e in (mensajes ?? _mensajesFicticios).entries)
           e.key: [...e.value],
       },
       _ahora = ahora ?? (() => DateTime.now().toUtc());

  final List<Conversacion> _conversaciones;
  final Map<String, List<Mensaje>> _mensajes;
  final DateTime Function() _ahora;
  final Failure? falla;
  final Failure? fallaAlEnviar;
  final List<DateTime> marcadosLeidos = [];
  int _siguiente = 1000;

  void _revisar() {
    final error = falla;
    if (error != null) {
      throw error;
    }
  }

  Conversacion _buscar(String id) {
    final i = _conversaciones.indexWhere((c) => c.conversacionId == id);
    if (i < 0) {
      throw const NoEncontradoFailure();
    }
    return _conversaciones[i];
  }

  @override
  Future<PaginaConversaciones> listar({String? cursor, int limite = 20}) async {
    _revisar();
    final inicio = (int.tryParse(cursor ?? '0') ?? 0).clamp(
      0,
      _conversaciones.length,
    );
    final fin = (inicio + limite).clamp(0, _conversaciones.length);
    return PaginaConversaciones(
      items: [
        for (final c in _conversaciones.sublist(inicio, fin))
          _aItem(c, _mensajes[c.conversacionId]),
      ],
      totalNoLeidos: _conversaciones.fold(0, (s, c) => s + c.noLeidos),
      nextCursor: fin < _conversaciones.length ? '$fin' : null,
    );
  }

  ConversacionItem _aItem(Conversacion c, List<Mensaje>? mensajes) {
    final ultimo = mensajes == null || mensajes.isEmpty ? null : mensajes.first;
    return ConversacionItem(
      conversacionId: c.conversacionId,
      solicitudId: c.solicitudId,
      visitaId: c.visitaId,
      rol: c.rol,
      contraparte: c.contraparte,
      servicio: c.servicio,
      estado: c.estado,
      noLeidos: c.noLeidos,
      ultimoMensaje: ultimo == null
          ? null
          : UltimoMensaje(
              texto: ultimo.texto,
              enviadoEn: ultimo.enviadoEn,
              autorRol: ultimo.autorRol,
            ),
    );
  }

  @override
  Future<int> noLeidas() async {
    _revisar();
    return _conversaciones.fold<int>(0, (s, c) => s + c.noLeidos);
  }

  @override
  Future<Conversacion> obtener(String id) async {
    _revisar();
    return _buscar(id);
  }

  @override
  Future<PaginaMensajes> mensajes(
    String id, {
    String? cursor,
    int limite = 30,
  }) async {
    _revisar();
    _buscar(id);
    final todos = _mensajes[id] ?? const <Mensaje>[];
    final inicio = (int.tryParse(cursor ?? '0') ?? 0).clamp(0, todos.length);
    final fin = (inicio + limite).clamp(0, todos.length);
    return PaginaMensajes(
      items: todos.sublist(inicio, fin),
      nextCursor: fin < todos.length ? '$fin' : null,
    );
  }

  @override
  Future<Mensaje> enviar(String id, String texto) async {
    _revisar();
    final conversacion = _buscar(id);
    final error = fallaAlEnviar;
    if (error != null) {
      throw error;
    }
    if (conversacion.cerrada) {
      throw const ReglaDeNegocioFailure('conversation_closed');
    }
    final limpio = validarTextoMensaje(texto);
    final mensaje = Mensaje(
      mensajeId: 'm${_siguiente++}',
      autorRol: conversacion.rol,
      texto: limpio,
      contactoOculto: false,
      enviadoEn: _ahora(),
    );
    _mensajes.putIfAbsent(id, () => []).insert(0, mensaje);
    return mensaje;
  }

  @override
  Future<void> marcarLeido(String id, {required DateTime hasta}) async {
    _revisar();
    _buscar(id);
    marcadosLeidos.add(hasta);
  }
}

final _ficticias = [
  const Conversacion(
    conversacionId: 'c1',
    solicitudId: 's1',
    rol: 'cliente',
    contraparte: ContraparteChat(nombre: 'Luis Prueba'),
    servicio: 'Plomería',
    estado: 'abierta',
    contactoVisible: false,
    avisoSeguridad:
        'Por tu seguridad, no compartas datos personales fuera de Knock.',
    noLeidos: 1,
  ),
];

final _mensajesFicticios = {
  'c1': [
    Mensaje(
      mensajeId: 'm2',
      autorRol: 'tecnico',
      texto: 'Puedo ir mañana a las 10.',
      contactoOculto: false,
      enviadoEn: DateTime.utc(2026, 11, 21, 18, 5),
    ),
    Mensaje(
      mensajeId: 'm1',
      autorRol: 'cliente',
      texto: 'Hola, tengo una fuga en la cocina.',
      contactoOculto: false,
      enviadoEn: DateTime.utc(2026, 11, 21, 18),
    ),
  ],
};

/// Hub de pruebas: `emitir` simula un evento del servidor y registra las
/// salas a las que se unió la app.
class ChatHubDePrueba implements ChatHub {
  final StreamController<EventoChat> _controlador =
      StreamController<EventoChat>.broadcast();
  final List<String> unidas = [];
  final List<String> salidas = [];
  bool conectado = false;

  void emitir(EventoChat evento) => _controlador.add(evento);

  @override
  Stream<EventoChat> get eventos => _controlador.stream;

  @override
  Future<void> conectar() async => conectado = true;

  @override
  Future<void> desconectar() async {
    conectado = false;
    await _controlador.close();
  }

  @override
  Future<ResultadoHub> unirseAConversacion(String conversacionId) async {
    unidas.add(conversacionId);
    return const ResultadoHub(ok: true);
  }

  @override
  Future<ResultadoHub> salirDeConversacion(String conversacionId) async {
    salidas.add(conversacionId);
    return const ResultadoHub(ok: true);
  }
}

/// Hub sin conexión: no entrega eventos. Es el valor por omisión hasta que se
/// evalúe el paquete de SignalR; el chat sigue funcionando por REST.
class ChatHubInactivo implements ChatHub {
  const ChatHubInactivo();

  @override
  Stream<EventoChat> get eventos => const Stream<EventoChat>.empty();

  @override
  Future<void> conectar() async {}

  @override
  Future<void> desconectar() async {}

  @override
  Future<ResultadoHub> unirseAConversacion(String conversacionId) async =>
      const ResultadoHub(ok: false, codigo: 'unavailable');

  @override
  Future<ResultadoHub> salirDeConversacion(String conversacionId) async =>
      const ResultadoHub(ok: true);
}
