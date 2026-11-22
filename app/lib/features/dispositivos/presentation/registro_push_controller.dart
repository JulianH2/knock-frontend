import 'package:app/core/errores/failure.dart';
import 'package:app/features/dispositivos/dispositivos_providers.dart';
import 'package:app/features/dispositivos/domain/permiso_notificaciones.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum EstadoPush {
  sinRegistrar,

  /// Antes de pedir el permiso se explica para qué sirve.
  explicacionPrevia,
  registrando,
  registrado,

  /// 503: el push aún no está habilitado. No se reintenta solo.
  noDisponible,

  /// La persona dijo que no; el sistema todavía deja volver a preguntar.
  permisoDenegado,

  /// El sistema ya no pregunta: solo se activa desde Ajustes.
  permisoBloqueado,

  /// Hay permiso pero el dispositivo no entregó un token.
  sinToken,

  /// El token no es válido (validación local o 422 del servidor).
  tokenInvalido,

  /// 409: el dispositivo ya está asociado y el servidor lo rechaza.
  conflicto,

  /// 429: demasiadas peticiones; se espera a que la persona reintente.
  limite,
  error,
}

class RegistroPush {
  const RegistroPush(this.estado, {this.id, this.permiso});

  final EstadoPush estado;
  final String? id;

  /// Último permiso conocido del sistema (`null` si aún no se consultó).
  final EstadoPermiso? permiso;

  RegistroPush con(EstadoPush estado, {String? id}) =>
      RegistroPush(estado, id: id ?? this.id, permiso: permiso);

  RegistroPush conPermiso(EstadoPermiso? permiso) =>
      RegistroPush(estado, id: id, permiso: permiso);
}

/// Flujo de push del dispositivo (KNOCK-60): permiso del sistema con
/// explicación previa, registro del token y baja al cerrar sesión.
///
/// Un 503 (push deshabilitado), un 409, un 429 o un token inválido dejan un
/// estado propio y no se reintenta solo: solo la persona reintenta, con un
/// botón. Sin reintentos en bucle.
class RegistroPushController extends Notifier<RegistroPush> {
  @override
  RegistroPush build() => const RegistroPush(EstadoPush.sinRegistrar);

  bool get _ocupado =>
      state.estado == EstadoPush.registrando ||
      state.estado == EstadoPush.noDisponible;

  /// Consulta el permiso del sistema y actualiza el estado mostrado. Si la
  /// persona lo activó desde Ajustes, registra el dispositivo.
  Future<void> refrescarPermiso() async {
    final permiso = await ref.read(permisoNotificacionesProvider).estado();
    state = state.conPermiso(permiso);
    final esperaPermiso =
        state.estado == EstadoPush.permisoBloqueado ||
        state.estado == EstadoPush.permisoDenegado;
    if (permiso == EstadoPermiso.concedido && esperaPermiso) {
      await _registrar();
    }
  }

  /// Botón «Activar notificaciones»: según el permiso, explica, pide o
  /// registra.
  Future<void> registrar() async {
    if (_ocupado) {
      return;
    }
    final permiso = await ref.read(permisoNotificacionesProvider).estado();
    await _segunPermiso(permiso);
  }

  /// La persona aceptó la explicación: se muestra el diálogo del sistema.
  Future<void> aceptarExplicacion() async {
    if (_ocupado) {
      return;
    }
    final permiso = await ref.read(permisoNotificacionesProvider).solicitar();
    await _segunPermiso(permiso);
  }

  /// La persona no quiere activar ahora: vuelve al inicio sin pedir nada.
  void rechazarExplicacion() {
    state = state.con(EstadoPush.sinRegistrar);
  }

  /// Abre los Ajustes del sistema (permiso bloqueado).
  Future<void> abrirAjustes() async {
    await ref.read(permisoNotificacionesProvider).abrirAjustes();
  }

  /// Reintento pedido por la persona tras un 503, 409, 429 o error. Es la
  /// única forma de volver a llamar al servidor desde esos estados.
  Future<void> reintentarManual() async {
    if (state.estado == EstadoPush.registrando) {
      return;
    }
    state = state.con(EstadoPush.sinRegistrar);
    await registrar();
  }

  /// Al iniciar sesión: si ya hay permiso, registra sin molestar; nunca abre
  /// el diálogo del sistema (eso solo sucede desde la pantalla).
  Future<void> alIniciarSesion() async {
    if (_ocupado || state.estado == EstadoPush.registrado) {
      return;
    }
    final permiso = await ref.read(permisoNotificacionesProvider).estado();
    state = state.conPermiso(permiso);
    if (permiso == EstadoPermiso.concedido) {
      await _registrar();
    }
  }

  Future<void> _segunPermiso(EstadoPermiso permiso) async {
    state = state.conPermiso(permiso);
    switch (permiso) {
      case EstadoPermiso.noPreguntado:
        state = state.con(EstadoPush.explicacionPrevia);
      case EstadoPermiso.denegado:
        state = state.con(EstadoPush.permisoDenegado);
      case EstadoPermiso.denegadoPermanente:
        state = state.con(EstadoPush.permisoBloqueado);
      case EstadoPermiso.concedido:
        await _registrar();
    }
  }

  Future<void> _registrar() async {
    state = state.con(EstadoPush.registrando);
    try {
      final token = await ref.read(proveedorTokenPushProvider).obtener();
      if (token == null) {
        state = state.con(EstadoPush.sinToken);
        return;
      }
      final registro = await ref
          .read(dispositivosRepositoryProvider)
          .registrar(
            identificador: token,
            plataforma: ref.read(plataformaDispositivoProvider),
          );
      state = state.con(EstadoPush.registrado, id: registro.id);
    } on ServicioNoDisponibleFailure {
      state = state.con(EstadoPush.noDisponible);
    } on ReglaDeNegocioFailure {
      state = state.con(EstadoPush.conflicto);
    } on LimiteDePeticionesFailure {
      state = state.con(EstadoPush.limite);
    } on DatosInvalidosFailure {
      state = state.con(EstadoPush.tokenInvalido);
    } on Object {
      state = state.con(EstadoPush.error);
    }
  }

  /// Baja del dispositivo al cerrar sesión. Si el push no está disponible o
  /// falla, no bloquea el cierre de sesión.
  Future<void> darDeBaja() async {
    final id = state.id;
    if (id == null) {
      state = state.con(EstadoPush.sinRegistrar);
      return;
    }
    try {
      await ref.read(dispositivosRepositoryProvider).darDeBaja(id);
    } on Object {
      // La baja es de mejor esfuerzo: el servidor responde 204 o 503.
    }
    state = RegistroPush(EstadoPush.sinRegistrar, permiso: state.permiso);
  }
}

final registroPushControllerProvider =
    NotifierProvider<RegistroPushController, RegistroPush>(
      RegistroPushController.new,
    );
