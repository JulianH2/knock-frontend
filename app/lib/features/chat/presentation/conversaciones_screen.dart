import 'package:app/core/datos/formato_fecha.dart';
import 'package:app/core/router/rutas.dart';
import 'package:app/core/widgets/estados.dart';
import 'package:app/features/chat/domain/chat.dart';
import 'package:app/features/chat/presentation/conversaciones_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Lista de conversaciones (KNOCK-72): cargando, lista con contador de no
/// leídos, vacío y error con Reintentar.
class ConversacionesScreen extends ConsumerWidget {
  const ConversacionesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(conversacionesControllerProvider);
    final controlador = ref.read(conversacionesControllerProvider.notifier);

    final Widget cuerpo;
    if (estado.isLoading) {
      cuerpo = const CargandoCentrado(etiqueta: 'Cargando mensajes');
    } else if (estado.hasError) {
      cuerpo = MensajeCentrado(
        texto: mensajeDeError(
          estado.error!,
          porDefecto: 'No pudimos cargar tus conversaciones',
        ),
        etiquetaAccion: 'Reintentar',
        alPulsar: controlador.reintentar,
      );
    } else if (estado.requireValue.items.isEmpty) {
      cuerpo = const MensajeCentrado(texto: 'Todavía no tienes conversaciones');
    } else {
      cuerpo = _Lista(bandeja: estado.requireValue);
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Mensajes')),
      body: cuerpo,
    );
  }
}

class _Lista extends ConsumerWidget {
  const _Lista({required this.bandeja});

  final BandejaChats bandeja;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controlador = ref.read(conversacionesControllerProvider.notifier);
    return ListView(
      children: [
        if (bandeja.totalNoLeidos > 0)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              bandeja.totalNoLeidos == 1
                  ? '1 mensaje sin leer'
                  : '${bandeja.totalNoLeidos} mensajes sin leer',
            ),
          ),
        for (final c in bandeja.items) _Fila(conversacion: c),
        if (bandeja.huboErrorAlCargarMas)
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'No pudimos cargar más conversaciones',
              textAlign: TextAlign.center,
            ),
          ),
        if (bandeja.nextCursor != null)
          Padding(
            padding: const EdgeInsets.all(12),
            child: bandeja.cargandoMas
                ? const Center(
                    child: CircularProgressIndicator(
                      semanticsLabel: 'Cargando más conversaciones',
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

class _Fila extends StatelessWidget {
  const _Fila({required this.conversacion});

  final ConversacionItem conversacion;

  @override
  Widget build(BuildContext context) {
    final ultimo = conversacion.ultimoMensaje;
    final sinLeer = conversacion.noLeidos > 0;
    return ListTile(
      key: ValueKey(conversacion.conversacionId),
      leading: const CircleAvatar(child: Icon(Icons.person_outline)),
      title: Text(
        conversacion.contraparte.nombre,
        style: sinLeer ? const TextStyle(fontWeight: FontWeight.bold) : null,
      ),
      subtitle: Text(
        ultimo == null
            ? conversacion.servicio
            : '${conversacion.servicio} · ${ultimo.texto}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (ultimo != null) Text(horaCorta(ultimo.enviadoEn)),
          if (sinLeer) Badge(label: Text('${conversacion.noLeidos}')),
        ],
      ),
      onTap: () => context.go('${Rutas.chats}/${conversacion.conversacionId}'),
    );
  }
}

/// Insignia con el total de mensajes sin leer.
class InsigniaChat extends ConsumerWidget {
  const InsigniaChat({required this.hijo, super.key});

  final Widget hijo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = ref.watch(noLeidasChatProvider).value ?? 0;
    if (total <= 0) {
      return hijo;
    }
    return Badge(label: Text(total > 99 ? '99+' : '$total'), child: hijo);
  }
}
