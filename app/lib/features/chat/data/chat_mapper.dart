import 'package:app/core/datos/lectura_json.dart';
import 'package:app/features/chat/domain/chat.dart';
import 'package:app/features/chat/domain/chat_hub.dart';

/// Traduce el JSON de Mensajería (REST y eventos del hub) al dominio.
abstract final class ChatMapper {
  static ContraparteChat _contraparte(Object? json) {
    final mapa = LecturaJson.objeto(json);
    return ContraparteChat(
      nombre: LecturaJson.texto(mapa['nombre']),
      fotoUrl: LecturaJson.textoONulo(mapa['fotoUrl']),
    );
  }

  static UltimoMensaje? _ultimo(Object? json) {
    final mapa = LecturaJson.objetoONulo(json);
    if (mapa == null) {
      return null;
    }
    return UltimoMensaje(
      texto: LecturaJson.texto(mapa['texto']),
      enviadoEn: LecturaJson.fecha(mapa['enviadoEn']),
      autorRol: LecturaJson.texto(mapa['autorRol']),
    );
  }

  static ConversacionItem item(Object? json) {
    final mapa = LecturaJson.objeto(json);
    return ConversacionItem(
      conversacionId: LecturaJson.texto(mapa['conversacionId']),
      solicitudId: LecturaJson.texto(mapa['solicitudId']),
      visitaId: LecturaJson.textoONulo(mapa['visitaId']),
      rol: LecturaJson.texto(mapa['rol']),
      contraparte: _contraparte(mapa['contraparte']),
      servicio: LecturaJson.texto(mapa['servicio']),
      estado: LecturaJson.texto(mapa['estado']),
      ultimoMensaje: _ultimo(mapa['ultimoMensaje']),
      noLeidos: LecturaJson.entero(mapa['noLeidos']),
    );
  }

  static PaginaConversaciones pagina(Object? json) {
    final mapa = LecturaJson.objeto(json);
    return PaginaConversaciones(
      items: [for (final i in LecturaJson.lista(mapa['items'])) item(i)],
      totalNoLeidos: LecturaJson.entero(mapa['totalNoLeidos']),
      nextCursor: LecturaJson.textoONulo(mapa['nextCursor']),
    );
  }

  /// `avisoSeguridad` no tiene tipo cerrado en lo que se leyó del backend:
  /// acepta texto o booleano (con `true` usa un texto por omisión).
  static String? _aviso(Object? valor) {
    if (valor is String && valor.isNotEmpty) {
      return valor;
    }
    if (valor == true) {
      return 'Por tu seguridad, no compartas datos personales fuera de Knock.';
    }
    return null;
  }

  static Conversacion conversacion(Object? json) {
    final mapa = LecturaJson.objeto(json);
    return Conversacion(
      conversacionId: LecturaJson.texto(mapa['conversacionId']),
      solicitudId: LecturaJson.texto(mapa['solicitudId']),
      visitaId: LecturaJson.textoONulo(mapa['visitaId']),
      rol: LecturaJson.texto(mapa['rol']),
      contraparte: _contraparte(mapa['contraparte']),
      servicio: LecturaJson.texto(mapa['servicio']),
      estado: LecturaJson.texto(mapa['estado']),
      motivoCierre: LecturaJson.textoONulo(mapa['motivoCierre']),
      contactoVisible: LecturaJson.booleano(mapa['contactoVisible']),
      avisoSeguridad: _aviso(mapa['avisoSeguridad']),
      noLeidos: LecturaJson.entero(mapa['noLeidos']),
    );
  }

  static Mensaje mensaje(Object? json) {
    final mapa = LecturaJson.objeto(json);
    return Mensaje(
      mensajeId: LecturaJson.texto(mapa['mensajeId']),
      autorRol: LecturaJson.texto(mapa['autorRol']),
      texto: LecturaJson.texto(mapa['texto']),
      contactoOculto: LecturaJson.booleano(mapa['contactoOculto']),
      enviadoEn: LecturaJson.fecha(mapa['enviadoEn']),
    );
  }

  static PaginaMensajes paginaMensajes(Object? json) {
    final (items, cursor) = LecturaJson.pagina(json, mensaje, 'nextCursor');
    return PaginaMensajes(items: items, nextCursor: cursor);
  }

  /// Convierte un evento del hub (`nombre` y su argumento) a `EventoChat`.
  /// Devuelve `null` para eventos desconocidos.
  static EventoChat? evento(String nombre, Object? argumento) {
    final mapa = LecturaJson.objeto(argumento);
    switch (nombre) {
      case 'mensajeConversacion':
        return MensajeConversacionRecibido(
          conversacionId: LecturaJson.texto(mapa['conversacionId']),
          mensaje: mensaje(mapa),
        );
      case 'noLeidos':
        return NoLeidosActualizados(
          conversacionId: LecturaJson.texto(mapa['conversacionId']),
          noLeidos: LecturaJson.entero(mapa['noLeidos']),
          total: LecturaJson.entero(mapa['total']),
        );
      case 'mensaje':
        return MensajeVisitaRecibido(
          visitaId: LecturaJson.texto(mapa['visitaId']),
          mensajeId: LecturaJson.texto(mapa['mensajeId']),
          texto: LecturaJson.texto(mapa['texto']),
          enviadoEn: LecturaJson.fecha(mapa['enviadoEn']),
        );
      default:
        return null;
    }
  }
}
