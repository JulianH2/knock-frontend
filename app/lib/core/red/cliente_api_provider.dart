import 'package:app/core/red/cliente_api.dart';
import 'package:app/core/red/configuracion_api.dart';
import 'package:app/core/red/simulada/cliente_api_simulado.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Configuración de la API de esta ejecución (`--dart-define`). Las pruebas
/// la sobreescriben para elegir modo o escenario.
final configuracionApiProvider = Provider<ConfiguracionApi>(
  (ref) => ConfiguracionApi.desdeEntorno(),
);

/// Único punto de inyección de la red (spec §8 D8): los repositorios de
/// `data/` reciben de aquí su cliente. En modo simulado es la API simulada;
/// en modo real falla de forma explícita hasta que TT-MOB-03 conecte aquí el
/// cliente generado, sin caer nunca a la simulación.
final clienteApiProvider = Provider<ClienteApi>(
  (ref) => crearClienteApi(ref.watch(configuracionApiProvider)),
);

/// El cliente de una configuración. `main.dart` lo llama antes de `runApp`
/// para que una configuración inválida falle al arrancar.
///
/// Lanza [ErrorDeConfiguracionApi] en modo real (sin cliente real todavía) y
/// en release. La rama simulada va detrás de `kReleaseMode` constante para
/// que el compilador pueda quitarla de la build release (spec §8 D4).
ClienteApi crearClienteApi(ConfiguracionApi configuracion) {
  if (!kReleaseMode && configuracion.modo == ModoApi.simulado) {
    return ClienteApiSimulado(escenario: configuracion.escenario);
  }
  throw const ErrorDeConfiguracionApi(
    MotivoDeErrorDeConfiguracion.clienteRealNoDisponible,
  );
}
