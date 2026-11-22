import 'dart:convert';

import 'package:app/core/errores/failure.dart';

/// Con quién se habla. Sin teléfono, correo ni dirección: no viajan.
class ContraparteChat {
  const ContraparteChat({required this.nombre, this.fotoUrl});

  final String nombre;
  final String? fotoUrl;
}

class UltimoMensaje {
  const UltimoMensaje({
    required this.texto,
    required this.enviadoEn,
    required this.autorRol,
  });

  final String texto;
  final DateTime enviadoEn;
  final String autorRol;
}

/// Fila de la lista de conversaciones (`ConversacionItem`).
class ConversacionItem {
  const ConversacionItem({
    required this.conversacionId,
    required this.solicitudId,
    required this.rol,
    required this.contraparte,
    required this.servicio,
    required this.estado,
    required this.noLeidos,
    this.visitaId,
    this.ultimoMensaje,
  });

  final String conversacionId;
  final String solicitudId;
  final String? visitaId;
  final String rol;
  final ContraparteChat contraparte;
  final String servicio;
  final String estado;
  final UltimoMensaje? ultimoMensaje;
  final int noLeidos;

  ConversacionItem copiar({int? noLeidos, UltimoMensaje? ultimoMensaje}) =>
      ConversacionItem(
        conversacionId: conversacionId,
        solicitudId: solicitudId,
        visitaId: visitaId,
        rol: rol,
        contraparte: contraparte,
        servicio: servicio,
        estado: estado,
        ultimoMensaje: ultimoMensaje ?? this.ultimoMensaje,
        noLeidos: noLeidos ?? this.noLeidos,
      );
}

class PaginaConversaciones {
  const PaginaConversaciones({
    required this.items,
    required this.totalNoLeidos,
    this.nextCursor,
  });

  final List<ConversacionItem> items;
  final int totalNoLeidos;
  final String? nextCursor;
}

/// Detalle de una conversación (`ConversacionView`).
class Conversacion {
  const Conversacion({
    required this.conversacionId,
    required this.solicitudId,
    required this.rol,
    required this.contraparte,
    required this.servicio,
    required this.estado,
    required this.contactoVisible,
    required this.noLeidos,
    this.visitaId,
    this.motivoCierre,
    this.avisoSeguridad,
  });

  final String conversacionId;
  final String solicitudId;
  final String? visitaId;

  /// Rol de la persona en esta conversación: `cliente` o `tecnico`.
  final String rol;
  final ContraparteChat contraparte;
  final String servicio;
  final String estado;
  final String? motivoCierre;
  final bool contactoVisible;

  /// Texto del aviso de seguridad, si la API lo manda.
  final String? avisoSeguridad;
  final int noLeidos;

  /// Cerrada: la API la reporta con motivo de cierre o estado `cerrada`.
  bool get cerrada => motivoCierre != null || estado == 'cerrada';
}

class Mensaje {
  const Mensaje({
    required this.mensajeId,
    required this.autorRol,
    required this.texto,
    required this.contactoOculto,
    required this.enviadoEn,
  });

  final String mensajeId;
  final String autorRol;
  final String texto;

  /// Verdadero si se reemplazó un dato de contacto del texto.
  final bool contactoOculto;
  final DateTime enviadoEn;
}

class PaginaMensajes {
  const PaginaMensajes({required this.items, this.nextCursor});

  /// Más reciente primero.
  final List<Mensaje> items;
  final String? nextCursor;
}

/// Tope del cuerpo de un mensaje (bytes UTF-8), igual que el servidor.
const int maxBytesMensaje = 4096;

/// Valida el texto antes de enviarlo: no vacío y hasta 4096 bytes. Falla con
/// `DatosInvalidosFailure`; devuelve el texto sin espacios en los extremos.
String validarTextoMensaje(String texto) {
  final limpio = texto.trim();
  if (limpio.isEmpty || utf8.encode(limpio).length > maxBytesMensaje) {
    throw const DatosInvalidosFailure();
  }
  return limpio;
}

/// Conversaciones y mensajes (`/api/v1/conversaciones`). Falla con un
/// `Failure`; los códigos de dominio (`content_rejected`, `message_limit`,
/// `conversation_closed`, `moderation_unavailable`) llegan como
/// `ReglaDeNegocioFailure`, `LimiteDePeticionesFailure` o
/// `ServicioNoDisponibleFailure` con su `codigo`.
abstract interface class ConversacionesRepository {
  /// `GET /` (límite 1–20, 20 por omisión).
  Future<PaginaConversaciones> listar({String? cursor, int limite = 20});

  /// `GET /no-leidas`.
  Future<int> noLeidas();

  /// `GET /{id}`: ajena o inexistente = `NoEncontradoFailure`.
  Future<Conversacion> obtener(String id);

  /// `GET /{id}/mensajes` (límite 1–50, 30 por omisión), más reciente primero.
  Future<PaginaMensajes> mensajes(String id, {String? cursor, int limite = 30});

  /// `POST /{id}/mensajes`.
  Future<Mensaje> enviar(String id, String texto);

  /// `POST /{id}/leido` con la fecha del último mensaje visto.
  Future<void> marcarLeido(String id, {required DateTime hasta});
}
