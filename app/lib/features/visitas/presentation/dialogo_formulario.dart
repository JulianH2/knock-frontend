import 'package:app/features/visitas/domain/visita_acciones.dart';
import 'package:app/features/visitas/presentation/mensajes_visita.dart';
import 'package:app/features/visitas/presentation/visitas_controller.dart';
import 'package:app/features/visitas/visitas_providers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Campo de texto de un formulario de acción. `validar` devuelve el texto del
/// error o `null`.
class CampoFormulario {
  const CampoFormulario({
    required this.clave,
    required this.etiqueta,
    required this.validar,
    this.maxLength,
    this.lineas = 1,
    this.soloDigitos = false,
    this.ayuda,
  });

  final String clave;
  final String etiqueta;
  final String? Function(String valor) validar;
  final int? maxLength;
  final int lineas;
  final bool soloDigitos;
  final String? ayuda;
}

/// Botón de envío del diálogo. Una acción sin `validar` (p. ej. «Rechazar»)
/// no exige que el formulario esté completo.
class OpcionDialogo {
  const OpcionDialogo({
    required this.etiqueta,
    required this.enviar,
    this.validar = true,
    this.principal = true,
  });

  final String etiqueta;
  final bool validar;
  final bool principal;
  final Future<ResultadoAccion> Function(
    Map<String, String> valores,
    List<String> fotos,
  )
  enviar;
}

/// Diálogo de acción de visita: campos con validación, fotos opcionales,
/// confirmación y envío. Mientras envía deshabilita los botones (sin doble
/// envío) y muestra un indicador; si el servidor rechaza, deja el error dentro
/// del diálogo para que la persona corrija sin perder lo escrito. Al terminar
/// cierra con el mensaje de éxito.
class DialogoFormulario extends ConsumerStatefulWidget {
  const DialogoFormulario({
    required this.titulo,
    required this.opciones,
    this.mensaje,
    this.campos = const [],
    this.conFotos = false,
    this.etiquetaVolver = 'Volver',
    super.key,
  });

  final String titulo;
  final String? mensaje;
  final List<CampoFormulario> campos;
  final bool conFotos;
  final String etiquetaVolver;
  final List<OpcionDialogo> opciones;

  @override
  ConsumerState<DialogoFormulario> createState() => _DialogoFormularioState();
}

class _DialogoFormularioState extends ConsumerState<DialogoFormulario> {
  late final Map<String, TextEditingController> _controles = {
    for (final c in widget.campos) c.clave: TextEditingController(),
  };
  final Map<String, String?> _errores = {};
  final List<String> _fotos = [];
  String? _errorFotos;
  String? _errorEnvio;
  bool _enviando = false;

  @override
  void dispose() {
    for (final c in _controles.values) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, String> get _valores => {
    for (final e in _controles.entries) e.key: e.value.text,
  };

  bool _validar() {
    var ok = true;
    for (final c in widget.campos) {
      final e = c.validar(_controles[c.clave]!.text);
      _errores[c.clave] = e;
      ok = ok && e == null;
    }
    if (widget.conFotos) {
      _errorFotos = errorFotos(_fotos.length);
      ok = ok && _errorFotos == null;
    }
    return ok;
  }

  Future<void> _enviar(OpcionDialogo opcion) async {
    if (_enviando) {
      return;
    }
    if (opcion.validar) {
      setState(() => _errorEnvio = null);
      if (!_validar()) {
        setState(() {});
        return;
      }
    }
    setState(() {
      _enviando = true;
      _errorEnvio = null;
    });
    final r = await opcion.enviar(_valores, List.unmodifiable(_fotos));
    if (!mounted) {
      return;
    }
    if (r.error != null) {
      setState(() {
        _enviando = false;
        _errorEnvio = mensajeDeErrorVisita(r.error!);
      });
      return;
    }
    Navigator.of(context).pop(r.mensaje ?? '');
  }

  Future<void> _agregarFotos() async {
    final cupo = LimitesVisita.fotosMax - _fotos.length;
    if (cupo <= 0) {
      return;
    }
    try {
      final nuevas = await ref.read(selectorFotosProvider).elegir(maximo: cupo);
      if (!mounted) {
        return;
      }
      setState(() {
        _fotos.addAll(nuevas.take(cupo));
        _errorFotos = null;
        _errorEnvio = null;
      });
    } on Object {
      if (!mounted) {
        return;
      }
      setState(() => _errorEnvio = 'Agregar fotos todavía no está disponible.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return AlertDialog(
      title: Text(widget.titulo),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.mensaje != null) Text(widget.mensaje!),
            for (final c in widget.campos) ...[
              const SizedBox(height: 12),
              TextField(
                key: ValueKey('campo-${c.clave}'),
                controller: _controles[c.clave],
                enabled: !_enviando,
                maxLength: c.maxLength,
                minLines: c.lineas,
                maxLines: c.lineas,
                keyboardType: c.soloDigitos ? TextInputType.number : null,
                inputFormatters: [
                  if (c.soloDigitos) FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  labelText: c.etiqueta,
                  helperText: c.ayuda,
                  errorText: _errores[c.clave],
                ),
              ),
            ],
            if (widget.conFotos) ...[
              const SizedBox(height: 12),
              Text(
                'Fotos del trabajo (${_fotos.length} de '
                '${LimitesVisita.fotosMax})',
              ),
              OutlinedButton.icon(
                onPressed: _enviando || _fotos.length >= LimitesVisita.fotosMax
                    ? null
                    : _agregarFotos,
                icon: const Icon(Icons.add_a_photo_outlined),
                label: const Text('Agregar fotos'),
              ),
              if (_errorFotos != null)
                Text(
                  _errorFotos!,
                  style: TextStyle(color: tema.colorScheme.error),
                ),
            ],
            if (_errorEnvio != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorEnvio!,
                style: TextStyle(color: tema.colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _enviando ? null : () => Navigator.of(context).pop(),
          child: Text(widget.etiquetaVolver),
        ),
        for (final o in widget.opciones)
          if (o.principal)
            FilledButton(
              onPressed: _enviando ? null : () => _enviar(o),
              child: _enviando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        semanticsLabel: 'Enviando',
                      ),
                    )
                  : Text(o.etiqueta),
            )
          else
            OutlinedButton(
              onPressed: _enviando ? null : () => _enviar(o),
              child: Text(o.etiqueta),
            ),
      ],
    );
  }
}
