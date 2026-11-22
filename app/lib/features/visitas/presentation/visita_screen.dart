import 'package:app/core/widgets/estados.dart';
import 'package:app/features/visitas/domain/visita.dart';
import 'package:app/features/visitas/domain/visita_acciones.dart';
import 'package:app/features/visitas/presentation/agenda_screen.dart';
import 'package:app/features/visitas/presentation/dialogo_aviso.dart';
import 'package:app/features/visitas/presentation/dialogo_formulario.dart';
import 'package:app/features/visitas/presentation/mensajes_visita.dart';
import 'package:app/features/visitas/presentation/visitas_controller.dart';
import 'package:app/features/visitas/visitas_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Detalle de la visita (KNOCK-119/122). Muestra lo que ve cada rol (el
/// cliente su código y al técnico; el técnico la colonia y la dirección, sin
/// código) y solo ofrece las acciones que el estado y el rol permiten.
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
      cuerpo = RefreshIndicator(
        onRefresh: () async => controlador.reintentar(),
        child: _Detalle(visita: estado.requireValue, controlador: controlador),
      );
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

class _Detalle extends ConsumerWidget {
  const _Detalle({required this.visita, required this.controlador});

  final Visita visita;
  final VisitaController controlador;

  /// Abre el diálogo y, si terminó con éxito, avisa con un mensaje.
  Future<void> _abrir(BuildContext context, DialogoFormulario dialogo) async {
    final mensajero = ScaffoldMessenger.of(context);
    final mensaje = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => dialogo,
    );
    if (mensaje != null && mensaje.isNotEmpty) {
      mensajero.showSnackBar(SnackBar(content: Text(mensaje)));
    }
  }

  Future<void> _reprogramar(BuildContext context, WidgetRef ref) async {
    final ahora = ref.read(relojVisitasProvider)();
    final mensajero = ScaffoldMessenger.of(context);
    final dia = await showDatePicker(
      context: context,
      initialDate: ahora.add(const Duration(days: 1)),
      firstDate: DateTime(ahora.year, ahora.month, ahora.day),
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
    final errorFecha = errorFechaReprogramacion(elegida, ahora);
    if (errorFecha != null) {
      mensajero.showSnackBar(SnackBar(content: Text(errorFecha)));
      return;
    }
    final r = await controlador.reprogramar(elegida);
    mensajero.showSnackBar(
      SnackBar(
        content: Text(
          r.error != null ? mensajeDeErrorVisita(r.error!) : (r.mensaje ?? ''),
        ),
      ),
    );
  }

  /// Pregunta de dos respuestas (rechazar o aceptar) sin campos.
  Future<void> _siNo(
    BuildContext context, {
    required String titulo,
    required String mensaje,
    required (String, Future<ResultadoAccion> Function()) no,
    required (String, Future<ResultadoAccion> Function()) si,
  }) => _abrir(
    context,
    DialogoFormulario(
      titulo: titulo,
      mensaje: mensaje,
      opciones: [
        OpcionDialogo(
          etiqueta: no.$1,
          validar: false,
          principal: false,
          enviar: (_, _) => no.$2(),
        ),
        OpcionDialogo(
          etiqueta: si.$1,
          validar: false,
          enviar: (_, _) => si.$2(),
        ),
      ],
    ),
  );

  /// Formulario de un solo texto con su validación del contrato.
  Future<void> _conTexto(
    BuildContext context, {
    required String titulo,
    required String mensaje,
    required CampoFormulario campo,
    required String envio,
    required Future<ResultadoAccion> Function(String texto) enviar,
  }) => _abrir(
    context,
    DialogoFormulario(
      titulo: titulo,
      mensaje: mensaje,
      campos: [campo],
      opciones: [
        OpcionDialogo(
          etiqueta: envio,
          enviar: (v, _) => enviar(v[campo.clave]!),
        ),
      ],
    ),
  );

  Future<void> _noSePresento(BuildContext context) => _abrir(
    context,
    DialogoFormulario(
      titulo: 'El cliente no se presentó',
      mensaje:
          'Se registra en la visita, sin penalizar al cliente. '
          '¿Continuar?',
      opciones: [
        OpcionDialogo(
          etiqueta: 'Confirmar',
          validar: false,
          enviar: (_, _) => controlador.noSePresento(),
        ),
      ],
    ),
  );

  Future<void> _llegada(BuildContext context) => _abrir(
    context,
    DialogoFormulario(
      titulo: 'Confirmar llegada',
      mensaje: 'Pídele al cliente el código de 4 dígitos de la visita.',
      campos: const [
        CampoFormulario(
          clave: 'codigo',
          etiqueta: 'Código',
          maxLength: LimitesVisita.codigoDigitos,
          soloDigitos: true,
          validar: errorCodigoLlegada,
        ),
      ],
      opciones: [
        OpcionDialogo(
          etiqueta: 'Confirmar llegada',
          enviar: (v, _) => controlador.llegada(v['codigo']!),
        ),
      ],
    ),
  );

  Future<void> _terminar(BuildContext context) => _abrir(
    context,
    DialogoFormulario(
      titulo: 'Terminar la visita',
      mensaje:
          'El cliente no tiene que confirmar. Cuenta qué hiciste y '
          'agrega de 1 a 5 fotos.',
      conFotos: true,
      campos: const [
        CampoFormulario(
          clave: 'descripcion',
          etiqueta: 'Qué hiciste',
          maxLength: LimitesVisita.descripcionMax,
          lineas: 3,
          validar: errorDescripcionTrabajo,
        ),
        CampoFormulario(
          clave: 'recomendacion',
          etiqueta: 'Recomendación (opcional)',
          maxLength: LimitesVisita.recomendacionMax,
          lineas: 2,
          validar: errorRecomendacion,
        ),
      ],
      opciones: [
        OpcionDialogo(
          etiqueta: 'Terminar visita',
          enviar: (v, fotos) => controlador.terminar(
            descripcion: v['descripcion']!,
            recomendacion: v['recomendacion']!,
            fotos: fotos,
          ),
        ),
      ],
    ),
  );

  Future<void> _cotizacionFinal(BuildContext context) => _abrir(
    context,
    DialogoFormulario(
      titulo: 'Cotización final',
      mensaje: 'Solo puedes enviar una por visita y el cliente decide.',
      campos: const [
        CampoFormulario(
          clave: 'precio',
          etiqueta: 'Precio en pesos',
          soloDigitos: true,
          maxLength: 9,
          validar: errorPrecio,
        ),
        CampoFormulario(
          clave: 'descripcion',
          etiqueta: 'Qué incluye',
          maxLength: LimitesVisita.descripcionMax,
          lineas: 3,
          validar: errorDescripcionTrabajo,
        ),
      ],
      opciones: [
        OpcionDialogo(
          etiqueta: 'Enviar cotización',
          enviar: (v, _) => controlador.enviarCotizacionFinal(
            precio: v['precio']!,
            descripcion: v['descripcion']!,
          ),
        ),
      ],
    ),
  );

  Future<void> _aviso(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => DialogoAviso(pedir: controlador.pedirAviso),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final acciones = AccionesVisita(visita);
    final esTecnico = visita.rol == 'tecnico';
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
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
        if (!esTecnico && visita.tecnico != null) ...[
          Text(
            'Técnico: ${visita.tecnico!.nombre}'
            '${visita.tecnico!.verificado ? ' (verificado)' : ''}',
          ),
          if (visita.tecnico!.telefono != null)
            Text('Teléfono: ${visita.tecnico!.telefono}'),
        ],
        if (visita.coloniaCliente != null)
          Text('Colonia: ${visita.coloniaCliente}'),
        if (visita.lugar.direccion != null)
          Text('Lugar: ${visita.lugar.direccion}'),
        if (!esTecnico) _Codigo(visita: visita),
        if (esTecnico && visita.llegadaEn != null)
          Text('Llegaste a las ${horaDeLlegada(visita.llegadaEn!)}'),
        if (visita.reglaSeguridad != null) ...[
          const SizedBox(height: 8),
          Text(visita.reglaSeguridad!),
        ],
        const SizedBox(height: 16),
        if (!acciones.alguna)
          const Text(
            'Por ahora no hay acciones disponibles para esta visita.',
            key: ValueKey('sin-acciones'),
          ),
        if (acciones.llegada)
          _Boton(
            principal: true,
            icono: Icons.where_to_vote_outlined,
            texto: 'Confirmar llegada',
            alPulsar: () => _llegada(context),
          ),
        if (acciones.terminar)
          _Boton(
            principal: true,
            icono: Icons.task_alt_outlined,
            texto: 'Terminar visita',
            alPulsar: () => _terminar(context),
          ),
        if (acciones.cotizacionFinal)
          _Boton(
            texto: 'Enviar cotización final',
            alPulsar: () => _cotizacionFinal(context),
          ),
        if (acciones.decidirCotizacion)
          _Boton(
            principal: true,
            texto: 'Responder a la cotización final',
            alPulsar: () => _siNo(
              context,
              titulo: 'Cotización final',
              mensaje:
                  '¿Apruebas la cotización final del técnico? La decisión es '
                  'definitiva.',
              no: (
                'Rechazar',
                () => controlador.decidirCotizacion(aprueba: false),
              ),
              si: (
                'Aprobar',
                () => controlador.decidirCotizacion(aprueba: true),
              ),
            ),
          ),
        if (acciones.permisoFotos)
          _Boton(
            texto: 'Permiso para publicar las fotos',
            alPulsar: () => _siNo(
              context,
              titulo: 'Fotos del trabajo',
              mensaje: '¿Autorizas que se publiquen las fotos del trabajo?',
              no: (
                'No autorizar',
                () => controlador.permisoFotos(permiso: false),
              ),
              si: ('Autorizar', () => controlador.permisoFotos(permiso: true)),
            ),
          ),
        if (acciones.noTerminado)
          _Boton(
            texto: 'Reportar que no se terminó',
            alPulsar: () => _conTexto(
              context,
              titulo: 'Reportar que no se terminó',
              mensaje:
                  'Puedes reportarlo una sola vez, hasta '
                  '${LimitesVisita.diasParaNoTerminado} días después de la visita.',
              campo: const CampoFormulario(
                clave: 'texto',
                etiqueta: 'Qué faltó',
                maxLength: LimitesVisita.noTerminadoMax,
                lineas: 3,
                validar: errorTextoNoTerminado,
              ),
              envio: 'Enviar reporte',
              enviar: controlador.noTerminado,
            ),
          ),
        if (acciones.aviso)
          _Boton(
            icono: Icons.shield_outlined,
            texto: 'Avisar a alguien de confianza',
            alPulsar: () => _aviso(context),
          ),
        if (acciones.reprogramar)
          _Boton(
            principal: !acciones.llegada,
            icono: Icons.edit_calendar_outlined,
            texto: 'Reprogramar',
            alPulsar: () => _reprogramar(context, ref),
          ),
        if (acciones.responderReprogramacion)
          _Boton(
            texto: 'Responder a un nuevo horario',
            alPulsar: () => _siNo(
              context,
              titulo: 'Nuevo horario propuesto',
              mensaje: '¿Aceptas el nuevo horario de la visita?',
              no: ('Rechazar', () => controlador.responder(acepta: false)),
              si: ('Aceptar', () => controlador.responder(acepta: true)),
            ),
          ),
        if (acciones.clienteAusente)
          _Boton(
            texto: 'El cliente no se presentó',
            alPulsar: () => _noSePresento(context),
          ),
        if (acciones.cancelar)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton(
              onPressed: () => _conTexto(
                context,
                titulo: 'Cancelar la visita',
                mensaje:
                    'Con menos de 24 horas de anticipación cuenta como '
                    'cancelación tardía.',
                campo: const CampoFormulario(
                  clave: 'motivo',
                  etiqueta: 'Motivo',
                  maxLength: LimitesVisita.motivoCancelarMax,
                  lineas: 3,
                  validar: errorMotivoCancelacion,
                ),
                envio: 'Cancelar visita',
                enviar: controlador.cancelar,
              ),
              child: const Text('Cancelar visita'),
            ),
          ),
      ],
    );
  }
}

/// Hora de llegada para mostrar («14:05»).
String horaDeLlegada(DateTime fecha) {
  final l = fecha.toLocal();
  return '${l.hour.toString().padLeft(2, '0')}:'
      '${l.minute.toString().padLeft(2, '0')}';
}

class _Boton extends StatelessWidget {
  const _Boton({
    required this.texto,
    required this.alPulsar,
    this.principal = false,
    this.icono,
  });

  final String texto;
  final VoidCallback alPulsar;
  final bool principal;
  final IconData? icono;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: principal
        ? (icono == null
              ? FilledButton(onPressed: alPulsar, child: Text(texto))
              : FilledButton.icon(
                  onPressed: alPulsar,
                  icon: Icon(icono),
                  label: Text(texto),
                ))
        : (icono == null
              ? OutlinedButton(onPressed: alPulsar, child: Text(texto))
              : OutlinedButton.icon(
                  onPressed: alPulsar,
                  icon: Icon(icono),
                  label: Text(texto),
                )),
  );
}

/// Código de la visita para el cliente; sin código, dice por qué.
class _Codigo extends StatelessWidget {
  const _Codigo({required this.visita});

  final Visita visita;

  @override
  Widget build(BuildContext context) {
    if (visita.codigo != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          'Código de la visita: ${visita.codigo}\n'
          'Dáselo al técnico cuando llegue; no lo compartas por mensaje.',
        ),
      );
    }
    final motivo = switch (visita.motivoCodigo) {
      'usado' => 'El código ya se usó.',
      'vencido' => 'El código venció.',
      'bloqueada' => 'La visita está bloqueada por intentos del código.',
      _ => null,
    };
    return motivo == null ? const SizedBox.shrink() : Text(motivo);
  }
}
