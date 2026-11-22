import 'package:app/core/widgets/estados.dart';
import 'package:app/features/avisos/domain/aviso.dart';
import 'package:app/features/avisos/presentation/avisos_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bandeja de avisos dentro de la app (KNOCK-105): cargando, lista, vacío y
/// error con Reintentar; filtros por leído y por rol; marcar uno o todos.
class AvisosScreen extends ConsumerWidget {
  const AvisosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(avisosControllerProvider);
    final controlador = ref.read(avisosControllerProvider.notifier);

    final Widget cuerpo;
    if (estado.isLoading) {
      cuerpo = const CargandoCentrado(etiqueta: 'Cargando avisos');
    } else if (estado.hasError) {
      cuerpo = MensajeCentrado(
        texto: mensajeDeError(
          estado.error!,
          porDefecto: 'No pudimos cargar tus avisos',
        ),
        etiquetaAccion: 'Reintentar',
        alPulsar: controlador.reintentar,
      );
    } else if (estado.requireValue.items.isEmpty) {
      cuerpo = const MensajeCentrado(texto: 'No tienes avisos');
    } else {
      cuerpo = _Lista(bandeja: estado.requireValue);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Avisos'),
        actions: [
          IconButton(
            tooltip: 'Marcar todos como leídos',
            icon: const Icon(Icons.done_all),
            onPressed: () async {
              final mensajero = ScaffoldMessenger.of(context);
              final bien = await controlador.marcarTodosLeidos();
              if (!bien) {
                mensajero.showSnackBar(
                  const SnackBar(
                    content: Text('No pudimos marcar los avisos como leídos'),
                  ),
                );
              }
            },
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

class _Lista extends ConsumerWidget {
  const _Lista({required this.bandeja});

  final BandejaAvisos bandeja;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controlador = ref.read(avisosControllerProvider.notifier);
    return ListView(
      children: [
        for (final aviso in bandeja.items)
          ListTile(
            key: ValueKey(aviso.id),
            leading: Icon(
              aviso.leido
                  ? Icons.notifications_none
                  : Icons.notifications_active,
              semanticLabel: aviso.leido ? 'Leído' : 'No leído',
            ),
            title: Text(
              aviso.titulo,
              style: aviso.leido
                  ? null
                  : const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(aviso.texto),
            onTap: aviso.leido ? null : () => controlador.marcarLeido(aviso.id),
          ),
        if (bandeja.huboErrorAlCargarMas)
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'No pudimos cargar más avisos',
              textAlign: TextAlign.center,
            ),
          ),
        if (bandeja.siguienteCursor != null)
          Padding(
            padding: const EdgeInsets.all(12),
            child: bandeja.cargandoMas
                ? const Center(
                    child: CircularProgressIndicator(
                      semanticsLabel: 'Cargando más avisos',
                    ),
                  )
                : OutlinedButton(
                    onPressed: controlador.cargarMas,
                    child: const Text('Cargar más'),
                  ),
          ),
      ],
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
