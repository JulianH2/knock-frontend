import 'package:app/core/widgets/estados.dart';
import 'package:app/features/visitas/domain/visita_acciones.dart';
import 'package:app/features/visitas/presentation/horarios_controller.dart';
import 'package:app/features/visitas/presentation/mensajes_visita.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Horarios del técnico: ver y editar los siete días (TEC-10/11). Cada día
/// está cerrado o abierto con una o dos franjas.
class HorariosScreen extends ConsumerWidget {
  const HorariosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(horariosControllerProvider);
    final controlador = ref.read(horariosControllerProvider.notifier);
    final Widget cuerpo;
    if (estado.hasValue) {
      cuerpo = _Editor(original: estado.requireValue, controlador: controlador);
    } else if (estado.isLoading) {
      cuerpo = const CargandoCentrado(etiqueta: 'Cargando horarios');
    } else {
      cuerpo = MensajeCentrado(
        texto: mensajeDeError(
          estado.error!,
          porDefecto: 'No pudimos cargar tus horarios',
        ),
        etiquetaAccion: 'Reintentar',
        alPulsar: controlador.reintentar,
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Mis horarios')),
      body: cuerpo,
    );
  }
}

String _hhmm(int minutos) =>
    '${(minutos ~/ 60).toString().padLeft(2, '0')}:'
    '${(minutos % 60).toString().padLeft(2, '0')}';

TimeOfDay _hora(String hhmm) {
  final m = minutosDeHora(hhmm) ?? 540;
  return TimeOfDay(hour: m ~/ 60, minute: m % 60);
}

bool _mismasFranjas(List<FranjaHorario> a, List<FranjaHorario> b) {
  if (a.length != b.length) {
    return false;
  }
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}

class _Editor extends StatefulWidget {
  const _Editor({required this.original, required this.controlador});

  final List<HorarioDia> original;
  final HorariosController controlador;

  @override
  State<_Editor> createState() => _EditorState();
}

class _EditorState extends State<_Editor> {
  late List<HorarioDia> _borrador = [...widget.original];
  bool _guardando = false;
  bool _mostrarErrores = false;

  @override
  void didUpdateWidget(_Editor anterior) {
    super.didUpdateWidget(anterior);
    // Tras guardar o recargar, el servidor es la nueva base del borrador.
    if (!identical(anterior.original, widget.original)) {
      _borrador = [...widget.original];
      _mostrarErrores = false;
    }
  }

  bool get _hayCambios {
    for (var i = 0; i < _borrador.length; i++) {
      final a = _borrador[i];
      final b = widget.original[i];
      if (a.abierto != b.abierto || !_mismasFranjas(a.franjas, b.franjas)) {
        return true;
      }
    }
    return false;
  }

  void _cambiar(int i, HorarioDia dia) =>
      setState(() => _borrador = [..._borrador]..[i] = dia);

  void _abrirCerrar(int i, bool abierto) {
    final d = _borrador[i];
    _cambiar(
      i,
      abierto
          ? d.copiar(
              abierto: true,
              franjas: d.franjas.isEmpty
                  ? const [FranjaHorario(inicio: '09:00', fin: '18:00')]
                  : d.franjas,
            )
          : d.copiar(abierto: false, franjas: const []),
    );
  }

  Future<void> _elegirHora(int dia, int franja, {required bool inicio}) async {
    final f = _borrador[dia].franjas[franja];
    final t = await showTimePicker(
      context: context,
      initialTime: _hora(inicio ? f.inicio : f.fin),
    );
    if (t == null || !mounted) {
      return;
    }
    final texto = _hhmm(t.hour * 60 + t.minute);
    final nueva = inicio
        ? FranjaHorario(inicio: texto, fin: f.fin)
        : FranjaHorario(inicio: f.inicio, fin: texto);
    final franjas = [..._borrador[dia].franjas]..[franja] = nueva;
    _cambiar(dia, _borrador[dia].copiar(franjas: franjas));
  }

  void _agregarFranja(int i) {
    final d = _borrador[i];
    final fin = d.franjas.isEmpty ? 0 : minutosDeHora(d.franjas.last.fin) ?? 0;
    final inicio = (fin + 60).clamp(0, 22 * 60);
    _cambiar(
      i,
      d.copiar(
        franjas: [
          ...d.franjas,
          FranjaHorario(inicio: _hhmm(inicio), fin: _hhmm(inicio + 60)),
        ],
      ),
    );
  }

  void _quitarFranja(int dia, int franja) {
    final franjas = [..._borrador[dia].franjas]..removeAt(franja);
    _cambiar(dia, _borrador[dia].copiar(franjas: franjas));
  }

  Future<void> _guardar() async {
    if (_guardando) {
      return;
    }
    if (errorHorarios(_borrador) != null) {
      setState(() => _mostrarErrores = true);
      return;
    }
    final mensajero = ScaffoldMessenger.of(context);
    setState(() => _guardando = true);
    final r = await widget.controlador.guardar(_borrador);
    if (!mounted) {
      return;
    }
    setState(() => _guardando = false);
    mensajero.showSnackBar(
      SnackBar(
        content: Text(
          r.error != null ? mensajeDeErrorVisita(r.error!) : (r.mensaje ?? ''),
        ),
      ),
    );
  }

  Future<bool> _confirmarSalida() async {
    final salir = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('¿Descartar los cambios?'),
        content: const Text('Tienes cambios sin guardar en tus horarios.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Seguir editando'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    return salir ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final colorError = Theme.of(context).colorScheme.error;
    return PopScope(
      canPop: !_hayCambios,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          return;
        }
        final navegador = Navigator.of(context);
        if (await _confirmarSalida()) {
          navegador.pop();
        }
      },
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Marca los días que atiendes y su horario (una o dos '
                  'franjas, en horario de 24 horas).',
                ),
                for (var i = 0; i < _borrador.length; i++)
                  _DiaEditor(
                    dia: _borrador[i],
                    error: _mostrarErrores
                        ? errorHorarioDia(_borrador[i])
                        : null,
                    colorError: colorError,
                    deshabilitado: _guardando,
                    alAbrirCerrar: (v) => _abrirCerrar(i, v),
                    alElegirHora: (f, {required inicio}) =>
                        _elegirHora(i, f, inicio: inicio),
                    alAgregar: () => _agregarFranja(i),
                    alQuitar: (f) => _quitarFranja(i, f),
                  ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _guardando || !_hayCambios ? null : _guardar,
                  child: _guardando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            semanticsLabel: 'Guardando',
                          ),
                        )
                      : const Text('Guardar horarios'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiaEditor extends StatelessWidget {
  const _DiaEditor({
    required this.dia,
    required this.error,
    required this.colorError,
    required this.deshabilitado,
    required this.alAbrirCerrar,
    required this.alElegirHora,
    required this.alAgregar,
    required this.alQuitar,
  });

  final HorarioDia dia;
  final String? error;
  final Color colorError;
  final bool deshabilitado;
  final ValueChanged<bool> alAbrirCerrar;
  final void Function(int franja, {required bool inicio}) alElegirHora;
  final VoidCallback alAgregar;
  final ValueChanged<int> alQuitar;

  @override
  Widget build(BuildContext context) {
    final nombre = nombreDeDia(dia.dia);
    return Card(
      key: ValueKey('dia-${dia.dia}'),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: Text(nombre),
              subtitle: Text(dia.abierto ? 'Abierto' : 'Cerrado'),
              value: dia.abierto,
              onChanged: deshabilitado ? null : alAbrirCerrar,
            ),
            for (var f = 0; f < dia.franjas.length; f++)
              Row(
                children: [
                  TextButton(
                    onPressed: deshabilitado
                        ? null
                        : () => alElegirHora(f, inicio: true),
                    child: Text('De ${dia.franjas[f].inicio}'),
                  ),
                  TextButton(
                    onPressed: deshabilitado
                        ? null
                        : () => alElegirHora(f, inicio: false),
                    child: Text('a ${dia.franjas[f].fin}'),
                  ),
                  if (dia.franjas.length > 1)
                    IconButton(
                      tooltip: 'Quitar franja de $nombre',
                      onPressed: deshabilitado ? null : () => alQuitar(f),
                      icon: const Icon(Icons.delete_outline),
                    ),
                ],
              ),
            if (dia.abierto && dia.franjas.length < 2)
              TextButton.icon(
                onPressed: deshabilitado ? null : alAgregar,
                icon: const Icon(Icons.add),
                label: Text('Agregar franja de $nombre'),
              ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(error!, style: TextStyle(color: colorError)),
              ),
          ],
        ),
      ),
    );
  }
}
