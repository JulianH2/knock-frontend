import 'package:app/core/red/cliente_api.dart';
import 'package:flutter/foundation.dart';

/// De dónde salen las respuestas de la API.
enum ModoApi {
  /// API simulada en memoria (solo fuera de release).
  simulado,

  /// API real en [ConfiguracionApi.baseUrl] (cliente de TT-MOB-03).
  real,
}

/// Escenario de la API simulada (`KNOCK_API_ESCENARIO`, spec §5). Un
/// escenario que no aplica a un endpoint deja ese endpoint en [normal].
enum EscenarioApi {
  normal('normal'),
  vacio('vacio'),
  errorServidor('error_servidor'),
  sinConexion('sin_conexion'),
  lento('lento'),
  noAutorizado('no_autorizado'),
  fueraDeCobertura('fuera_de_cobertura'),
  limite('limite');

  const EscenarioApi(this.clave);

  /// Valor de `--dart-define`.
  final String clave;

  /// El escenario de esa clave, o `null` si no existe.
  static EscenarioApi? desdeClave(String clave) {
    for (final escenario in values) {
      if (escenario.clave == clave) {
        return escenario;
      }
    }
    return null;
  }
}

/// Configuración de la API leída de `--dart-define` (spec §8 D3):
/// `KNOCK_API_URL` (origen sin ruta) y `KNOCK_API_ESCENARIO` (solo simulado).
final class ConfiguracionApi {
  const ConfiguracionApi._(this.modo, this.baseUrl, this.escenario);

  /// Valida los valores recibidos. Lanza [ErrorDeConfiguracionApi] si no se
  /// permiten; nunca cae en silencio al modo simulado.
  ///
  /// - [url] vacía fuera de release → simulado; en release → error.
  /// - `https://<host>[:puerto]` → real con ese origen.
  /// - `http://` solo hacia [hostsLocales] y nunca en release.
  /// - Cualquier otra cosa (otro esquema, usuario y clave, ruta distinta de
  ///   `/`, consulta, fragmento o mal formada) → error.
  /// - [escenario] solo en modo simulado y con una clave de [EscenarioApi].
  factory ConfiguracionApi.desde({
    required String url,
    required String escenario,
    required bool esRelease,
  }) {
    if (url.isEmpty) {
      if (esRelease) {
        throw const ErrorDeConfiguracionApi(
          MotivoDeErrorDeConfiguracion.releaseSinUrl,
        );
      }
      return ConfiguracionApi._(
        ModoApi.simulado,
        null,
        _escenarioSimulado(escenario),
      );
    }
    final origen = _origenPermitido(url, esRelease: esRelease);
    if (escenario.isNotEmpty) {
      throw const ErrorDeConfiguracionApi(
        MotivoDeErrorDeConfiguracion.escenarioNoPermitido,
      );
    }
    return ConfiguracionApi._(ModoApi.real, origen, EscenarioApi.normal);
  }

  /// La de esta compilación (`--dart-define` y `kReleaseMode`).
  factory ConfiguracionApi.desdeEntorno() => ConfiguracionApi.desde(
    url: const String.fromEnvironment('KNOCK_API_URL'),
    escenario: const String.fromEnvironment('KNOCK_API_ESCENARIO'),
    esRelease: kReleaseMode,
  );

  /// Hosts a los que se permite `http://` fuera de release (máquina local y
  /// el anfitrión visto desde el emulador de Android).
  static const hostsLocales = {'127.0.0.1', 'localhost', '10.0.2.2'};

  final ModoApi modo;

  /// Origen (esquema, host y puerto) en modo real; `null` en simulado.
  final Uri? baseUrl;

  /// Escenario de la simulación; [EscenarioApi.normal] en modo real.
  final EscenarioApi escenario;

  /// Sin el origen: no se registra ni se muestra.
  @override
  String toString() => 'ConfiguracionApi(${modo.name})';

  static EscenarioApi _escenarioSimulado(String clave) {
    if (clave.isEmpty) {
      return EscenarioApi.normal;
    }
    return EscenarioApi.desdeClave(clave) ??
        (throw const ErrorDeConfiguracionApi(
          MotivoDeErrorDeConfiguracion.escenarioNoPermitido,
        ));
  }

  static Uri _origenPermitido(String url, {required bool esRelease}) {
    const noPermitida = ErrorDeConfiguracionApi(
      MotivoDeErrorDeConfiguracion.urlNoPermitida,
    );
    final uri = Uri.tryParse(url);
    if (uri == null ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        (uri.path.isNotEmpty && uri.path != '/') ||
        url.contains(RegExp(r'\s'))) {
      throw noPermitida;
    }
    final esHttpLocal =
        uri.scheme == 'http' && !esRelease && hostsLocales.contains(uri.host);
    if (uri.scheme != 'https' && !esHttpLocal) {
      throw noPermitida;
    }
    if (uri.hasPort && (uri.port < 1 || uri.port > 65535)) {
      throw noPermitida;
    }
    return Uri(
      scheme: uri.scheme,
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
    );
  }
}
