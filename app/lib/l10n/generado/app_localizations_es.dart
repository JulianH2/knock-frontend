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
  String get pruebaModoTecnico => 'Modo t├®cnico (prueba)';

  @override
  String get configuracionTitulo => 'Configuraci├│n';

  @override
  String get configuracionIdioma => 'Idioma';

  @override
  String get configuracionIdiomaEspanol => 'Espa├▒ol';

  @override
  String get configuracionIdiomaIngles => 'English';

  @override
  String get configuracionTema => 'Tema';

  @override
  String get configuracionTemaAutomatico => 'Autom├ítico';

  @override
  String get configuracionTemaAutomaticoDetalle => 'Igual que el tel├®fono';

  @override
  String get configuracionTemaClaro => 'Claro';

  @override
  String get configuracionTemaOscuro => 'Oscuro';

  @override
  String get inicioSaludo => 'Hola';

  @override
  String get inicioZonaTitulo => 'Tu zona';

  @override
  String get inicioZonaSinPedir => 'Descubre si tu zona tiene cobertura.';

  @override
  String get inicioZonaBuscando => 'Buscando tu coloniaÔÇª';

  @override
  String get inicioZonaFuera => 'Todav├¡a no llegamos a tu zona.';

  @override
  String get inicioZonaSinUbicacion =>
      'Necesitamos tu ubicaci├│n para ubicar tu colonia.';

  @override
  String get inicioVerColonia => 'Ver mi colonia';

  @override
  String get inicioActualizar => 'Actualizar';

  @override
  String get inicioReintentar => 'Reintentar';

  @override
  String get inicioExplorarOficios => 'Explorar oficios';

  @override
  String get inicioExplorarOficiosDetalle =>
      'Mira qu├® t├®cnicos puedes encontrar';

  @override
  String get cuentaEditarPerfil => 'Editar perfil';

  @override
  String get cuentaCerrarSesion => 'Cerrar sesi├│n';

  @override
  String get cuentaCerrarSesionTitulo => '┬┐Cerrar sesi├│n?';

  @override
  String get cuentaCerrarSesionCuerpo =>
      'Tendr├ís que volver a entrar para usar tu cuenta.';

  @override
  String get cuentaCancelar => 'Cancelar';

  @override
  String get permisoContinuar => 'Continuar';

  @override
  String get permisoAhoraNo => 'Ahora no';

  @override
  String get permisoNotificacionesTitulo => '┬┐Activar las notificaciones?';

  @override
  String get permisoNotificacionesCuerpo =>
      'Te avisamos cuando haya novedades en tus solicitudes, mensajes y visitas. Los avisos no muestran c├│digos ni direcciones.';

  @override
  String get permisoUbicacionTitulo => '┬┐Usar tu ubicaci├│n?';

  @override
  String get permisoUbicacionCuerpo =>
      'La usamos una sola vez para mostrarte t├®cnicos de tu colonia. No la guardamos. Si prefieres, puedes escribir tu c├│digo postal.';

  @override
  String get avisosTitulo => 'Avisos';

  @override
  String get avisosCotizaciones => 'Cotizaciones';

  @override
  String get avisosMensajes => 'Mensajes';

  @override
  String get avisosVisitas => 'Visitas';

  @override
  String get avisosActivar => 'Activar notificaciones';

  @override
  String get avisosApagadas =>
      'Las notificaciones est├ín apagadas en tu tel├®fono. La app sigue funcionando; puedes activarlas cuando quieras.';

  @override
  String get avisosAbrirAjustes => 'Abrir ajustes';

  @override
  String get avisosActivadas => 'Notificaciones activadas';

  @override
  String get zonaUsarUbicacion => 'Usar mi ubicaci├│n';

  @override
  String get zonaPideCodigoPostal =>
      'Sin la ubicaci├│n, escribe tu c├│digo postal para continuar.';

  @override
  String get zonaCodigoPostal => 'C├│digo postal';

  @override
  String get zonaCodigoPostalInvalido =>
      'Escribe los 5 n├║meros de tu c├│digo postal.';

  @override
  String get zonaContinuar => 'Continuar';

  @override
  String get errorSinConexion =>
      'No pudimos conectar con Knock. Revisa tu conexi├│n e int├®ntalo de nuevo.';

  @override
  String get errorSesionVencida =>
      'Tu sesi├│n ya no es v├ílida. Inicia sesi├│n de nuevo.';

  @override
  String get errorCuentaSuspendida =>
      'Tu cuenta est├í suspendida. Contacta a soporte si crees que es un error.';

  @override
  String get errorAccesoDenegado => 'No tienes permiso para hacer esto.';

  @override
  String get errorConflicto =>
      'Esta acci├│n choca con otra cuenta o con el estado actual. Revisa los datos e int├®ntalo de nuevo.';

  @override
  String get errorDatosRechazados =>
      'Revisa los datos que escribiste e int├®ntalo de nuevo.';

  @override
  String get errorDemasiadosIntentos =>
      'Hiciste demasiados intentos. Espera un momento e int├®ntalo de nuevo.';

  @override
  String get errorDatosInvalidos =>
      'Recibimos informaci├│n que no pudimos leer. Int├®ntalo m├ís tarde.';

  @override
  String get errorApiNoConfigurada =>
      'La app no est├í conectada a un servidor. Instala una versi├│n oficial.';

  @override
  String get errorInesperado => 'Algo sali├│ mal. Int├®ntalo de nuevo.';
}
