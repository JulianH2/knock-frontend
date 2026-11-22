import 'package:app/features/visitas/domain/visita_acciones.dart';
import 'package:app/features/visitas/presentation/mensajes_visita.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Texto para compartir con alguien de confianza (`POST /visitas/{id}/aviso`).
/// La app no envía nada ni guarda contactos: la persona copia el texto. El
/// servidor nunca incluye el código ni la dirección.
class DialogoAviso extends StatefulWidget {
  const DialogoAviso({required this.pedir, super.key});

  final Future<({AvisoConfianza? aviso, Object? error})> Function() pedir;

  @override
  State<DialogoAviso> createState() => _DialogoAvisoState();
}

class _DialogoAvisoState extends State<DialogoAviso> {
  late Future<({AvisoConfianza? aviso, Object? error})> _futuro = widget
      .pedir();
  bool _copiado = false;

  void _reintentar() => setState(() => _futuro = widget.pedir());

  Future<void> _copiar(String texto) async {
    await Clipboard.setData(ClipboardData(text: texto));
    if (mounted) {
      setState(() => _copiado = true);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Avisar a alguien de confianza'),
    content: FutureBuilder(
      future: _futuro,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const SizedBox(
            height: 64,
            child: Center(
              child: CircularProgressIndicator(
                semanticsLabel: 'Preparando el aviso',
              ),
            ),
          );
        }
        final r = snap.requireData;
        if (r.error != null) {
          return Text(mensajeDeErrorVisita(r.error!));
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Copia este texto y compártelo tú. No incluye el código ni la '
              'dirección.',
            ),
            const SizedBox(height: 12),
            SelectableText(r.aviso!.texto),
            if (_copiado) const Text('Texto copiado.'),
          ],
        );
      },
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cerrar'),
      ),
      FutureBuilder(
        future: _futuro,
        builder: (context, snap) {
          final r = snap.data;
          if (r == null) {
            return const SizedBox.shrink();
          }
          return r.error != null
              ? FilledButton(
                  onPressed: _reintentar,
                  child: const Text('Reintentar'),
                )
              : FilledButton(
                  onPressed: () => _copiar(r.aviso!.texto),
                  child: const Text('Copiar texto'),
                );
        },
      ),
    ],
  );
}
