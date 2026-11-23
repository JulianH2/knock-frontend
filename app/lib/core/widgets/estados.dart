import 'package:app/core/errores/failure.dart';
import 'package:material_ui/material_ui.dart';

/// Indicador de carga centrado con su etiqueta de accesibilidad.
class CargandoCentrado extends StatelessWidget {
  const CargandoCentrado({required this.etiqueta, super.key});

  final String etiqueta;

  @override
  Widget build(BuildContext context) =>
      Center(child: CircularProgressIndicator(semanticsLabel: etiqueta));
}

/// Mensaje centrado, con una acción opcional (Reintentar u otra).
class MensajeCentrado extends StatelessWidget {
  const MensajeCentrado({
    required this.texto,
    this.etiquetaAccion,
    this.alPulsar,
    super.key,
  });

  final String texto;
  final String? etiquetaAccion;
  final VoidCallback? alPulsar;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(texto, textAlign: TextAlign.center),
          if (etiquetaAccion != null && alPulsar != null) ...[
            const SizedBox(height: 16),
            FilledButton(
              onPressed: alPulsar,
              style: FilledButton.styleFrom(minimumSize: const Size(64, 48)),
              child: Text(etiquetaAccion!),
            ),
          ],
        ],
      ),
    ),
  );
}

/// Texto para la persona según el error. Nunca muestra mensajes técnicos.
///
/// Los códigos de dominio propios de una pantalla se resuelven antes con
/// `porCodigo`; lo demás cae aquí.
String mensajeDeError(
  Object error, {
  required String porDefecto,
  Map<String, String> porCodigo = const {},
}) {
  switch (error) {
    case ReglaDeNegocioFailure(:final codigo) when porCodigo[codigo] != null:
      return porCodigo[codigo]!;
    case ServicioNoDisponibleFailure(:final codigo)
        when codigo != null && porCodigo[codigo] != null:
      return porCodigo[codigo]!;
    case LimiteDePeticionesFailure(:final codigo)
        when codigo != null && porCodigo[codigo] != null:
      return porCodigo[codigo]!;
    case RutaNoDisponibleFailure():
      return 'Esta función todavía no está disponible.';
    case ServicioNoDisponibleFailure():
      return 'El servicio no está disponible por ahora. Intenta más tarde.';
    case LimiteDePeticionesFailure():
      return 'Hiciste muchas peticiones. Espera un momento e intenta de nuevo.';
    case NoEncontradoFailure():
      return 'No encontramos lo que buscabas.';
    default:
      return porDefecto;
  }
}
