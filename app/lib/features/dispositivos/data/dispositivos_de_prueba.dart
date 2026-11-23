import 'package:app/core/errores/failure.dart';
import 'package:app/features/dispositivos/domain/dispositivo.dart';
import 'package:app/features/dispositivos/domain/permiso_notificaciones.dart';

/// Dispositivos en memoria. `falla` simula el 503 del push deshabilitado u
/// otro error; cuenta las llamadas para comprobar que no hay reintentos.
class DispositivosRepositoryDePrueba implements DispositivosRepository {
  DispositivosRepositoryDePrueba({this.falla});

  final Failure? falla;
  final Map<String, String> _porIdentificador = {};
  int llamadas = 0;

  @override
  Future<RegistroDispositivo> registrar({
    required String identificador,
    required PlataformaDispositivo plataforma,
  }) async {
    llamadas++;
    final error = falla;
    if (error != null) {
      throw error;
    }
    final valido = validarIdentificadorDispositivo(identificador);
    final existente = _porIdentificador[valido];
    if (existente != null) {
      return RegistroDispositivo(id: existente, nuevo: false);
    }
    final id = 'dispositivo-${_porIdentificador.length + 1}';
    _porIdentificador[valido] = id;
    return RegistroDispositivo(id: id, nuevo: true);
  }

  @override
  Future<void> darDeBaja(String id) async {
    llamadas++;
    final error = falla;
    if (error != null) {
      throw error;
    }
    _porIdentificador.removeWhere((_, valor) => valor == id);
  }
}

/// Token ficticio; `null` simula que la persona no dio permiso.
class ProveedorTokenPushDePrueba implements ProveedorTokenPush {
  const ProveedorTokenPushDePrueba([this.token = 'token-ficticio-0001']);

  final String? token;

  @override
  Future<String?> obtener() async => token;
}

/// Permiso ficticio en memoria. `alSolicitar` es lo que responde el «sistema»
/// al pedir permiso; `ajustesAbiertos` cuenta las veces que se abrió Ajustes.
class PermisoNotificacionesDePrueba implements PermisoNotificaciones {
  PermisoNotificacionesDePrueba({
    this.actual = EstadoPermiso.noPreguntado,
    this.alSolicitar = EstadoPermiso.concedido,
  });

  EstadoPermiso actual;
  final EstadoPermiso alSolicitar;
  int solicitudes = 0;
  int ajustesAbiertos = 0;

  @override
  Future<EstadoPermiso> estado() async => actual;

  @override
  Future<EstadoPermiso> solicitar() async {
    solicitudes++;
    actual = alSolicitar;
    return actual;
  }

  @override
  Future<bool> abrirAjustes() async {
    ajustesAbiertos++;
    return true;
  }
}
