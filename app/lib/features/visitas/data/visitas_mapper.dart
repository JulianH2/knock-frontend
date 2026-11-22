import 'package:app/core/datos/lectura_json.dart';
import 'package:app/features/visitas/domain/visita.dart';

/// Traduce el JSON de Market (`docs/openapi.v1.json`) a los modelos de visitas.
/// Los enteros pueden llegar como número o como cadena de dígitos.
abstract final class VisitasMapper {
  static VisitaTecnico _tecnico(Map<String, Object?> mapa) => VisitaTecnico(
    nombre: LecturaJson.texto(mapa['nombre']),
    fotoUrl: LecturaJson.textoONulo(mapa['fotoUrl']),
    verificado: LecturaJson.booleano(mapa['verificado']),
    nivelVerificacion: LecturaJson.texto(mapa['nivelVerificacion']),
    telefono: LecturaJson.textoONulo(mapa['telefono']),
    whatsapp: LecturaJson.textoONulo(mapa['whatsapp']),
  );

  static Visita visita(Object? json) {
    final mapa = LecturaJson.objeto(json);
    final tecnico = LecturaJson.objetoONulo(mapa['tecnico']);
    final cliente = LecturaJson.objetoONulo(mapa['cliente']);
    final lugar = LecturaJson.objeto(mapa['lugar']);
    return Visita(
      id: LecturaJson.texto(mapa['id']),
      rol: LecturaJson.texto(mapa['rol']),
      estado: LecturaJson.texto(mapa['estado']),
      modalidad: LecturaJson.texto(mapa['modalidad']),
      dia: LecturaJson.texto(mapa['dia']),
      hora: LecturaJson.texto(mapa['hora']),
      precio: LecturaJson.enteroONulo(mapa['precio']),
      tope: LecturaJson.entero(mapa['tope']),
      tecnico: tecnico == null ? null : _tecnico(tecnico),
      coloniaCliente: cliente == null
          ? null
          : LecturaJson.texto(cliente['colonia']),
      lugar: VisitaLugar(
        tipo: LecturaJson.texto(lugar['tipo']),
        direccion: LecturaJson.textoONulo(lugar['direccion']),
      ),
      codigo: LecturaJson.textoONulo(mapa['codigo']),
      codigoVenceEn: mapa['codigoVenceEn'] == null
          ? null
          : LecturaJson.fecha(mapa['codigoVenceEn']),
      motivoCodigo: LecturaJson.textoONulo(mapa['motivoCodigo']),
      reglaSeguridad: LecturaJson.textoONulo(mapa['reglaSeguridad']),
      puedeAvisar: LecturaJson.booleanoONulo(mapa['puedeAvisar']),
      puedeLlegar: LecturaJson.booleano(mapa['puedeLlegar']),
      llegadaEn: mapa['llegadaEn'] == null
          ? null
          : LecturaJson.fecha(mapa['llegadaEn']),
    );
  }

  static AgendaItem agendaItem(Object? json) {
    final mapa = LecturaJson.objeto(json);
    return AgendaItem(
      id: LecturaJson.texto(mapa['id']),
      estado: LecturaJson.texto(mapa['estado']),
      modalidad: LecturaJson.texto(mapa['modalidad']),
      fechaHora: LecturaJson.fecha(mapa['fechaHora']),
      dia: LecturaJson.texto(mapa['dia']),
      hora: LecturaJson.texto(mapa['hora']),
      precio: LecturaJson.enteroONulo(mapa['precio']),
    );
  }

  static PaginaAgenda agenda(Object? json) {
    final (items, cursor) = LecturaJson.pagina(json, agendaItem, 'nextCursor');
    return PaginaAgenda(items: items, nextCursor: cursor);
  }

  static PropuestaReprogramacion propuesta(Object? json) {
    final mapa = LecturaJson.objeto(json);
    return PropuestaReprogramacion(
      visitaId: LecturaJson.texto(mapa['visitaId']),
      fechaHora: LecturaJson.fecha(mapa['fechaHora']),
      propuestaPor: LecturaJson.texto(mapa['propuestaPor']),
      venceEn: LecturaJson.fecha(mapa['venceEn']),
    );
  }

  static RespuestaReprogramacion respuesta(Object? json) {
    final mapa = LecturaJson.objeto(json);
    final reprogramaciones = LecturaJson.entero(mapa['reprogramaciones']);
    final aceptada = LecturaJson.booleano(mapa['aceptada']);
    return RespuestaReprogramacion(
      visitaId: LecturaJson.texto(mapa['visitaId']),
      aceptada: aceptada,
      fechaHora: LecturaJson.fecha(mapa['fechaHora']),
      reprogramaciones: reprogramaciones,
    );
  }

  /// Lectura común de las respuestas que traen `visitaId` y `estado`.
  static T _conEstado<T>(
    Object? json,
    T Function(String visitaId, String estado, Map<String, Object?> mapa) crear,
  ) {
    final mapa = LecturaJson.objeto(json);
    return crear(
      LecturaJson.texto(mapa['visitaId']),
      LecturaJson.texto(mapa['estado']),
      mapa,
    );
  }

  static ResultadoCancelacion cancelacion(Object? json) => _conEstado(
    json,
    (id, estado, m) => ResultadoCancelacion(
      visitaId: id,
      estado: estado,
      tardia: LecturaJson.booleano(m['tardia']),
    ),
  );

  static ResultadoAusencia ausencia(Object? json) => _conEstado(
    json,
    (id, estado, m) => ResultadoAusencia(
      visitaId: id,
      estado: estado,
      quienFalto: LecturaJson.texto(m['quienFalto']),
    ),
  );
}
