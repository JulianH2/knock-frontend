import 'package:app/core/errores/failure.dart';
import 'package:app/features/dispositivos/dispositivos_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum EstadoPush {
  sinRegistrar,
  registrando,
  registrado,

  /// 503: el push aún no está habilitado. No se reintenta solo.
  noDisponible,

  /// No se dio permiso o no hay token en el dispositivo.
  sinPermiso,
  error,
}

class RegistroPush {
  const RegistroPush(this.estado, {this.id});

  final EstadoPush estado;
  final String? id;
}

/// Registra el dispositivo para push y lo da de baja (al cerrar sesión).
///
/// Un 503 deja el estado en `noDisponible` y no se vuelve a intentar hasta que
/// la persona reabra la pantalla: sin reintentos en bucle.
class RegistroPushController extends Notifier<RegistroPush> {
  @override
  RegistroPush build() => const RegistroPush(EstadoPush.sinRegistrar);

  Future<void> registrar() async {
    if (state.estado == EstadoPush.registrando ||
        state.estado == EstadoPush.noDisponible) {
      return;
    }
    state = const RegistroPush(EstadoPush.registrando);
    try {
      final token = await ref.read(proveedorTokenPushProvider).obtener();
      if (token == null) {
        state = const RegistroPush(EstadoPush.sinPermiso);
        return;
      }
      final registro = await ref
          .read(dispositivosRepositoryProvider)
          .registrar(
            identificador: token,
            plataforma: ref.read(plataformaDispositivoProvider),
          );
      state = RegistroPush(EstadoPush.registrado, id: registro.id);
    } on ServicioNoDisponibleFailure {
      state = const RegistroPush(EstadoPush.noDisponible);
    } on Object {
      state = const RegistroPush(EstadoPush.error);
    }
  }

  /// Baja del dispositivo al cerrar sesión. Si el push no está disponible o
  /// falla, no bloquea el cierre de sesión.
  Future<void> darDeBaja() async {
    final id = state.id;
    if (id == null) {
      return;
    }
    try {
      await ref.read(dispositivosRepositoryProvider).darDeBaja(id);
    } on Object {
      // La baja es de mejor esfuerzo: el servidor responde 204 o 503.
    }
    state = const RegistroPush(EstadoPush.sinRegistrar);
  }
}

final registroPushControllerProvider =
    NotifierProvider<RegistroPushController, RegistroPush>(
      RegistroPushController.new,
    );
