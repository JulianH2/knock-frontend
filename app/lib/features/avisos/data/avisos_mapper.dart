import 'package:app/core/datos/lectura_json.dart';
import 'package:app/features/avisos/domain/aviso.dart';
import 'package:app/features/avisos/domain/preferencias_avisos.dart';

/// Traduce el JSON del contrato de avisos a los modelos del dominio.
abstract final class AvisosMapper {
  static Aviso aviso(Object? json) {
    final mapa = LecturaJson.objeto(json);
    return Aviso(
      id: LecturaJson.texto(mapa['id']),
      tipo: LecturaJson.texto(mapa['tipo']),
      comoRol: LecturaJson.texto(mapa['comoRol']),
      titulo: LecturaJson.texto(mapa['titulo']),
      texto: LecturaJson.texto(mapa['texto']),
      destino: LecturaJson.objetoONulo(mapa['destino']),
      leido: LecturaJson.booleano(mapa['leido']),
      creadoEn: LecturaJson.fecha(mapa['creadoEn']),
    );
  }

  static PaginaAvisos pagina(Object? json) {
    final mapa = LecturaJson.objeto(json);
    return PaginaAvisos(
      items: [for (final i in LecturaJson.lista(mapa['items'])) aviso(i)],
      siguienteCursor: LecturaJson.textoONulo(mapa['siguienteCursor']),
    );
  }

  static ContadorAvisos contador(Object? json) {
    final mapa = LecturaJson.objeto(json);
    return ContadorAvisos(
      cantidad: LecturaJson.entero(mapa['cantidad']),
      masDe99: LecturaJson.booleano(mapa['masDe99']),
    );
  }

  static List<PreferenciaAviso> preferencias(Object? json) {
    final mapa = LecturaJson.objeto(json);
    return [
      for (final i in LecturaJson.lista(mapa['tipos']))
        _preferencia(LecturaJson.objeto(i)),
    ];
  }

  static PreferenciaAviso _preferencia(Map<String, Object?> mapa) {
    final apagable = LecturaJson.booleano(mapa['apagable']);
    final activo = LecturaJson.booleano(mapa['activo']);
    return PreferenciaAviso(
      tipo: LecturaJson.texto(mapa['tipo']),
      // Lo que no se puede apagar siempre está activo.
      activo: apagable ? activo : true,
      apagable: apagable,
    );
  }
}
