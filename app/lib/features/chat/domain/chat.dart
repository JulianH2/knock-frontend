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

  /// La misma conversación marcada como cerrada (cuando un envío responde
  /// `conversation_closed`).
  Conversacion comoCerrada() => Conversacion(
    conversacionId: conversacionId,
    solicitudId: solicitudId,
    visitaId: visitaId,
    rol: rol,
    contraparte: contraparte,
    servicio: servicio,
    estado: 'cerrada',
    motivoCierre: motivoCierre ?? 'cerrada',
    contactoVisible: contactoVisible,
    avisoSeguridad: avisoSeguridad,
    noLeidos: noLeidos,
  );
}

/// Aviso que se muestra siempre en el chat si la API no manda uno propio.
const String avisoSeguridadPorOmision =
    'Por tu seguridad, no pagues por adelantado ni compartas datos personales '
    'fuera de Knock.';

/// Resultado de crear o recuperar la conversación del par (solicitud, técnico).
class ConversacionCreada {
  const ConversacionCreada({required this.conversacion, required this.nueva});

  final Conversacion conversacion;

  /// `true` si fue 201 (primera vez); `false` si ya existía (200).
  final bool nueva;
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

/// Tope de caracteres de un mensaje ya recortado (`ReglasDeMensaje.MaxCaracteres`
/// del servidor, contados como unidades UTF-16 igual que `String.Length`).
const int maxCaracteresMensaje = 1000;

/// Bytes UTF-8 del texto ya recortado (lo que cuenta el servidor).
int bytesDeMensaje(String texto) => utf8.encode(texto.trim()).length;

/// `true` si el texto, ya recortado, supera 1000 caracteres o 4096 bytes.
bool mensajeDemasiadoLargo(String texto) =>
    texto.trim().length > maxCaracteresMensaje ||
    bytesDeMensaje(texto) > maxBytesMensaje;

bool _tieneControl(String texto) => texto.codeUnits.any(
  (c) => (c < 0x20 && c != 0x0A) || (c >= 0x7F && c <= 0x9F),
);

/// Valida el texto antes de enviarlo con la regla del servidor: de 1 a 1000
/// caracteres, hasta 4096 bytes y sin caracteres de control salvo el salto de
/// línea. Falla con `DatosInvalidosFailure`; devuelve el texto sin espacios en
/// los extremos.
String validarTextoMensaje(String texto) {
  final limpio = texto.trim();
  if (limpio.isEmpty ||
      mensajeDemasiadoLargo(limpio) ||
      _tieneControl(limpio)) {
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

  /// `POST /` con la solicitud y, si quien llama es el cliente, el técnico:
  /// 201 primera vez, 200 si ya existía; 409 `conversation_closed`.
  Future<ConversacionCreada> crear({
    required String solicitudId,
    String? tecnicoId,
  });

  /// `POST /{id}/leido` con la fecha del último mensaje visto.
  Future<void> marcarLeido(String id, {required DateTime hasta});
}
