import 'package:app/core/router/rutas.dart';
import 'package:app/core/widgets/estados.dart';
import 'package:app/features/visitas/presentation/visitas_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Agenda de visitas (KNOCK-119/122): cargando, lista, vacío y error.
class AgendaScreen extends ConsumerWidget {
  const AgendaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(agendaControllerProvider);
    final controlador = ref.read(agendaControllerProvider.notifier);

    final Widget cuerpo;
    if (estado.isLoading) {
      cuerpo = const CargandoCentrado(etiqueta: 'Cargando agenda');
    } else if (estado.hasError) {
      cuerpo = MensajeCentrado(
        texto: mensajeDeError(
          estado.error!,
          porDefecto: 'No pudimos cargar tu agenda',
        ),
        etiquetaAccion: 'Reintentar',
        alPulsar: controlador.reintentar,
      );
    } else if (estado.requireValue.items.isEmpty) {
      cuerpo = const MensajeCentrado(texto: 'No tienes visitas programadas');
    } else {
      final agenda = estado.requireValue;
      cuerpo = ListView(
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
              onTap: () => context.go('${Rutas.agenda}/${v.id}'),
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
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Agenda de visitas')),
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
  _ => estado,
};
