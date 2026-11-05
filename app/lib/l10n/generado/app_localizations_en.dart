// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Knock';

  @override
  String get tabInicio => 'Home';

  @override
  String get tabExplorar => 'Explore';

  @override
  String get explorarOficios => 'Trades';

  @override
  String get tabActividad => 'Activity';

  @override
  String get tabTrabajo => 'Work';

  @override
  String get tabCuenta => 'My account';

  @override
  String get pruebaModoTecnico => 'Technician mode (test)';

  @override
  String get configuracionTitulo => 'Settings';

  @override
  String get configuracionIdioma => 'Language';

  @override
  String get configuracionIdiomaEspanol => 'Español';

  @override
  String get configuracionIdiomaIngles => 'English';

  @override
  String get configuracionTema => 'Theme';

  @override
  String get configuracionTemaAutomatico => 'Automatic';

  @override
  String get configuracionTemaAutomaticoDetalle => 'Same as your phone';

  @override
  String get configuracionTemaClaro => 'Light';

  @override
  String get configuracionTemaOscuro => 'Dark';

  @override
  String get errorSinConexion =>
      'We couldn\'t reach Knock. Check your connection and try again.';

  @override
  String get errorSesionVencida =>
      'Your session is no longer valid. Please sign in again.';

  @override
  String get errorCuentaSuspendida =>
      'Your account is suspended. Contact support if you think this is a mistake.';

  @override
  String get errorAccesoDenegado => 'You don\'t have permission to do this.';

  @override
  String get errorConflicto =>
      'This action conflicts with another account or the current state. Check the data and try again.';

  @override
  String get errorDatosRechazados =>
      'Check the information you entered and try again.';

  @override
  String get errorDemasiadosIntentos =>
      'Too many attempts. Wait a moment and try again.';

  @override
  String get errorDatosInvalidos =>
      'We received information we couldn\'t read. Please try again later.';

  @override
  String get errorApiNoConfigurada =>
      'The app isn\'t connected to a server. Install an official version.';

  @override
  String get errorInesperado => 'Something went wrong. Please try again.';
}
