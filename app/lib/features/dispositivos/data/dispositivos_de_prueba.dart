import 'package:app/core/errores/failure.dart';
import 'package:app/features/dispositivos/domain/dispositivo.dart';

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
