import 'package:app/features/avisos/avisos_providers.dart';
import 'package:app/features/avisos/domain/aviso.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Contador de no leídos para la insignia («99+» según `masDe99`).
final contadorAvisosProvider = FutureProvider.autoDispose<ContadorAvisos>(
  (ref) => ref.watch(avisosRepositoryProvider).contador(),
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

  /// Marca uno como leído; devuelve `false` si la API falló.
  Future<bool> marcarLeido(String id) async {
    try {
      await ref.read(avisosRepositoryProvider).marcarLeido(id);
    } on Object {
      return false;
    }
    _actualizar((a) => a.id == id ? a.copiaLeido() : a);
    ref.invalidate(contadorAvisosProvider);
    return true;
  }

  /// Marca todos como leídos; devuelve `false` si la API falló.
  Future<bool> marcarTodosLeidos() async {
    try {
      await ref.read(avisosRepositoryProvider).marcarTodosLeidos();
    } on Object {
      return false;
    }
    _actualizar((a) => a.copiaLeido());
    ref.invalidate(contadorAvisosProvider);
    return true;
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
