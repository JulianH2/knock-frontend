import 'package:app/features/avisos/domain/aviso.dart';

/// Fuente de los avisos de la app (`/api/v1/avisos`). Falla con un `Failure`
/// de `core/errores`.
abstract interface class AvisosRepository {
  /// `GET /avisos?cursor&limite&leido&comoRol` (límite 1–50, 20 por omisión).
  Future<PaginaAvisos> listar({
    String? cursor,
    int limite = 20,
    FiltroAvisos filtro = const FiltroAvisos(),
  });

  /// `GET /avisos/no-leidos/contador`.
  Future<ContadorAvisos> contador();

  /// `POST /avisos/{id}/leido` (repetirlo es válido).
  Future<void> marcarLeido(String id);

  /// `POST /avisos/leidos`: marca todos los propios.
  Future<void> marcarTodosLeidos();
}
