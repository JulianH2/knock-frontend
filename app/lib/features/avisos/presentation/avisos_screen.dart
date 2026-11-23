import 'package:app/core/widgets/estados.dart';
import 'package:app/features/avisos/domain/aviso.dart';
import 'package:app/features/avisos/domain/destino_aviso.dart';
import 'package:app/features/avisos/presentation/avisos_controller.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

void _avisar(BuildContext context, String texto) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));

/// Bandeja de avisos dentro de la app (KNOCK-105): cargando, lista con
/// cursor infinito, pull to refresh, vacío, error (503, 429) con Reintentar;
/// filtros que duran la sesión; marcar uno al abrirlo o todos con
/// confirmación; el contador se ajusta al instante y se deshace si falla.
class AvisosScreen extends ConsumerWidget {
  const AvisosScreen({super.key});

  Future<void> _marcarTodos(BuildContext context, WidgetRef ref) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text('Marcar todos como leídos'),
        content: const Text('Todos tus avisos quedarán como leídos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(contexto).pop(true),
            child: const Text('Marcar todos'),
          ),
        ],
      ),
    );
    if (confirmado != true || !context.mounted) {
      return;
    }
    final mensajero = ScaffoldMessenger.of(context);
    final error = await ref
        .read(avisosControllerProvider.notifier)
        .marcarTodosLeidos();
    if (error != null) {
      mensajero.showSnackBar(
        SnackBar(
          content: Text(
            mensajeDeError(
              error,
              porDefecto: 'No pudimos marcar los avisos como leídos',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _refrescar(
    BuildContext context,
    AvisosController controlador,
  ) async {
    final error = await controlador.refrescar();
    if (error != null && context.mounted) {
      _avisar(
        context,
        mensajeDeError(error, porDefecto: 'No pudimos actualizar tus avisos'),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(avisosControllerProvider);
    final filtro = ref.watch(filtroAvisosProvider);
    // Mantiene vivo el contador mientras la bandeja está abierta.
    ref.watch(contadorAvisosProvider);
    final controlador = ref.read(avisosControllerProvider.notifier);

    final Widget cuerpo;
    if (estado.isLoading && !estado.hasValue) {
      cuerpo = const CargandoCentrado(etiqueta: 'Cargando avisos');
    } else if (estado.hasError && !estado.hasValue) {
      cuerpo = MensajeCentrado(
        texto: mensajeDeError(
          estado.error!,
          porDefecto: 'No pudimos cargar tus avisos',
        ),
        etiquetaAccion: 'Reintentar',
        alPulsar: controlador.reintentar,
      );
    } else if (estado.requireValue.items.isEmpty) {
      cuerpo = RefreshIndicator(
        onRefresh: () => _refrescar(context, controlador),
        child: LayoutBuilder(
          builder: (_, restricciones) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: restricciones.maxHeight,
                child: MensajeCentrado(
                  texto: filtro.leido == false || filtro.comoRol != null
                      ? 'No hay avisos con estos filtros'
                      : 'No tienes avisos',
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      cuerpo = RefreshIndicator(
        onRefresh: () => _refrescar(context, controlador),
        child: _Lista(bandeja: estado.requireValue),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Avisos'),
        actions: [
          IconButton(
            tooltip: 'Marcar todos como leídos',
            icon: const Icon(Icons.done_all),
            onPressed: () => _marcarTodos(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          const _Filtros(),
          Expanded(child: cuerpo),
        ],
      ),
    );
  }
}

class _Filtros extends ConsumerWidget {
  const _Filtros();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtro = ref.watch(filtroAvisosProvider);
    void cambiar(FiltroAvisos nuevo) =>
        ref.read(filtroAvisosProvider.notifier).cambiar(nuevo);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        spacing: 8,
        children: [
          FilterChip(
            label: const Text('No leídos'),
            selected: filtro.leido == false,
            onSelected: (marcado) => cambiar(
              FiltroAvisos(
                leido: marcado ? false : null,
                comoRol: filtro.comoRol,
              ),
            ),
          ),
          FilterChip(
            label: const Text('Como cliente'),
            selected: filtro.comoRol == 'cliente',
            onSelected: (marcado) => cambiar(
              FiltroAvisos(
                leido: filtro.leido,
                comoRol: marcado ? 'cliente' : null,
              ),
            ),
          ),
          FilterChip(
            label: const Text('Como técnico'),
            selected: filtro.comoRol == 'tecnico',
            onSelected: (marcado) => cambiar(
              FiltroAvisos(
                leido: filtro.leido,
                comoRol: marcado ? 'tecnico' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Lista extends ConsumerStatefulWidget {
  const _Lista({required this.bandeja});

  final BandejaAvisos bandeja;

  @override
  ConsumerState<_Lista> createState() => _ListaState();
}

class _ListaState extends ConsumerState<_Lista> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_alDesplazar);
    // Si la primera página no llena la pantalla, no hay con qué desplazar.
    WidgetsBinding.instance.addPostFrameCallback((_) => _alDesplazar());
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Pide la página siguiente al acercarse al final. Si la última carga
  /// falló, no insiste: la persona toca Reintentar.
  void _alDesplazar() {
    final b = widget.bandeja;
    if (!mounted || !_scroll.hasClients) {
      return;
    }
    if (_scroll.position.extentAfter < 200 &&
        !b.huboErrorAlCargarMas &&
        !b.cargandoMas &&
        b.siguienteCursor != null) {
      ref.read(avisosControllerProvider.notifier).cargarMas();
    }
  }

  Future<void> _abrir(Aviso aviso) async {
    final ruta = DestinoAviso.ruta(aviso.destino);
    final enrutador = GoRouter.maybeOf(context);
    final mensajero = ScaffoldMessenger.of(context);
    final futuro = ref
        .read(avisosControllerProvider.notifier)
        .marcarLeido(aviso.id);
    if (aviso.destino != null) {
      if (ruta != null && enrutador != null) {
        enrutador.go(ruta);
      } else {
        mensajero.showSnackBar(
          const SnackBar(
            content: Text('No pudimos abrir lo que indica el aviso'),
          ),
        );
      }
    }
    final error = await futuro;
    if (error != null) {
      mensajero.showSnackBar(
        SnackBar(
          content: Text(
            mensajeDeError(
              error,
              porDefecto: 'No pudimos marcar el aviso como leído',
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bandeja = widget.bandeja;
    final controlador = ref.read(avisosControllerProvider.notifier);
    final hayPie = bandeja.siguienteCursor != null;
    // Tras cada reconstrucción (p. ej. llegó una página) se revisa si falta
    // llenar la pantalla.
    WidgetsBinding.instance.addPostFrameCallback((_) => _alDesplazar());
    return ListView.builder(
      controller: _scroll,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: bandeja.items.length + (hayPie ? 1 : 0),
      itemBuilder: (context, indice) {
        if (indice == bandeja.items.length) {
          if (bandeja.huboErrorAlCargarMas) {
            return Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const Text(
                    'No pudimos cargar más avisos',
                    textAlign: TextAlign.center,
                  ),
                  TextButton(
                    onPressed: controlador.cargarMas,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          return const Padding(
            padding: EdgeInsets.all(12),
            child: Center(
              child: CircularProgressIndicator(
                semanticsLabel: 'Cargando más avisos',
              ),
            ),
          );
        }
        final aviso = bandeja.items[indice];
        return ListTile(
          key: ValueKey(aviso.id),
          leading: Icon(
            aviso.leido ? Icons.notifications_none : Icons.notifications_active,
            semanticLabel: aviso.leido ? 'Leído' : 'No leído',
          ),
          title: Text(
            aviso.titulo,
            style: aviso.leido
                ? null
                : const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(aviso.texto),
          trailing: aviso.destino == null
              ? null
              : const Icon(Icons.chevron_right),
          onTap: () => _abrir(aviso),
        );
      },
    );
  }
}

/// Insignia con el contador de no leídos («99+» cuando `masDe99`).
class InsigniaAvisos extends ConsumerWidget {
  const InsigniaAvisos({required this.hijo, super.key});

  final Widget hijo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contador = ref.watch(contadorAvisosProvider).value;
    if (contador == null || !contador.hayNoLeidos) {
      return hijo;
    }
    return Badge(label: Text(contador.etiqueta), child: hijo);
  }
}
