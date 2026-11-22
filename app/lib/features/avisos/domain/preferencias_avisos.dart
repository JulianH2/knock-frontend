/// Una preferencia de avisos (`GET /me/preferencias-avisos`).
class PreferenciaAviso {
  const PreferenciaAviso({
    required this.tipo,
    required this.activo,
    required this.apagable,
  });

  final String tipo;
  final bool activo;

  /// La seguridad nunca se apaga: `apagable` es falso y `activo` verdadero.
  final bool apagable;

  PreferenciaAviso conActivo({required bool activo}) => PreferenciaAviso(
    tipo: tipo,
    activo: apagable ? activo : true,
    apagable: apagable,
  );
}

/// Fuente de las preferencias. Guardar (`PUT`, spec 037) aún no tiene ruta:
/// cuando exista se agrega `guardar` aquí y la pantalla ya tiene los
/// interruptores listos.
abstract interface class PreferenciasAvisosRepository {
  Future<List<PreferenciaAviso>> obtener();
}
