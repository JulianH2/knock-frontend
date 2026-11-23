import 'package:app/core/datos/formato_fecha.dart';
import 'package:app/core/errores/failure.dart';
import 'package:app/core/widgets/estados.dart';
import 'package:app/features/chat/domain/chat.dart';
import 'package:app/features/chat/presentation/chat_controller.dart';
import 'package:material_ui/material_ui.dart';
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

/// Por qué se cerró una conversación (`motivoCierre` del contrato de Mensajería).
const Map<String, String> motivosDeCierreChat = {
  'request_cancelled':
      'Esta conversación se cerró porque se canceló la solicitud.',
  'request_expired': 'Esta conversación se cerró porque la solicitud venció.',
  'other_quote_chosen':
      'Esta conversación se cerró porque se eligió otra cotización.',
  'dismissed': 'Esta conversación se cerró porque se descartó la solicitud.',
  'service_finished': 'Esta conversación se cerró porque el servicio terminó.',
};

/// Texto de una conversación cerrada: el motivo si se conoce, o el genérico.
String textoDeConversacionCerrada(String? motivoCierre) =>
    motivosDeCierreChat[motivoCierre] ?? 'Esta conversación ya está cerrada.';

/// Texto bajo un mensaje que no salió.
String textoDeFalloDeEnvio(Object? error) => mensajeDeError(
  error ?? const DatosInvalidosFailure(),
  porDefecto: 'No pudimos enviar el mensaje. Intenta de nuevo.',
  porCodigo: mensajesDeErrorChat,
);

/// Chat de una conversación (KNOCK-72): historial con cursor, envío optimista
/// con reintento, espera por límite, aviso de seguridad y estados de carga,
/// error (503, 404) y conversación cerrada.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({required this.conversacionId, super.key});

  final String conversacionId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState estado) {
    ref
        .read(chatControllerProvider(widget.conversacionId).notifier)
        .visible(valor: estado == AppLifecycleState.resumed);
  }

  @override
  Widget build(BuildContext context) {
    final proveedor = chatControllerProvider(widget.conversacionId);
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
          _AvisoDeSeguridad(
            texto: chat.conversacion.avisoSeguridad ?? avisoSeguridadPorOmision,
          ),
          Expanded(
            child: _Mensajes(chat: chat, controlador: controlador),
          ),
          if (chat.conversacion.cerrada)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                textoDeConversacionCerrada(chat.conversacion.motivoCierre),
              ),
            )
          else
            _Redaccion(controlador: controlador, chat: chat),
        ],
      ),
    );
  }
}

class _AvisoDeSeguridad extends StatelessWidget {
  const _AvisoDeSeguridad({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      color: esquema.secondaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(texto)),
        ],
      ),
    );
  }
}

class _Mensajes extends StatefulWidget {
  const _Mensajes({required this.chat, required this.controlador});

  final EstadoChat chat;
  final ChatController controlador;

  @override
  State<_Mensajes> createState() => _MensajesState();
}

class _MensajesState extends State<_Mensajes> {
  final _scroll = ScrollController();
  bool _hayNuevos = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_alDesplazar);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  bool get _abajo => !_scroll.hasClients || _scroll.offset <= 48;

  void _alDesplazar() {
    final chat = widget.chat;
    if (_hayNuevos && _abajo) {
      setState(() => _hayNuevos = false);
    }
    // Cerca del final de la lista (arriba en pantalla): pide el siguiente
    // tramo del historial.
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 120 &&
        chat.nextCursor != null &&
        !chat.cargandoAnteriores &&
        !chat.huboErrorAlCargarAnteriores) {
      widget.controlador.cargarAnteriores();
    }
  }

  @override
  void didUpdateWidget(_Mensajes anterior) {
    super.didUpdateWidget(anterior);
    final antes = anterior.chat;
    final ahora = widget.chat;
    final propioNuevo = ahora.pendientes.length > antes.pendientes.length;
    final llegoAlgo =
        ahora.mensajes.isNotEmpty &&
        (antes.mensajes.isEmpty ||
            ahora.mensajes.first.mensajeId != antes.mensajes.first.mensajeId) &&
        ahora.mensajes.length > antes.mensajes.length &&
        // Si crece por abajo del historial (cargar anteriores) no es nuevo.
        (antes.mensajes.isEmpty ||
            ahora.mensajes.first.enviadoEn.isAfter(
              antes.mensajes.first.enviadoEn,
            ));
    if (propioNuevo || (llegoAlgo && ahora.esMio(ahora.mensajes.first))) {
      _irAlFinal();
    } else if (llegoAlgo && !_abajo) {
      _hayNuevos = true;
    }
  }

  void _irAlFinal() {
    setState(() => _hayNuevos = false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chat = widget.chat;
    if (chat.mensajes.isEmpty && chat.pendientes.isEmpty) {
      return const MensajeCentrado(texto: 'Escribe el primer mensaje');
    }
    // `reverse`: el más reciente queda abajo; "anteriores" va al final de la
    // lista, o sea arriba en pantalla.
    return Stack(
      children: [
        ListView(
          controller: _scroll,
          reverse: true,
          padding: const EdgeInsets.all(8),
          children: [
            for (final p in chat.pendientes.reversed)
              _BurbujaPendiente(
                key: ValueKey(p.localId),
                pendiente: p,
                controlador: widget.controlador,
                esperando: chat.segundosEspera > 0 || chat.enviando,
              ),
            for (final m in chat.mensajes)
              _Burbuja(
                key: ValueKey(m.mensajeId),
                mensaje: m,
                mio: chat.esMio(m),
              ),
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
                        onPressed: widget.controlador.cargarAnteriores,
                        child: const Text('Cargar mensajes anteriores'),
                      ),
              ),
          ],
        ),
        if (_hayNuevos)
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Center(
              child: FilledButton.tonalIcon(
                onPressed: _irAlFinal,
                icon: const Icon(Icons.arrow_downward, size: 18),
                label: const Text('Mensajes nuevos'),
              ),
            ),
          ),
      ],
    );
  }
}

class _Globo extends StatelessWidget {
  const _Globo({
    required this.mio,
    required this.hijo,
    this.atenuado = false,
    this.conError = false,
  });

  final bool mio;
  final Widget hijo;
  final bool atenuado;
  final bool conError;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Align(
      alignment: mio ? Alignment.centerRight : Alignment.centerLeft,
      child: Opacity(
        opacity: atenuado ? 0.6 : 1,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(10),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.8,
          ),
          decoration: BoxDecoration(
            color: conError
                ? esquema.errorContainer
                : mio
                ? esquema.primaryContainer
                : esquema.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
          ),
          child: hijo,
        ),
      ),
    );
  }
}

class _Burbuja extends StatelessWidget {
  const _Burbuja({required this.mensaje, required this.mio, super.key});

  final Mensaje mensaje;
  final bool mio;

  @override
  Widget build(BuildContext context) => _Globo(
    mio: mio,
    hijo: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(mensaje.texto),
        if (mensaje.contactoOculto)
          const Text(
            'Se ocultó un dato de contacto',
            style: TextStyle(fontSize: 12),
          ),
        Text(
          mio
              ? '${horaCorta(mensaje.enviadoEn)} · Enviado'
              : horaCorta(mensaje.enviadoEn),
          style: const TextStyle(fontSize: 11),
        ),
      ],
    ),
  );
}

class _BurbujaPendiente extends StatelessWidget {
  const _BurbujaPendiente({
    required this.pendiente,
    required this.controlador,
    required this.esperando,
    super.key,
  });

  final MensajePendiente pendiente;
  final ChatController controlador;
  final bool esperando;

  @override
  Widget build(BuildContext context) {
    final fallido = pendiente.estado == EstadoEnvio.fallido;
    return _Globo(
      mio: true,
      atenuado: !fallido,
      conError: fallido,
      hijo: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(pendiente.texto),
          if (!fallido)
            const Text('Enviando…', style: TextStyle(fontSize: 11))
          else ...[
            Text(
              'No se envió. ${textoDeFalloDeEnvio(pendiente.error)}',
              style: const TextStyle(fontSize: 12),
            ),
            Wrap(
              spacing: 8,
              children: [
                if (pendiente.reintentable)
                  TextButton(
                    onPressed: esperando
                        ? null
                        : () => controlador.reintentarEnvio(pendiente.localId),
                    child: const Text('Reintentar'),
                  ),
                TextButton(
                  onPressed: () => controlador.descartar(pendiente.localId),
                  child: const Text('Descartar'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Redaccion extends StatefulWidget {
  const _Redaccion({required this.controlador, required this.chat});

  final ChatController controlador;
  final EstadoChat chat;

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

  bool get _demasiadoLargo => mensajeDemasiadoLargo(_texto.text);

  bool get _vacio => _texto.text.trim().isEmpty;

  void _enviar() {
    if (widget.controlador.enviar(_texto.text)) {
      _texto.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final chat = widget.chat;
    final espera = chat.segundosEspera;
    final puede = !chat.enviando && espera == 0 && !_vacio && !_demasiadoLargo;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (espera > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Enviaste muchos mensajes. Podrás enviar otro en $espera s.',
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _texto,
                    minLines: 1,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje',
                      border: const OutlineInputBorder(),
                      errorText: _demasiadoLargo
                          ? 'El mensaje es demasiado largo (máximo '
                                '$maxCaracteresMensaje caracteres).'
                          : null,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Enviar',
                  onPressed: puede ? _enviar : null,
                  icon: chat.enviando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
