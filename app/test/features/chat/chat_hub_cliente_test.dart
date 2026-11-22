import 'dart:async';

import 'package:app/features/chat/data/chat_hub_cliente.dart';
import 'package:app/features/chat/domain/chat_hub.dart';
import 'package:flutter_test/flutter_test.dart';

class _TransporteDePrueba implements TransporteHub {
  final _recibidos = StreamController<MensajeDeHub>.broadcast();
  final _cierres = StreamController<Object?>.broadcast();
  int fallosPendientes = 0;
  int iniciosIntentados = 0;
  final List<String> tokens = [];
  final List<(String, List<Object?>)> invocaciones = [];
  Object? respuesta = {'ok': true};

  @override
  Stream<MensajeDeHub> get recibidos => _recibidos.stream;

  @override
  Stream<Object?> get cierres => _cierres.stream;

  void servidorEmite(String nombre, Object? argumento) =>
      _recibidos.add(MensajeDeHub(nombre, argumento));

  void servidorCierra() => _cierres.add('cerrada');

  @override
  Future<void> iniciar(String token) async {
    iniciosIntentados++;
    if (fallosPendientes > 0) {
      fallosPendientes--;
      throw StateError('sin red');
    }
    tokens.add(token);
  }

  @override
  Future<void> detener() async {}

  @override
  Future<Object?> invocar(String metodo, List<Object?> argumentos) async {
    invocaciones.add((metodo, argumentos));
    return respuesta;
  }
}

Future<void> _soltar() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  test('retardoDeReconexion crece y topa en 30 s', () {
    expect(
      [for (var i = 1; i <= 8; i++) retardoDeReconexion(i).inSeconds],
      [1, 2, 4, 8, 16, 30, 30, 30],
    );
  });

  test('conecta, traduce eventos y se une a las salas', () async {
    final t = _TransporteDePrueba();
    final hub = ChatHubCliente(
      transporte: t,
      obtenerToken: () async => const TokenHub('jwt-1'),
    );
    addTearDown(hub.desconectar);
    final eventos = <EventoChat>[];
    hub.eventos.listen(eventos.add);
    await hub.conectar();
    expect(hub.conectado, isTrue);
    expect(t.tokens, ['jwt-1']);

    final r = await hub.unirseAConversacion('c1');
    expect(r.ok, isTrue);
    expect(t.invocaciones.last.$1, 'UnirseAConversacion');
    expect(t.invocaciones.last.$2, ['c1']);

    t.servidorEmite('noLeidos', {
      'conversacionId': 'c1',
      'noLeidos': 2,
      'total': 3,
    });
    t.servidorEmite('desconocido', {'a': 1});
    t.servidorEmite('noLeidos', {'mal': 'formado'});
    await _soltar();
    expect(eventos, hasLength(1));
    expect((eventos.single as NoLeidosActualizados).total, 3);
  });

  test('reintenta con espera creciente hasta conectar', () async {
    final t = _TransporteDePrueba()..fallosPendientes = 3;
    final esperas = <Duration>[];
    final hub = ChatHubCliente(
      transporte: t,
      obtenerToken: () async => const TokenHub('jwt'),
      esperar: (d) async => esperas.add(d),
    );
    addTearDown(hub.desconectar);
    await hub.conectar();
    expect(hub.conectado, isTrue);
    expect(esperas.map((d) => d.inSeconds), [1, 2, 4]);
  });

  test('sin token sigue reintentando y conecta cuando hay sesión', () async {
    final t = _TransporteDePrueba();
    var llamadas = 0;
    final hub = ChatHubCliente(
      transporte: t,
      obtenerToken: () async => ++llamadas < 3 ? null : const TokenHub('jwt'),
      esperar: (_) async {},
    );
    addTearDown(hub.desconectar);
    await hub.conectar();
    expect(llamadas, 3);
    expect(hub.conectado, isTrue);
  });

  test('tras una caída reconecta, se vuelve a unir y avisa', () async {
    final t = _TransporteDePrueba();
    var n = 0;
    final hub = ChatHubCliente(
      transporte: t,
      obtenerToken: () async => TokenHub('jwt-${++n}'),
      esperar: (_) async {},
    );
    addTearDown(hub.desconectar);
    final eventos = <EventoChat>[];
    hub.eventos.listen(eventos.add);
    await hub.conectar();
    await hub.unirseAConversacion('c1');
    await hub.unirseAVisita('v1');
    await hub.unirseAConversacion('c2');
    await hub.salirDeConversacion('c2');
    t.invocaciones.clear();

    t.fallosPendientes = 1;
    t.servidorCierra();
    await _soltar();
    expect(hub.conectado, isTrue);
    expect(t.tokens, ['jwt-1', 'jwt-3']);
    expect(t.invocaciones.map((i) => i.$1), [
      'UnirseAConversacion',
      'UnirseAVisita',
    ]);
    expect(t.invocaciones.first.$2, ['c1']);
    expect(eventos.whereType<ConexionRestablecida>(), hasLength(1));
  });

  test('las salas pedidas sin conexión se unen al conectar', () async {
    final t = _TransporteDePrueba();
    final hub = ChatHubCliente(
      transporte: t,
      obtenerToken: () async => const TokenHub('jwt'),
    );
    addTearDown(hub.desconectar);
    final r = await hub.unirseAConversacion('c1');
    expect(r.ok, isFalse);
    expect(r.codigo, 'unavailable');
    await hub.conectar();
    expect(t.invocaciones.single.$1, 'UnirseAConversacion');
    expect(t.invocaciones.single.$2, ['c1']);
  });

  test('una sala rechazada por el servidor no se vuelve a intentar', () async {
    final t = _TransporteDePrueba();
    final hub = ChatHubCliente(
      transporte: t,
      obtenerToken: () async => const TokenHub('jwt'),
      esperar: (_) async {},
    );
    addTearDown(hub.desconectar);
    await hub.conectar();
    t.respuesta = {'ok': false, 'codigo': 'conversation_unavailable'};
    final r = await hub.unirseAConversacion('c9');
    expect(r.codigo, 'conversation_unavailable');
    t.invocaciones.clear();
    await hub.renovarSesion();
    expect(t.invocaciones, isEmpty);
  });

  test(
    'EnviarMensaje de visita devuelve el ChatResult con el límite',
    () async {
      final t = _TransporteDePrueba();
      final hub = ChatHubCliente(
        transporte: t,
        obtenerToken: () async => const TokenHub('jwt'),
      );
      addTearDown(hub.desconectar);
      await hub.conectar();
      t.respuesta = {
        'ok': false,
        'codigo': 'message_limit',
        'reintentarEnSegundos': 12,
      };
      final r = await hub.enviarMensajeVisita('v1', 'hola');
      expect(t.invocaciones.last.$1, 'EnviarMensaje');
      expect(t.invocaciones.last.$2, ['v1', 'hola']);
      expect(r.codigo, 'message_limit');
      expect(r.reintentarEnSegundos, 12);
    },
  );

  test('antes de vencer el token se reconecta con uno nuevo', () async {
    final t = _TransporteDePrueba();
    var n = 0;
    final hub = ChatHubCliente(
      transporte: t,
      obtenerToken: () async => TokenHub(
        'jwt-${++n}',
        venceEn: DateTime.now().toUtc().add(const Duration(milliseconds: 60)),
      ),
      margenDeToken: Duration.zero,
    );
    addTearDown(hub.desconectar);
    await hub.conectar();
    expect(t.tokens, ['jwt-1']);
    await Future<void>.delayed(const Duration(milliseconds: 150));
    expect(t.tokens.length, greaterThanOrEqualTo(2));
    expect(t.tokens[1], 'jwt-2');
  });

  test('desconectar cierra el flujo y no reconecta', () async {
    final t = _TransporteDePrueba();
    final hub = ChatHubCliente(
      transporte: t,
      obtenerToken: () async => const TokenHub('jwt'),
      esperar: (_) async {},
    );
    await hub.conectar();
    await hub.desconectar();
    expect(hub.conectado, isFalse);
    t.servidorCierra();
    await _soltar();
    expect(t.iniciosIntentados, 1);
  });

  test('el transporte inactivo nunca conecta', () async {
    const t = TransporteHubInactivo();
    await expectLater(t.iniciar('x'), throwsStateError);
    await expectLater(t.invocar('a', const []), throwsStateError);
  });
}
