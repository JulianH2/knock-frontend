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
  String get entradaCelularTitulo => 'Entra con tu celular';

  @override
  String get entradaCelularDetalle =>
      'Sin contraseñas: solo tu número y un código.';

  @override
  String get entradaCelularEtiqueta => 'Celular';

  @override
  String get entradaPrefijoPais => '+52';

  @override
  String get entradaCelularAyuda => 'Te enviaremos un código por SMS';

  @override
  String get entradaCelularError => 'Escribe los 10 dígitos de tu celular';

  @override
  String entradaAceptoAviso(String aviso) {
    return 'Acepto el $aviso';
  }

  @override
  String get entradaAvisoPrivacidad => 'aviso de privacidad';

  @override
  String get entradaAvisoError =>
      'Acepta el aviso de privacidad para continuar';

  @override
  String get entradaContinuar => 'Continuar';

  @override
  String get entradaCodigoTitulo => 'Escribe el código';

  @override
  String entradaCodigoEnviadoA(String celular) {
    return 'Lo enviamos al +52 $celular';
  }

  @override
  String get entradaCodigoEtiqueta => 'Código de 6 dígitos';

  @override
  String get entradaCodigoError => 'Escribe los 6 dígitos del código';

  @override
  String get entradaEntrar => 'Entrar';

  @override
  String entradaReenviarEn(int segundos) {
    return 'Reenviar en $segundos s';
  }

  @override
  String get entradaReenviarCodigo => 'Reenviar código';

  @override
  String get entradaCambiarNumero => 'Cambiar número';

  @override
  String get entradaErrorCodigoIncorrecto =>
      'El código no es correcto. Revísalo e inténtalo otra vez.';

  @override
  String get entradaErrorCodigoVencido =>
      'El código ya venció. Pide uno nuevo.';

  @override
  String get entradaErrorCelularRechazado =>
      'No pudimos usar ese número. Revísalo e inténtalo otra vez.';

  @override
  String get entradaErrorCuentaSuspendida =>
      'Tu cuenta está suspendida. Si crees que es un error, escríbenos.';

  @override
  String get entradaErrorConflicto =>
      'Este número ya está ligado a otra cuenta. Escríbenos para revisarlo.';

  @override
  String get entradaErrorDatos =>
      'No pudimos procesar la entrada. Inténtalo otra vez.';

  @override
  String get entradaErrorDemasiadosIntentos =>
      'Hiciste muchos intentos. Espera un momento y vuelve a intentarlo.';

  @override
  String get entradaErrorSinConexion =>
      'No pudimos conectarnos. Revisa tu internet e inténtalo otra vez.';

  @override
  String get entradaErrorVerificacionNoDisponible =>
      'La verificación por SMS no está disponible en esta versión de la app.';

  @override
  String get entradaErrorApiNoConfigurada =>
      'Esta versión de la app no tiene configurado el servidor.';

  @override
  String get entradaErrorGenerico => 'Algo salió mal. Inténtalo otra vez.';

  @override
  String get entradaCargando => 'Cargando';
}
