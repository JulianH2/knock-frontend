import 'dart:async';

import 'package:app/features/avisos/avisos_providers.dart';
import 'package:app/features/avisos/domain/aviso.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Contador de no leídos para la insignia («99+» según `masDe99`). Se ajusta
/// de forma optimista al marcar avisos y la API lo confirma al recargar.
class ContadorAvisosNotifier extends AsyncNotifier<ContadorAvisos> {
  @override
  Future<ContadorAvisos> build() =>
      ref.watch(avisosRepositoryProvider).contador();

  /// Baja uno. Con «99+» no se sabe el total real: se mantiene hasta recargar.
  void bajarUno() {
    final actual = state.value;
    if (actual == null || actual.masDe99 || actual.cantidad == 0) {
      return;
    }
    state = AsyncData(
      ContadorAvisos(cantidad: actual.cantidad - 1, masDe99: false),
    );
  }

  void ponerEnCero() =>
      state = const AsyncData(ContadorAvisos(cantidad: 0, masDe99: false));

  /// Vuelve al valor anterior si la API rechazó el cambio.
  void restaurar(ContadorAvisos? anterior) {
    if (anterior != null) {
      state = AsyncData(anterior);
    }
  }

  /// Pide el valor real a la API sin pasar por «cargando».
  Future<void> confirmar() async {
    try {
      final real = await ref.read(avisosRepositoryProvider).contador();
      state = AsyncData(real);
    } on Object {
      // Se queda el valor optimista; la insignia no es crítica.
    }
  }
}

final contadorAvisosProvider =
    AsyncNotifierProvider.autoDispose<ContadorAvisosNotifier, ContadorAvisos>(
      ContadorAvisosNotifier.new,
      retry: (_, _) => null,
    );

/// Filtros activos de la bandeja.
class FiltroAvisosNotifier extends Notifier<FiltroAvisos> {
  @override
  FiltroAvisos build() => const FiltroAvisos();

  void cambiar(FiltroAvisos filtro) => state = filtro;
}

final filtroAvisosProvider =
    NotifierProvider<FiltroAvisosNotifier, FiltroAvisos>(
      FiltroAvisosNotifier.new,
    );

/// Lo que ya se cargó de la bandeja y cómo seguir.
class BandejaAvisos {
  const BandejaAvisos({
    required this.items,
    this.siguienteCursor,
    this.cargandoMas = false,
    this.huboErrorAlCargarMas = false,
  });

  final List<Aviso> items;
  final String? siguienteCursor;
  final bool cargandoMas;
  final bool huboErrorAlCargarMas;

  BandejaAvisos copiar({
    List<Aviso>? items,
    String? siguienteCursor,
    bool? cargandoMas,
    bool? huboErrorAlCargarMas,
  }) => BandejaAvisos(
    items: items ?? this.items,
    siguienteCursor: siguienteCursor ?? this.siguienteCursor,
    cargandoMas: cargandoMas ?? this.cargandoMas,
    huboErrorAlCargarMas: huboErrorAlCargarMas ?? this.huboErrorAlCargarMas,
  );
}

/// Bandeja de avisos con cursor. Cambiar el filtro la recarga desde cero.
class AvisosController extends AsyncNotifier<BandejaAvisos> {
  @override
  Future<BandejaAvisos> build() async {
    final filtro = ref.watch(filtroAvisosProvider);
    final pagina = await ref
        .watch(avisosRepositoryProvider)
        .listar(filtro: filtro);
    return BandejaAvisos(
      items: pagina.items,
      siguienteCursor: pagina.siguienteCursor,
    );
  }

  void reintentar() => ref.invalidateSelf();

  /// Pide la página siguiente; si falla, conserva lo cargado y lo avisa.
  Future<void> cargarMas() async {
    final actual = state.value;
    final cursor = actual?.siguienteCursor;
    if (actual == null || cursor == null || actual.cargandoMas) {
      return;
    }
    state = AsyncData(
      actual.copiar(cargandoMas: true, huboErrorAlCargarMas: false),
    );
    try {
      final pagina = await ref
          .read(avisosRepositoryProvider)
          .listar(cursor: cursor, filtro: ref.read(filtroAvisosProvider));
      state = AsyncData(
        BandejaAvisos(
          items: [...actual.items, ...pagina.items],
          siguienteCursor: pagina.siguienteCursor,
        ),
      );
    } on Object {
      state = AsyncData(
        actual.copiar(cargandoMas: false, huboErrorAlCargarMas: true),
      );
    }
  }

  /// Vuelve a pedir la primera página sin pasar por «cargando» (pull to
  /// refresh). Si falla, conserva lo que ya había y devuelve el error.
  Future<Object?> refrescar() async {
    try {
      final pagina = await ref
          .read(avisosRepositoryProvider)
          .listar(filtro: ref.read(filtroAvisosProvider));
      state = AsyncData(
        BandejaAvisos(
          items: pagina.items,
          siguienteCursor: pagina.siguienteCursor,
        ),
      );
      unawaited(ref.read(contadorAvisosProvider.notifier).confirmar());
      return null;
    } on Object catch (error) {
      return error;
    }
  }

  /// Marca uno como leído al instante (también el contador); si la API
  /// falla, deshace el cambio. Devuelve el error o `null` si salió bien.
  Future<Object?> marcarLeido(String id) async {
    final antes = state.value?.items;
    final aviso = antes?.where((a) => a.id == id).firstOrNull;
    if (aviso == null || aviso.leido) {
      return null;
    }
    final contador = ref.read(contadorAvisosProvider.notifier);
    final contadorAntes = ref.read(contadorAvisosProvider).value;
    _actualizar((a) => a.id == id ? a.copiaLeido() : a);
    contador.bajarUno();
    try {
      await ref.read(avisosRepositoryProvider).marcarLeido(id);
    } on Object catch (error) {
      _restaurar(antes!);
      contador.restaurar(contadorAntes);
      return error;
    }
    unawaited(contador.confirmar());
    return null;
  }

  /// Marca todos como leídos al instante; si la API falla, deshace el cambio.
  Future<Object?> marcarTodosLeidos() async {
    final antes = state.value?.items;
    final contador = ref.read(contadorAvisosProvider.notifier);
    final contadorAntes = ref.read(contadorAvisosProvider).value;
    _actualizar((a) => a.copiaLeido());
    contador.ponerEnCero();
    try {
      await ref.read(avisosRepositoryProvider).marcarTodosLeidos();
    } on Object catch (error) {
      if (antes != null) {
        _restaurar(antes);
      }
      contador.restaurar(contadorAntes);
      return error;
    }
    unawaited(contador.confirmar());
    return null;
  }

  void _restaurar(List<Aviso> items) {
    final actual = state.value;
    if (actual != null) {
      state = AsyncData(actual.copiar(items: items));
    }
  }

  void _actualizar(Aviso Function(Aviso) cambio) {
    final actual = state.value;
    if (actual != null) {
      state = AsyncData(
        actual.copiar(items: actual.items.map(cambio).toList()),
      );
    }
  }
}

final avisosControllerProvider =
    AsyncNotifierProvider<AvisosController, BandejaAvisos>(
      AvisosController.new,
      retry: (_, _) => null,
    );
