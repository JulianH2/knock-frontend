import 'package:app/core/red/cliente_api.dart';

/// Peticiones de prueba a los contratos simulados (TT-MOB-08). Datos
/// ficticios: coordenadas de ejemplo y un token que no es JWT.
abstract final class PeticionesSimuladas {
  static const oficios = PeticionApi(metodo: 'GET', ruta: '/api/v1/oficios');

  static PeticionApi colonia({
    List<(String, String)> consulta = const [
      ('lat', '20.0543'),
      ('lon', '-99.3401'),
    ],
    bool conSesion = true,
  }) => PeticionApi(
    metodo: 'GET',
    ruta: '/api/v1/colonias/en-punto',
    consulta: consulta,
    encabezados: conSesion
        ? const {'Authorization': 'Bearer simulado-access-0001'}
        : const {},
  );

  /// Una petición válida y una o más inválidas por contrato: entre todas y con
  /// todos los escenarios producen cada respuesta simulada.
  static List<PeticionApi> todas() => [
    oficios,
    colonia(),
    colonia(conSesion: false),
    colonia(consulta: const [('lat', '91'), ('lon', '-99.3401')]),
    colonia(consulta: const [('lat', '20.0543'), ('lon', '1e2')]),
    colonia(consulta: const [('lat', '1'), ('lat', '2'), ('lon', '-99.3401')]),
  ];
}
