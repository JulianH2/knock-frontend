import 'package:app/features/dispositivos/data/dispositivos_de_prueba.dart';
import 'package:app/features/dispositivos/domain/dispositivo.dart';
import 'package:app/features/dispositivos/domain/permiso_notificaciones.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Raíz de composición de dispositivos (KNOCK-60). Datos de prueba hasta que
/// exista el cliente HTTP y el paquete de push (duda anotada en Memoria).
final dispositivosRepositoryProvider = Provider<DispositivosRepository>(
  (ref) => DispositivosRepositoryDePrueba(),
);

final proveedorTokenPushProvider = Provider<ProveedorTokenPush>(
  (ref) => const ProveedorTokenPushDePrueba(),
);

final plataformaDispositivoProvider = Provider<PlataformaDispositivo>(
  (ref) => defaultTargetPlatform == TargetPlatform.iOS
      ? PlataformaDispositivo.ios
      : PlataformaDispositivo.android,
);

/// Permiso de notificaciones del sistema. Datos de prueba hasta que se evalúe
/// el paquete de push; cambiar solo esta línea.
final permisoNotificacionesProvider = Provider<PermisoNotificaciones>(
  (ref) => PermisoNotificacionesDePrueba(),
);
