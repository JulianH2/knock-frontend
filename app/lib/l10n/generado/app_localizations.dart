import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generado/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// Nombre de la app (título de la tarea en el sistema). Es una marca: no se traduce.
  ///
  /// In es, this message translates to:
  /// **'Knock'**
  String get appTitle;

  /// Pestaña de la barra inferior y título de la pantalla de inicio.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get tabInicio;

  /// Pestaña de la barra inferior y título de la pantalla para buscar técnicos.
  ///
  /// In es, this message translates to:
  /// **'Explorar'**
  String get tabExplorar;

  /// Acceso temporal de Explorar a la pantalla de oficios (TT-PRU-02); lo reemplaza la historia de Explorar.
  ///
  /// In es, this message translates to:
  /// **'Oficios'**
  String get explorarOficios;

  /// Pestaña de la barra inferior y título de la pantalla con las solicitudes y su historial.
  ///
  /// In es, this message translates to:
  /// **'Actividad'**
  String get tabActividad;

  /// Pestaña de la barra inferior y título de la pantalla de trabajo; solo la ven los técnicos.
  ///
  /// In es, this message translates to:
  /// **'Trabajo'**
  String get tabTrabajo;

  /// Pestaña de la barra inferior y título de la pantalla con los datos y la configuración de la cuenta.
  ///
  /// In es, this message translates to:
  /// **'Mi cuenta'**
  String get tabCuenta;

  /// Interruptor de prueba (solo fuera de la versión de tienda) que da el rol de técnico.
  ///
  /// In es, this message translates to:
  /// **'Modo técnico (prueba)'**
  String get pruebaModoTecnico;

  /// Entrada de Mi cuenta y título de la pantalla para elegir idioma y tema.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get configuracionTitulo;

  /// Encabezado del selector de idioma en Configuración.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get configuracionIdioma;

  /// Opción del selector de idioma. Se escribe siempre en español, en cualquier idioma.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get configuracionIdiomaEspanol;

  /// Opción del selector de idioma. Se escribe siempre en inglés, en cualquier idioma.
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get configuracionIdiomaIngles;

  /// Encabezado del selector de tema en Configuración.
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get configuracionTema;

  /// Opción del selector de tema: seguir el tema claro u oscuro del teléfono.
  ///
  /// In es, this message translates to:
  /// **'Automático'**
  String get configuracionTemaAutomatico;

  /// Subtítulo de la opción Automático del selector de tema.
  ///
  /// In es, this message translates to:
  /// **'Igual que el teléfono'**
  String get configuracionTemaAutomaticoDetalle;

  /// Opción del selector de tema: tema claro.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get configuracionTemaClaro;

  /// Opción del selector de tema: tema oscuro.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get configuracionTemaOscuro;

  /// Saludo de Inicio; el nombre de la persona va en un texto aparte.
  ///
  /// In es, this message translates to:
  /// **'Hola'**
  String get inicioSaludo;

  /// Título de la tarjeta de colonia en Inicio.
  ///
  /// In es, this message translates to:
  /// **'Tu zona'**
  String get inicioZonaTitulo;

  /// Texto inicial de la tarjeta de colonia en Inicio.
  ///
  /// In es, this message translates to:
  /// **'Descubre si tu zona tiene cobertura.'**
  String get inicioZonaSinPedir;

  /// Estado cargando de la tarjeta de colonia.
  ///
  /// In es, this message translates to:
  /// **'Buscando tu colonia…'**
  String get inicioZonaBuscando;

  /// La ubicación está fuera de la cobertura.
  ///
  /// In es, this message translates to:
  /// **'Todavía no llegamos a tu zona.'**
  String get inicioZonaFuera;

  /// Sin permiso de ubicación o servicio apagado.
  ///
  /// In es, this message translates to:
  /// **'Necesitamos tu ubicación para ubicar tu colonia.'**
  String get inicioZonaSinUbicacion;

  /// Botón que consulta la colonia de la persona.
  ///
  /// In es, this message translates to:
  /// **'Ver mi colonia'**
  String get inicioVerColonia;

  /// Botón que vuelve a consultar la colonia.
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get inicioActualizar;

  /// Botón tras un error al consultar la colonia o un intento fallido.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get inicioReintentar;

  /// Acceso de Inicio al catálogo de oficios.
  ///
  /// In es, this message translates to:
  /// **'Explorar oficios'**
  String get inicioExplorarOficios;

  /// Detalle del acceso a oficios en Inicio.
  ///
  /// In es, this message translates to:
  /// **'Mira qué técnicos puedes encontrar'**
  String get inicioExplorarOficiosDetalle;

  /// Detalle bajo el nombre en Mi cuenta.
  ///
  /// In es, this message translates to:
  /// **'Editar perfil'**
  String get cuentaEditarPerfil;

  /// Entrada de Mi cuenta y botón de confirmación del diálogo.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get cuentaCerrarSesion;

  /// Título del diálogo de cierre de sesión.
  ///
  /// In es, this message translates to:
  /// **'¿Cerrar sesión?'**
  String get cuentaCerrarSesionTitulo;

  /// Cuerpo del diálogo de cierre de sesión.
  ///
  /// In es, this message translates to:
  /// **'Tendrás que volver a entrar para usar tu cuenta.'**
  String get cuentaCerrarSesionCuerpo;

  /// Botón que cierra el diálogo sin hacer nada.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cuentaCancelar;

  /// Botón del aviso previo a un permiso: seguir y ver la petición del sistema.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get permisoContinuar;

  /// Botón del aviso previo a un permiso: no pedirlo ahora.
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get permisoAhoraNo;

  /// Título del aviso previo al permiso de notificaciones.
  ///
  /// In es, this message translates to:
  /// **'¿Activar las notificaciones?'**
  String get permisoNotificacionesTitulo;

  /// Explicación previa al permiso de notificaciones: para qué sirve.
  ///
  /// In es, this message translates to:
  /// **'Te avisamos cuando haya novedades en tus solicitudes, mensajes y visitas. Los avisos no muestran códigos ni direcciones.'**
  String get permisoNotificacionesCuerpo;

  /// Título del aviso previo al permiso de ubicación.
  ///
  /// In es, this message translates to:
  /// **'¿Usar tu ubicación?'**
  String get permisoUbicacionTitulo;

  /// Explicación previa al permiso de ubicación: para qué sirve y la alternativa.
  ///
  /// In es, this message translates to:
  /// **'La usamos una sola vez para mostrarte técnicos de tu colonia. No la guardamos. Si prefieres, puedes escribir tu código postal.'**
  String get permisoUbicacionCuerpo;

  /// Encabezado de la sección de Configuración para elegir qué avisos recibir.
  ///
  /// In es, this message translates to:
  /// **'Avisos'**
  String get avisosTitulo;

  /// Interruptor: avisos de cotizaciones.
  ///
  /// In es, this message translates to:
  /// **'Cotizaciones'**
  String get avisosCotizaciones;

  /// Interruptor: avisos de mensajes.
  ///
  /// In es, this message translates to:
  /// **'Mensajes'**
  String get avisosMensajes;

  /// Interruptor: avisos de visitas.
  ///
  /// In es, this message translates to:
  /// **'Visitas'**
  String get avisosVisitas;

  /// Botón que inicia la petición del permiso de notificaciones.
  ///
  /// In es, this message translates to:
  /// **'Activar notificaciones'**
  String get avisosActivar;

  /// Mensaje cuando no hay permiso de notificaciones.
  ///
  /// In es, this message translates to:
  /// **'Las notificaciones están apagadas en tu teléfono. La app sigue funcionando; puedes activarlas cuando quieras.'**
  String get avisosApagadas;

  /// Botón que abre los ajustes del teléfono para cambiar un permiso negado.
  ///
  /// In es, this message translates to:
  /// **'Abrir ajustes'**
  String get avisosAbrirAjustes;

  /// Mensaje cuando el permiso de notificaciones está concedido.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones activadas'**
  String get avisosActivadas;

  /// Botón para elegir la zona con la ubicación del teléfono.
  ///
  /// In es, this message translates to:
  /// **'Usar mi ubicación'**
  String get zonaUsarUbicacion;

  /// Mensaje cuando no hay ubicación y se ofrece el código postal.
  ///
  /// In es, this message translates to:
  /// **'Sin la ubicación, escribe tu código postal para continuar.'**
  String get zonaPideCodigoPostal;

  /// Etiqueta del campo del código postal.
  ///
  /// In es, this message translates to:
  /// **'Código postal'**
  String get zonaCodigoPostal;

  /// Error del campo de código postal.
  ///
  /// In es, this message translates to:
  /// **'Escribe los 5 números de tu código postal.'**
  String get zonaCodigoPostalInvalido;

  /// Botón que confirma el código postal.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get zonaContinuar;

  /// Error común: sin conexión o servicio no disponible (5xx).
  ///
  /// In es, this message translates to:
  /// **'No pudimos conectar con Knock. Revisa tu conexión e inténtalo de nuevo.'**
  String get errorSinConexion;

  /// Error común: la API rechazó la credencial (401) y no se pudo renovar.
  ///
  /// In es, this message translates to:
  /// **'Tu sesión ya no es válida. Inicia sesión de nuevo.'**
  String get errorSesionVencida;

  /// Error común: cuenta suspendida (403 account_suspended).
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta está suspendida. Contacta a soporte si crees que es un error.'**
  String get errorCuentaSuspendida;

  /// Error común: acceso negado (403).
  ///
  /// In es, this message translates to:
  /// **'No tienes permiso para hacer esto.'**
  String get errorAccesoDenegado;

  /// Error común: conflicto (409).
  ///
  /// In es, this message translates to:
  /// **'Esta acción choca con otra cuenta o con el estado actual. Revisa los datos e inténtalo de nuevo.'**
  String get errorConflicto;

  /// Error común: datos rechazados (400, 413 o 422).
  ///
  /// In es, this message translates to:
  /// **'Revisa los datos que escribiste e inténtalo de nuevo.'**
  String get errorDatosRechazados;

  /// Error común: límite de intentos (429).
  ///
  /// In es, this message translates to:
  /// **'Hiciste demasiados intentos. Espera un momento e inténtalo de nuevo.'**
  String get errorDemasiadosIntentos;

  /// Error común: la respuesta no cumple el contrato.
  ///
  /// In es, this message translates to:
  /// **'Recibimos información que no pudimos leer. Inténtalo más tarde.'**
  String get errorDatosInvalidos;

  /// Error común: falta KNOCK_API_URL al compilar.
  ///
  /// In es, this message translates to:
  /// **'La app no está conectada a un servidor. Instala una versión oficial.'**
  String get errorApiNoConfigurada;

  /// Error común: cualquier fallo no previsto; nunca muestra detalles técnicos.
  ///
  /// In es, this message translates to:
  /// **'Algo salió mal. Inténtalo de nuevo.'**
  String get errorInesperado;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
