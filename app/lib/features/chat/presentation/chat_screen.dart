import 'package:app/core/datos/formato_fecha.dart';
import 'package:app/core/widgets/estados.dart';
import 'package:app/features/chat/domain/chat.dart';
import 'package:app/features/chat/presentation/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Textos por código de dominio del chat (contrato de Mensajería).
const Map<String, String> mensajesDeErrorChat = {
  'content_rejected':
      'No pudimos enviar el mensaje porque no cumple las reglas de contenido.',
  'message_limit':
      'Enviaste muchos mensajes en poco tiempo. Espera un momento.',
  'conversation_closed': 'Esta conversación ya está cerrada.',
  'moderation_unavailable':
      'No pudimos revisar tu mensaje ahora. Intenta de nuevo en un momento.',
  'market_unavailable':
      'No pudimos enviar el mensaje por ahora. Intenta de nuevo en un momento.',
};

/// Chat de una conversación (KNOCK-72/73): historial con cursor, enviar y
/// estados de carga, error y conversación cerrada.
class ChatScreen extends ConsumerWidget {
  const ChatScreen({required this.conversacionId, super.key});

  final String conversacionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proveedor = chatControllerProvider(conversacionId);
    final estado = ref.watch(proveedor);
    final controlador = ref.read(proveedor.notifier);

    if (estado.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chat')),
        body: const CargandoCentrado(etiqueta: 'Cargando conversación'),
      );
    }
    if (estado.hasError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chat')),
        body: MensajeCentrado(
          texto: mensajeDeError(
            estado.error!,
            porDefecto: 'No pudimos cargar la conversación',
          ),
          etiquetaAccion: 'Reintentar',
          alPulsar: controlador.reintentar,
        ),
      );
    }
    final chat = estado.requireValue;
    return Scaffold(
      appBar: AppBar(
        title: Text(chat.conversacion.contraparte.nombre),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(chat.conversacion.servicio),
          ),
        ),
      ),
      body: Column(
        children: [
          if (chat.conversacion.avisoSeguridad != null)
            MaterialBanner(
              content: Text(chat.conversacion.avisoSeguridad!),
              actions: const [SizedBox.shrink()],
            ),
          Expanded(
            child: _Mensajes(chat: chat, controlador: controlador),
          ),
          if (chat.conversacion.cerrada)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Esta conversación ya está cerrada.'),
            )
          else
            _Redaccion(controlador: controlador, enviando: chat.enviando),
        ],
      ),
    );
  }
}

class _Mensajes extends StatelessWidget {
  const _Mensajes({required this.chat, required this.controlador});

  final EstadoChat chat;
  final ChatController controlador;

  @override
  Widget build(BuildContext context) {
    if (chat.mensajes.isEmpty) {
      return const MensajeCentrado(texto: 'Escribe el primer mensaje');
    }
    // `reverse`: el más reciente queda abajo; "anteriores" va al final de la
    // lista, o sea arriba en pantalla.
    return ListView(
      reverse: true,
      padding: const EdgeInsets.all(8),
      children: [
        for (final m in chat.mensajes)
          _Burbuja(key: ValueKey(m.mensajeId), mensaje: m, mio: chat.esMio(m)),
        if (chat.huboErrorAlCargarAnteriores)
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              'No pudimos cargar mensajes anteriores',
              textAlign: TextAlign.center,
            ),
          ),
        if (chat.nextCursor != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: chat.cargandoAnteriores
                ? const Center(
                    child: CircularProgressIndicator(
                      semanticsLabel: 'Cargando mensajes anteriores',
                    ),
                  )
                : TextButton(
                    onPressed: controlador.cargarAnteriores,
                    child: const Text('Cargar mensajes anteriores'),
                  ),
          ),
      ],
    );
  }
}

class _Burbuja extends StatelessWidget {
  const _Burbuja({required this.mensaje, required this.mio, super.key});

  final Mensaje mensaje;
  final bool mio;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Align(
      alignment: mio ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.8,
        ),
        decoration: BoxDecoration(
          color: mio ? esquema.primaryContainer : esquema.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mensaje.texto),
            if (mensaje.contactoOculto)
              const Text(
                'Se ocultó un dato de contacto',
                style: TextStyle(fontSize: 12),
              ),
            Text(
              horaCorta(mensaje.enviadoEn),
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _Redaccion extends StatefulWidget {
  const _Redaccion({required this.controlador, required this.enviando});

  final ChatController controlador;
  final bool enviando;

  @override
  State<_Redaccion> createState() => _RedaccionState();
}

class _RedaccionState extends State<_Redaccion> {
  final _texto = TextEditingController();

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final mensajero = ScaffoldMessenger.of(context);
    final contenido = _texto.text;
    final error = await widget.controlador.enviar(contenido);
    if (error == null) {
      _texto.clear();
      return;
    }
    mensajero.showSnackBar(
      SnackBar(
        content: Text(
          mensajeDeError(
            error,
            porDefecto: 'No pudimos enviar el mensaje. Intenta de nuevo.',
            porCodigo: mensajesDeErrorChat,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _texto,
              minLines: 1,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Escribe un mensaje',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Enviar',
            onPressed: widget.enviando ? null : _enviar,
            icon: widget.enviando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
          ),
        ],
      ),
    ),
  );
}
