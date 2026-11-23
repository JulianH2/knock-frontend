import 'package:app/core/router/rutas.dart';
import 'package:app/core/sesion/es_tecnico_provider.dart';
import 'package:app/core/widgets/estados.dart';
import 'package:app/features/visitas/domain/visita_acciones.dart';
import 'package:app/features/visitas/presentation/visitas_controller.dart';
import 'package:app/features/visitas/visitas_providers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Agenda de visitas (KNOCK-119/122): cargando, lista, vacío y error, con
/// rango de fechas (31 días como máximo), actualizar al deslizar y, para el
/// técnico, acceso a sus horarios.
class AgendaScreen extends ConsumerWidget {
  const AgendaScreen({super.key});

  Future<void> _elegirRango(BuildContext context, WidgetRef ref) async {
    final ahora = ref.read(relojVisitasProvider)();
    final mensajero = ScaffoldMessenger.of(context);
    final rango = await showDateRangePicker(
      context: context,
      firstDate: DateTime(ahora.year - 1),
      lastDate: DateTime(ahora.year + 2),
      initialDateRange: ref.read(rangoAgendaProvider),
      helpText: 'Rango de la agenda (máximo 31 días)',
    );
    if (rango == null) {
      return;
    }
    final error = errorRangoAgenda(rango.start, rango.end);
    if (error != null) {
      mensajero.showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    ref.read(rangoAgendaProvider.notifier).cambiar(rango);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(agendaControllerProvider);
    final controlador = ref.read(agendaControllerProvider.notifier);
    final esTecnico = ref.watch(esTecnicoProvider);
    final rango = ref.watch(rangoAgendaProvider);

    final Widget cuerpo;
    if (estado.isLoading && !estado.hasValue) {
      cuerpo = const CargandoCentrado(etiqueta: 'Cargando agenda');
    } else if (estado.hasError && !estado.hasValue) {
      cuerpo = MensajeCentrado(
        texto: mensajeDeError(
          estado.error!,
          porDefecto: 'No pudimos cargar tu agenda',
        ),
        etiquetaAccion: 'Reintentar',
        alPulsar: controlador.reintentar,
      );
    } else if (estado.requireValue.items.isEmpty) {
      cuerpo = MensajeCentrado(
        texto: rango == null
            ? 'No tienes visitas programadas'
            : 'No tienes visitas en ese rango de fechas',
        etiquetaAccion: rango == null ? null : 'Ver el rango por omisión',
        alPulsar: rango == null
            ? null
            : () => ref.read(rangoAgendaProvider.notifier).cambiar(null),
      );
    } else {
      final agenda = estado.requireValue;
      cuerpo = RefreshIndicator(
        onRefresh: () async => controlador.reintentar(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            for (final v in agenda.items)
              ListTile(
                key: ValueKey(v.id),
                leading: const Icon(Icons.event_outlined),
                title: Text('${v.dia} · ${v.hora}'),
                subtitle: Text(
                  '${_textoModalidad(v.modalidad)} · ${_textoEstado(v.estado)}'
                  '${v.precio == null ? '' : ' · \$${v.precio}'}',
                ),
                onTap: () async {
                  await context.push<void>('${Rutas.agenda}/${v.id}');
                  // Al volver se pide la agenda otra vez por si cambió.
                  controlador.reintentar();
                },
              ),
            if (agenda.huboErrorAlCargarMas)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'No pudimos cargar más visitas',
                  textAlign: TextAlign.center,
                ),
              ),
            if (agenda.nextCursor != null)
              Padding(
                padding: const EdgeInsets.all(12),
                child: agenda.cargandoMas
                    ? const Center(
                        child: CircularProgressIndicator(
                          semanticsLabel: 'Cargando más visitas',
                        ),
                      )
                    : OutlinedButton(
                        onPressed: controlador.cargarMas,
                        child: const Text('Cargar más'),
                      ),
              ),
          ],
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda de visitas'),
        actions: [
          IconButton(
            tooltip: 'Elegir rango de fechas',
            onPressed: () => _elegirRango(context, ref),
            icon: const Icon(Icons.date_range_outlined),
          ),
          if (esTecnico)
            IconButton(
              tooltip: 'Mis horarios',
              onPressed: () => context.push<void>(Rutas.horarios),
              icon: const Icon(Icons.schedule_outlined),
            ),
        ],
      ),
      body: cuerpo,
    );
  }
}

String _textoModalidad(String modalidad) => switch (modalidad) {
  'domicilio' => 'A domicilio',
  'taller' => 'En taller',
  _ => modalidad,
};

/// Texto del estado de la visita. Los estados que la app no conoce se
/// muestran tal cual llegan, sin inventar un significado.
String textoEstadoVisita(String estado) => _textoEstado(estado);

String _textoEstado(String estado) => switch (estado) {
  'propuesta' => 'Propuesta',
  'confirmada' => 'Confirmada',
  'en_curso' => 'En curso',
  'cancelada' => 'Cancelada',
  'terminada' => 'Terminada',
  'no_presentado' => 'No se presentó',
  _ => estado,
};
