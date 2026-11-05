import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

/// Dónde vive la sesión en el teléfono (KNOCK-228, security-core #10).
///
/// Los tokens van **solo** al almacenamiento seguro del sistema (Keystore en
/// Android, Keychain en iOS); nunca a `shared_preferences` ni a los registros.
abstract interface class AlmacenSesion {
  /// Guarda el token de acceso y el de renovación que emitió la API.
  Future<void> guardarTokens({
    required String acceso,
    required String renovacion,
  });

  /// Si hay un token de renovación guardado.
  Future<bool> tieneSesion();

  /// Borra los tokens (cerrar sesión). Conserva el id del dispositivo.
  Future<void> borrarTokens();

  /// UUID del dispositivo para `deviceId`: se crea la primera vez y se reusa.
  Future<String> idDeDispositivo();
}

/// [AlmacenSesion] con `flutter_secure_storage`.
class AlmacenSesionSeguro implements AlmacenSesion {
  AlmacenSesionSeguro({
    this._almacen = const FlutterSecureStorage(),
    String Function()? nuevoId,
  }) : _nuevoId = nuevoId ?? const Uuid().v4;

  final FlutterSecureStorage _almacen;
  final String Function() _nuevoId;

  static const claveAcceso = 'knock.sesion.acceso';
  static const claveRenovacion = 'knock.sesion.renovacion';
  static const claveDispositivo = 'knock.dispositivo.id';

  @override
  Future<void> guardarTokens({
    required String acceso,
    required String renovacion,
  }) async {
    await _almacen.write(key: claveAcceso, value: acceso);
    await _almacen.write(key: claveRenovacion, value: renovacion);
  }

  @override
  Future<bool> tieneSesion() async {
    final renovacion = await _almacen.read(key: claveRenovacion);
    return renovacion != null && renovacion.isNotEmpty;
  }

  @override
  Future<void> borrarTokens() async {
    await _almacen.delete(key: claveAcceso);
    await _almacen.delete(key: claveRenovacion);
  }

  @override
  Future<String> idDeDispositivo() async {
    final guardado = await _almacen.read(key: claveDispositivo);
    if (guardado != null && guardado.isNotEmpty) return guardado;
    final nuevo = _nuevoId();
    await _almacen.write(key: claveDispositivo, value: nuevo);
    return nuevo;
  }
}
