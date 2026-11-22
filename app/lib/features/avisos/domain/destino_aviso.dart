import 'package:app/core/router/rutas.dart';

/// A dónde lleva un aviso. La forma del `destino` no está cerrada en el
/// contrato (duda abierta): se aceptan `{tipo|recurso: visita|conversacion,
/// id}` y se ignora todo lo demás, así un destino desconocido solo marca el
/// aviso como leído y no rompe la pantalla.
abstract final class DestinoAviso {
  static final _idSeguro = RegExp(r'^[A-Za-z0-9_-]{1,64}$');

  /// Ruta de la app para el destino, o `null` si no hay destino o no se
  /// reconoce. Los identificadores se validan para no armar rutas con texto
  /// libre.
  static String? ruta(Map<String, Object?>? destino) {
    if (destino == null) {
      return null;
    }
    final tipo = destino['tipo'] ?? destino['recurso'];
    final id = destino['id'];
    if (tipo is! String || id is! String || !_idSeguro.hasMatch(id)) {
      return null;
    }
    return switch (tipo) {
      'visita' => '${Rutas.agenda}/$id',
      'conversacion' => '${Rutas.chats}/$id',
      _ => null,
    };
  }
}
