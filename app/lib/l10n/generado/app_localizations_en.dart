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
  String get entradaCelularTitulo => 'Sign in with your phone';

  @override
  String get entradaCelularDetalle =>
      'No passwords: just your number and a code.';

  @override
  String get entradaCelularEtiqueta => 'Phone number';

  @override
  String get entradaPrefijoPais => '+52';

  @override
  String get entradaCelularAyuda => 'We will send you a code by SMS';

  @override
  String get entradaCelularError => 'Enter the 10 digits of your phone number';

  @override
  String entradaAceptoAviso(String aviso) {
    return 'I accept the $aviso';
  }

  @override
  String get entradaAvisoPrivacidad => 'privacy notice';

  @override
  String get entradaAvisoError => 'Accept the privacy notice to continue';

  @override
  String get entradaContinuar => 'Continue';

  @override
  String get entradaCodigoTitulo => 'Enter the code';

  @override
  String entradaCodigoEnviadoA(String celular) {
    return 'We sent it to +52 $celular';
  }

  @override
  String get entradaCodigoEtiqueta => '6-digit code';

  @override
  String get entradaCodigoError => 'Enter the 6 digits of the code';

  @override
  String get entradaEntrar => 'Sign in';

  @override
  String entradaReenviarEn(int segundos) {
    return 'Resend in $segundos s';
  }

  @override
  String get entradaReenviarCodigo => 'Resend code';

  @override
  String get entradaCambiarNumero => 'Change number';

  @override
  String get entradaErrorCodigoIncorrecto =>
      'That code isn\'t right. Check it and try again.';

  @override
  String get entradaErrorCodigoVencido =>
      'The code has expired. Request a new one.';

  @override
  String get entradaErrorCelularRechazado =>
      'We couldn\'t use that number. Check it and try again.';

  @override
  String get entradaErrorCuentaSuspendida =>
      'Your account is suspended. If you think this is a mistake, contact us.';

  @override
  String get entradaErrorConflicto =>
      'This number is already linked to another account. Contact us so we can check it.';

  @override
  String get entradaErrorDatos =>
      'We couldn\'t process your sign-in. Please try again.';

  @override
  String get entradaErrorDemasiadosIntentos =>
      'Too many attempts. Wait a moment and try again.';

  @override
  String get entradaErrorSinConexion =>
      'We couldn\'t connect. Check your internet and try again.';

  @override
  String get entradaErrorVerificacionNoDisponible =>
      'SMS verification isn\'t available in this version of the app.';

  @override
  String get entradaErrorApiNoConfigurada =>
      'This version of the app has no server configured.';

  @override
  String get entradaErrorGenerico => 'Something went wrong. Please try again.';

  @override
  String get entradaCargando => 'Loading';
}
