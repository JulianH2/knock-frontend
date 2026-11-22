import 'package:app/core/errores/failure.dart';

/// Técnico de la visita (`VisitTechnician`). El teléfono y el WhatsApp solo
/// llegan cuando el servidor los autoriza.
class VisitaTecnico {
  const VisitaTecnico({
    required this.nombre,
    required this.verificado,
    required this.nivelVerificacion,
    this.fotoUrl,
    this.telefono,
    this.whatsapp,
  });

  final String nombre;
  final String? fotoUrl;
  final bool verificado;
  final String nivelVerificacion;
  final String? telefono;
  final String? whatsapp;
}

class VisitaLugar {
  const VisitaLugar({required this.tipo, this.direccion});

  final String tipo;
  final String? direccion;
}

/// Detalle de una visita (`VisitResponse`). `dia` y `hora` ya vienen listos
/// para mostrar.
class Visita {
  const Visita({
    required this.id,
    required this.rol,
    required this.estado,
    required this.modalidad,
    required this.dia,
    required this.hora,
    required this.tope,
    required this.lugar,
    required this.puedeLlegar,
    this.precio,
    this.tecnico,
    this.coloniaCliente,
    this.codigo,
    this.codigoVenceEn,
    this.motivoCodigo,
    this.reglaSeguridad,
    this.puedeAvisar,
    this.llegadaEn,
  });

  final String id;

  /// Rol de la persona en la visita: `cliente` o `tecnico`.
  final String rol;
  final String estado;
  final String modalidad;
  final String dia;
  final String hora;
  final int? precio;
  final int tope;
  final VisitaTecnico? tecnico;

  /// Colonia del cliente (`cliente.colonia`); nunca la dirección.
  final String? coloniaCliente;
  final VisitaLugar lugar;
  final String? codigo;
  final DateTime? codigoVenceEn;
  final String? motivoCodigo;
  final String? reglaSeguridad;
  final bool? puedeAvisar;
  final bool puedeLlegar;
  final DateTime? llegadaEn;
}

/// Fila de la agenda (`AgendaItem`).
class AgendaItem {
  const AgendaItem({
    required this.id,
    required this.estado,
    required this.modalidad,
    required this.fechaHora,
    required this.dia,
    required this.hora,
    this.precio,
  });

  final String id;
  final String estado;
  final String modalidad;
  final DateTime fechaHora;
  final String dia;
  final String hora;
  final int? precio;
}

class PaginaAgenda {
  const PaginaAgenda({required this.items, this.nextCursor});

  final List<AgendaItem> items;
  final String? nextCursor;
}

/// Respuesta de `POST /visitas/{id}/reprogramar`.
class PropuestaReprogramacion {
  const PropuestaReprogramacion({
    required this.visitaId,
    required this.fechaHora,
    required this.propuestaPor,
    required this.venceEn,
  });

  final String visitaId;
  final DateTime fechaHora;
  final String propuestaPor;
  final DateTime venceEn;
}

/// Respuesta de `POST /visitas/{id}/reprogramar/respuesta`.
class RespuestaReprogramacion {
  const RespuestaReprogramacion({
    required this.visitaId,
    required this.aceptada,
    required this.fechaHora,
    required this.reprogramaciones,
  });

  final String visitaId;
  final bool aceptada;
  final DateTime fechaHora;
  final int reprogramaciones;
}

/// Respuesta de `POST /visitas/{id}/cancelar`; `tardia` marca la cancelación
/// fuera de plazo.
class ResultadoCancelacion {
  const ResultadoCancelacion({
    required this.visitaId,
    required this.estado,
    required this.tardia,
  });

  final String visitaId;
  final String estado;
  final bool tardia;
}

/// Respuesta de `POST /visitas/{id}/cliente-ausente`.
class ResultadoAusencia {
  const ResultadoAusencia({
    required this.visitaId,
    required this.estado,
    required this.quienFalto,
  });

  final String visitaId;
  final String estado;
  final String quienFalto;
}

/// Quita espacios y exige un motivo no vacío (hasta 500 caracteres; el límite
/// exacto no está en el contrato, es una cota prudente de la app).
String validarMotivoCancelacion(String motivo) {
  final limpio = motivo.trim();
  if (limpio.isEmpty || limpio.length > 500) {
    throw const DatosInvalidosFailure();
  }
  return limpio;
}

/// Visitas y agenda (Market, `/api/v1`). Muchas rutas aún no existen en el
/// gateway: una implementación real debe convertir ese 404 de ruta en
/// `RutaNoDisponibleFailure` y un 404 de recurso en `NoEncontradoFailure`.
abstract interface class VisitasRepository {
  /// `GET /agenda?Desde&Hasta&Cursor&Limite` (fechas `yyyy-MM-dd`; rango de
  /// 31 días como máximo; límite 1–50, 20 por omisión).
  Future<PaginaAgenda> agenda({
    DateTime? desde,
    DateTime? hasta,
    String? cursor,
    int limite = 20,
  });

  /// `GET /visitas/{id}`.
  Future<Visita> obtener(String id);

  /// `POST /visitas/{id}/reprogramar` con la nueva fecha y hora.
  Future<PropuestaReprogramacion> reprogramar(
    String id, {
    required DateTime fechaHora,
  });

  /// `POST /visitas/{id}/reprogramar/respuesta`.
  Future<RespuestaReprogramacion> responderReprogramacion(
    String id, {
    required bool acepta,
  });

  /// `POST /visitas/{id}/cancelar`.
  Future<ResultadoCancelacion> cancelar(String id, {required String motivo});

  /// `POST /visitas/{id}/cliente-ausente` («no se presentó»).
  Future<ResultadoAusencia> noSePresento(String id);
}
