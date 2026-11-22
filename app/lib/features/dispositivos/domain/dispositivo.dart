import 'package:app/core/errores/failure.dart';

/// Plataforma del dispositivo (`POST /dispositivos`).
enum PlataformaDispositivo {
  android,
  ios;

  String get valor => name;
}

/// Resultado de registrar: `nuevo` es verdadero con 201 y falso con 200.
class RegistroDispositivo {
  const RegistroDispositivo({required this.id, required this.nuevo});

  final String id;
  final bool nuevo;
}

/// Longitud máxima del identificador (token de push) según el contrato.
const int maxIdentificadorDispositivo = 4096;

/// Valida el identificador antes de enviarlo: no vacío, hasta 4096 caracteres
/// y sin caracteres de control. Falla con `DatosInvalidosFailure`.
String validarIdentificadorDispositivo(String identificador) {
  final limpio = identificador.trim();
  final hayControl = limpio.runes.any((r) => r < 0x20 || r == 0x7f);
  if (limpio.isEmpty ||
      limpio.length > maxIdentificadorDispositivo ||
      hayControl) {
    throw const DatosInvalidosFailure();
  }
  return limpio;
}

/// Registro y baja de dispositivos para push (`/api/v1/dispositivos`).
///
/// Mientras el push no esté habilitado en el servidor, ambas llamadas dan 503
/// (`ServicioNoDisponibleFailure`); la app no reintenta en bucle.
abstract interface class DispositivosRepository {
  /// `POST /dispositivos`: 201 nuevo, 200 ya existía, 409 conflicto.
  Future<RegistroDispositivo> registrar({
    required String identificador,
    required PlataformaDispositivo plataforma,
  });

  /// `DELETE /dispositivos/{id}`: 204 siempre (aunque ya no exista).
  Future<void> darDeBaja(String id);
}

/// Origen del token de push del dispositivo (Firebase Messaging cuando se
/// agregue el paquete). Devuelve `null` si la persona no dio permiso o no hay
/// token.
abstract interface class ProveedorTokenPush {
  Future<String?> obtener();
}
