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

/// Fuente de las preferencias.
abstract interface class PreferenciasAvisosRepository {
  Future<List<PreferenciaAviso>> obtener();

  /// `PUT /me/preferencias-avisos` con `{ tipos: [{ tipo, activo }] }`, solo los
  /// tipos que cambian. Falla con `DatosInvalidosFailure` (422) si se intenta
  /// apagar un tipo no apagable. Si falla, los cambios quedan pendientes.
  Future<void> guardar(List<PreferenciaAviso> preferencias);
}
