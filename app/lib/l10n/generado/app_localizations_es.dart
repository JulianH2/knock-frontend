// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Knock';

  @override
  String get tabInicio => 'Inicio';

  @override
  String get tabExplorar => 'Explorar';

  @override
  String get explorarOficios => 'Oficios';

  @override
  String get tabActividad => 'Actividad';

  @override
  String get tabTrabajo => 'Trabajo';

  @override
  String get tabCuenta => 'Mi cuenta';

  @override
  String get pruebaModoTecnico => 'Modo técnico (prueba)';

  @override
  String get configuracionTitulo => 'Configuración';

  @override
  String get configuracionIdioma => 'Idioma';

  @override
  String get configuracionIdiomaEspanol => 'Español';

  @override
  String get configuracionIdiomaIngles => 'English';

  @override
  String get configuracionTema => 'Tema';

  @override
  String get configuracionTemaAutomatico => 'Automático';

  @override
  String get configuracionTemaAutomaticoDetalle => 'Igual que el teléfono';

  @override
  String get configuracionTemaClaro => 'Claro';

  @override
  String get configuracionTemaOscuro => 'Oscuro';

  @override
  String get errorSinConexion =>
      'No pudimos conectar con Knock. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get errorSesionVencida =>
      'Tu sesión ya no es válida. Inicia sesión de nuevo.';

  @override
  String get errorCuentaSuspendida =>
      'Tu cuenta está suspendida. Contacta a soporte si crees que es un error.';

  @override
  String get errorAccesoDenegado => 'No tienes permiso para hacer esto.';

  @override
  String get errorConflicto =>
      'Esta acción choca con otra cuenta o con el estado actual. Revisa los datos e inténtalo de nuevo.';

  @override
  String get errorDatosRechazados =>
      'Revisa los datos que escribiste e inténtalo de nuevo.';

  @override
  String get errorDemasiadosIntentos =>
      'Hiciste demasiados intentos. Espera un momento e inténtalo de nuevo.';

  @override
  String get errorDatosInvalidos =>
      'Recibimos información que no pudimos leer. Inténtalo más tarde.';

  @override
  String get errorApiNoConfigurada =>
      'La app no está conectada a un servidor. Instala una versión oficial.';

  @override
  String get errorInesperado => 'Algo salió mal. Inténtalo de nuevo.';
}
