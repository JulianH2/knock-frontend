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

  /// Título del selector de prueba (solo fuera de la versión de tienda) para elegir el tema.
  ///
  /// In es, this message translates to:
  /// **'Tema (prueba)'**
  String get pruebaTema;

  /// Opción del selector de tema: seguir el tema claro u oscuro del teléfono.
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get pruebaTemaSistema;

  /// Opción del selector de tema: tema claro.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get pruebaTemaClaro;

  /// Opción del selector de tema: tema oscuro.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get pruebaTemaOscuro;

  /// Título del selector de prueba (solo fuera de la versión de tienda) para elegir el idioma.
  ///
  /// In es, this message translates to:
  /// **'Idioma (prueba)'**
  String get pruebaIdioma;

  /// Opción del selector de idioma. Se escribe siempre en español, en cualquier idioma.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get pruebaIdiomaEspanol;

  /// Opción del selector de idioma. Se escribe siempre en inglés, en cualquier idioma.
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get pruebaIdiomaIngles;
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
