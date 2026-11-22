import 'package:app/core/router/rutas.dart';
import 'package:app/core/widgets/estados.dart';
import 'package:app/features/chat/chat_providers.dart';
import 'package:app/features/chat/presentation/chat_screen.dart';
import 'package:app/features/chat/presentation/conversaciones_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Crea o recupera la conversación del par (solicitud, técnico) y abre el
/// chat. `POST /conversaciones`: 201 la primera vez, 200 si ya existía; los
/// errores (409 `conversation_closed`, 404, 422, 429, 503) se explican en un
/// aviso y no navegan.
Future<void> abrirConversacion(
  BuildContext context,
  WidgetRef ref, {
  required String solicitudId,
  String? tecnicoId,
}) async {
  final mensajero = ScaffoldMessenger.of(context);
  final ir = GoRouter.of(context).go;
  try {
    final creada = await ref
        .read(conversacionesRepositoryProvider)
        .crear(solicitudId: solicitudId, tecnicoId: tecnicoId);
    if (creada.nueva) {
      ref.invalidate(conversacionesControllerProvider);
    }
    ir('${Rutas.chats}/${creada.conversacion.conversacionId}');
  } on Object catch (e) {
    mensajero.showSnackBar(
      SnackBar(
        content: Text(
          mensajeDeError(
            e,
            porDefecto: 'No pudimos abrir la conversación. Intenta de nuevo.',
            porCodigo: mensajesDeErrorChat,
          ),
        ),
      ),
    );
  }
}

/// Botón «Enviar mensaje» para colgar en el detalle de una solicitud o de una
/// cotización. Se usa con la solicitud y, si quien mira es el cliente, el
/// técnico.
class BotonAbrirChat extends ConsumerStatefulWidget {
  const BotonAbrirChat({required this.solicitudId, this.tecnicoId, super.key});

  final String solicitudId;
  final String? tecnicoId;

  @override
  ConsumerState<BotonAbrirChat> createState() => _BotonAbrirChatState();
}

class _BotonAbrirChatState extends ConsumerState<BotonAbrirChat> {
  bool _abriendo = false;

  Future<void> _abrir() async {
    if (_abriendo) {
      return;
    }
    setState(() => _abriendo = true);
    await abrirConversacion(
      context,
      ref,
      solicitudId: widget.solicitudId,
      tecnicoId: widget.tecnicoId,
    );
    if (mounted) {
      setState(() => _abriendo = false);
    }
  }

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: _abriendo ? null : _abrir,
    icon: _abriendo
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Icon(Icons.chat_bubble_outline),
    label: const Text('Enviar mensaje'),
  );
}
