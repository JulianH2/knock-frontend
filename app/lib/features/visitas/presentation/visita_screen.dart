import 'package:app/core/errores/failure.dart';
import 'package:app/core/widgets/estados.dart';
import 'package:app/features/visitas/domain/visita.dart';
import 'package:app/features/visitas/presentation/agenda_screen.dart';
import 'package:app/features/visitas/presentation/visitas_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Texto para el error de una acción de visita. Una regla de negocio (409/422)
/// dice que la visita ya no permite la acción; una ruta que aún no existe en
/// el gateway no es un fallo de la app.
String mensajeDeErrorVisita(Object error) => switch (error) {
  ReglaDeNegocioFailure() => 'La visita ya no permite esta acción.',
  DatosInvalidosFailure() => 'Revisa los datos e intenta de nuevo.',
  _ => mensajeDeError(error, porDefecto: 'No pudimos completar la acción.'),
};

/// Detalle de la visita con sus acciones: reprogramar, responder a una
/// propuesta, cancelar y «no se presentó».
class VisitaScreen extends ConsumerWidget {
  const VisitaScreen({required this.visitaId, super.key});

  final String visitaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proveedor = visitaControllerProvider(visitaId);
    final estado = ref.watch(proveedor);
    final controlador = ref.read(proveedor.notifier);

    final Widget cuerpo;
    // Con datos previos se sigue mostrando el detalle mientras se refresca.
    if (estado.hasValue) {
      cuerpo = _Detalle(visita: estado.requireValue, controlador: controlador);
    } else if (estado.isLoading) {
      cuerpo = const CargandoCentrado(etiqueta: 'Cargando visita');
    } else if (estado.hasError) {
      cuerpo = MensajeCentrado(
        texto: mensajeDeError(
          estado.error!,
          porDefecto: 'No pudimos cargar la visita',
        ),
        etiquetaAccion: 'Reintentar',
        alPulsar: controlador.reintentar,
      );
    } else {
      cuerpo = const SizedBox.shrink();
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Visita')),
      body: cuerpo,
    );
  }
}

class _Detalle extends StatelessWidget {
  const _Detalle({required this.visita, required this.controlador});

  final Visita visita;
  final VisitaController controlador;

  Future<void> _mostrar(
    BuildContext context,
    Future<ResultadoAccion> Function() accion,
  ) async {
    final mensajero = ScaffoldMessenger.of(context);
    final r = await accion();
    final texto = r.error != null
        ? mensajeDeErrorVisita(r.error!)
        : (r.mensaje ?? '');
    mensajero.showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _reprogramar(BuildContext context) async {
    final ahora = DateTime.now();
    final dia = await showDatePicker(
      context: context,
      initialDate: ahora.add(const Duration(days: 1)),
      firstDate: ahora,
      lastDate: ahora.add(const Duration(days: 60)),
    );
    if (dia == null || !context.mounted) {
      return;
    }
    final hora = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (hora == null || !context.mounted) {
      return;
    }
    final elegida = DateTime(
      dia.year,
      dia.month,
      dia.day,
      hora.hour,
      hora.minute,
    );
    await _mostrar(context, () => controlador.reprogramar(elegida));
  }

  Future<void> _responder(BuildContext context) async {
    final acepta = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text('Nuevo horario propuesto'),
        content: const Text('¿Aceptas el nuevo horario de la visita?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contexto, false),
            child: const Text('Rechazar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(contexto, true),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
    if (acepta == null || !context.mounted) {
      return;
    }
    await _mostrar(context, () => controlador.responder(acepta: acepta));
  }

  Future<void> _cancelar(BuildContext context) async {
    final motivo = await showDialog<String>(
      context: context,
      builder: (contexto) => const _DialogoMotivo(),
    );
    if (motivo == null || !context.mounted) {
      return;
    }
    await _mostrar(context, () => controlador.cancelar(motivo));
  }

  Future<void> _noSePresento(BuildContext context) async {
    final confirma = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: Text(_textoNoSePresento(visita.rol)),
        content: const Text('Se registrará en la visita. ¿Continuar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contexto, false),
            child: const Text('Volver'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(contexto, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (confirma != true || !context.mounted) {
      return;
    }
    await _mostrar(context, controlador.noSePresento);
  }

  @override
  Widget build(BuildContext context) {
    final cancelada = visita.estado == 'cancelada';
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          '${visita.dia} · ${visita.hora}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text('Estado: ${textoEstadoVisita(visita.estado)}'),
        Text(visita.modalidad == 'taller' ? 'En taller' : 'A domicilio'),
        if (visita.precio != null) Text('Precio: \$${visita.precio}'),
        Text('Tope: \$${visita.tope}'),
        if (visita.tecnico != null)
          Text(
            'Técnico: ${visita.tecnico!.nombre}'
            '${visita.tecnico!.verificado ? ' (verificado)' : ''}',
          ),
        if (visita.coloniaCliente != null)
          Text('Colonia: ${visita.coloniaCliente}'),
        if (visita.lugar.direccion != null)
          Text('Lugar: ${visita.lugar.direccion}'),
        if (visita.codigo != null)
          Text('Código de la visita: ${visita.codigo}'),
        if (visita.reglaSeguridad != null) ...[
          const SizedBox(height: 8),
          Text(visita.reglaSeguridad!),
        ],
        const SizedBox(height: 16),
        if (!cancelada) ...[
          FilledButton.icon(
            onPressed: () => _reprogramar(context),
            icon: const Icon(Icons.edit_calendar_outlined),
            label: const Text('Reprogramar'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => _responder(context),
            child: const Text('Responder a un nuevo horario'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => _noSePresento(context),
            child: Text(_textoNoSePresento(visita.rol)),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _cancelar(context),
            child: const Text('Cancelar visita'),
          ),
        ],
      ],
    );
  }
}

/// Diálogo con el campo del motivo; el controlador de texto vive en su estado
/// para liberarse cuando termina la animación de cierre.
class _DialogoMotivo extends StatefulWidget {
  const _DialogoMotivo();

  @override
  State<_DialogoMotivo> createState() => _DialogoMotivoState();
}

class _DialogoMotivoState extends State<_DialogoMotivo> {
  final _campo = TextEditingController();

  @override
  void dispose() {
    _campo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Cancelar la visita'),
    content: TextField(
      controller: _campo,
      maxLength: 500,
      decoration: const InputDecoration(labelText: 'Motivo'),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Volver'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, _campo.text),
        child: const Text('Cancelar visita'),
      ),
    ],
  );
}

String _textoNoSePresento(String rol) => rol == 'tecnico'
    ? 'El cliente no se presentó'
    : 'El técnico no se presentó';
