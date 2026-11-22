import 'package:app/core/errores/failure.dart';
import 'package:app/features/visitas/domain/visita.dart';

/// Texto de confianza de `POST /visitas/{id}/aviso`. No envía nada: la
/// persona lo copia y lo comparte. Nunca incluye el código ni la dirección.
class AvisoConfianza {
  const AvisoConfianza({
    required this.texto,
    required this.incluyeCodigo,
    required this.incluyeDireccion,
  });

  final String texto;
  final bool incluyeCodigo;
  final bool incluyeDireccion;
}

/// Respuesta de `POST /visitas/{id}/terminar`.
class ResultadoTermino {
  const ResultadoTermino({
    required this.visitaId,
    required this.estado,
    required this.terminadaEn,
  });

  final String visitaId;
  final String estado;
  final DateTime terminadaEn;
}

/// Respuesta (201) de `POST /visitas/{id}/no-terminado`.
class ResultadoNoTerminado {
  const ResultadoNoTerminado({required this.visitaId, required this.estado});

  final String visitaId;
  final String estado;
}

/// Respuesta (201) de `POST /visitas/{id}/cotizacion-final`.
class CotizacionFinal {
  const CotizacionFinal({
    required this.visitaId,
    required this.precio,
    required this.estado,
    required this.venceEn,
  });

  final String visitaId;
  final int precio;
  final String estado;
  final DateTime venceEn;
}

/// Respuesta de `POST /visitas/{id}/cotizacion-final/decision`; `resultado`
/// solo llega al rechazar (`solo_visita`).
class DecisionCotizacion {
  const DecisionCotizacion({
    required this.visitaId,
    required this.estado,
    this.resultado,
  });

  final String visitaId;
  final String estado;
  final String? resultado;
}

/// Respuesta de `PUT /visitas/{id}/permiso-fotos`.
class PermisoFotos {
  const PermisoFotos({required this.visitaId, required this.permiso});

  final String visitaId;
  final bool permiso;
}

/// Franja `HH:mm` (24 h, hora de la ciudad) con inicio anterior al fin.
class FranjaHorario {
  const FranjaHorario({required this.inicio, required this.fin});

  final String inicio;
  final String fin;

  @override
  bool operator ==(Object other) =>
      other is FranjaHorario && other.inicio == inicio && other.fin == fin;

  @override
  int get hashCode => Object.hash(inicio, fin);
}

/// Horario de un día (`DayScheduleDto`): abierto con una o dos franjas, o
/// cerrado sin franjas.
class HorarioDia {
  const HorarioDia({
    required this.dia,
    required this.abierto,
    this.franjas = const [],
  });

  final String dia;
  final bool abierto;
  final List<FranjaHorario> franjas;

  HorarioDia copiar({bool? abierto, List<FranjaHorario>? franjas}) =>
      HorarioDia(
        dia: dia,
        abierto: abierto ?? this.abierto,
        franjas: franjas ?? this.franjas,
      );
}

/// Los siete días, en el orden que exige el contrato.
const diasDeLaSemana = [
  'lunes',
  'martes',
  'miercoles',
  'jueves',
  'viernes',
  'sabado',
  'domingo',
];

/// Horario cerrado de los siete días (lo que da la API sin horario guardado).
List<HorarioDia> horarioCerrado() => [
  for (final d in diasDeLaSemana) HorarioDia(dia: d, abierto: false),
];

/// Cotas de texto. Solo el motivo de cancelar (8–300) y el de no terminado
/// (8–500) vienen del contrato; las demás son cotas prudentes de la app.
abstract final class LimitesVisita {
  static const motivoCancelarMin = 8;
  static const motivoCancelarMax = 300;
  static const noTerminadoMin = 8;
  static const noTerminadoMax = 500;
  static const descripcionMax = 1000;
  static const recomendacionMax = 1000;
  static const fotosMin = 1;
  static const fotosMax = 5;
  static const codigoDigitos = 4;
  static const diasParaNoTerminado = 7;
  static const diasMaximosAgenda = 31;
}

/// Error de un texto con longitud acotada, o `null` si es válido. Se mide el
/// texto sin espacios en los extremos.
String? errorDeTexto(
  String valor, {
  required int min,
  required int max,
  required String vacio,
}) {
  final limpio = valor.trim();
  if (limpio.isEmpty) {
    return vacio;
  }
  if (limpio.length < min) {
    return 'Escribe al menos $min caracteres.';
  }
  if (limpio.length > max) {
    return 'Escribe como máximo $max caracteres.';
  }
  return null;
}

String? errorMotivoCancelacion(String valor) => errorDeTexto(
  valor,
  min: LimitesVisita.motivoCancelarMin,
  max: LimitesVisita.motivoCancelarMax,
  vacio: 'Escribe el motivo de la cancelación.',
);

String? errorTextoNoTerminado(String valor) => errorDeTexto(
  valor,
  min: LimitesVisita.noTerminadoMin,
  max: LimitesVisita.noTerminadoMax,
  vacio: 'Cuéntanos qué faltó por terminar.',
);

String? errorDescripcionTrabajo(String valor) => errorDeTexto(
  valor,
  min: 1,
  max: LimitesVisita.descripcionMax,
  vacio: 'Describe el trabajo que hiciste.',
);

String? errorRecomendacion(String valor) =>
    valor.trim().length > LimitesVisita.recomendacionMax
    ? 'Escribe como máximo ${LimitesVisita.recomendacionMax} caracteres.'
    : null;

/// Código de llegada: exactamente cuatro dígitos ASCII (con ceros a la
/// izquierda).
String? errorCodigoLlegada(String valor) =>
    RegExp(r'^[0-9]{4}$').hasMatch(valor.trim())
    ? null
    : 'El código tiene 4 dígitos.';

/// Precio entero en pesos, mayor que cero y dentro de `int32`.
String? errorPrecio(String valor) {
  final limpio = valor.trim();
  if (limpio.isEmpty) {
    return 'Escribe el precio.';
  }
  final n = int.tryParse(limpio);
  if (n == null || !RegExp(r'^[0-9]+$').hasMatch(limpio)) {
    return 'Escribe un precio entero, sin centavos.';
  }
  if (n <= 0 || n > 2147483647) {
    return 'El precio debe ser mayor que cero.';
  }
  return null;
}

String? errorFotos(int cantidad) =>
    cantidad < LimitesVisita.fotosMin || cantidad > LimitesVisita.fotosMax
    ? 'Agrega de ${LimitesVisita.fotosMin} a ${LimitesVisita.fotosMax} fotos.'
    : null;

/// La nueva fecha de una reprogramación debe ser posterior a `ahora`.
String? errorFechaReprogramacion(DateTime fecha, DateTime ahora) =>
    fecha.isAfter(ahora) ? null : 'Elige una fecha y hora futuras.';

/// Rango de la agenda: `hasta` no antes de `desde` y a lo más 31 días de
/// diferencia (el contrato no aclara si cuenta ambos extremos; se usa la
/// lectura estricta).
String? errorRangoAgenda(DateTime desde, DateTime hasta) {
  final dias = DateTime.utc(
    hasta.year,
    hasta.month,
    hasta.day,
  ).difference(DateTime.utc(desde.year, desde.month, desde.day)).inDays;
  if (dias < 0) {
    return 'La fecha final no puede ser anterior a la inicial.';
  }
  if (dias > LimitesVisita.diasMaximosAgenda) {
    return 'El rango puede ser de ${LimitesVisita.diasMaximosAgenda} días '
        'como máximo.';
  }
  return null;
}

final _hora = RegExp(r'^([01][0-9]|2[0-3]):[0-5][0-9]$');

/// Minutos desde medianoche de una hora `HH:mm`, o `null` si no es válida.
int? minutosDeHora(String hhmm) {
  if (!_hora.hasMatch(hhmm)) {
    return null;
  }
  return int.parse(hhmm.substring(0, 2)) * 60 + int.parse(hhmm.substring(3));
}

/// Nombre del día para mostrar (con acentos).
String nombreDeDia(String dia) => switch (dia) {
  'miercoles' => 'Miércoles',
  'sabado' => 'Sábado',
  _ => '${dia[0].toUpperCase()}${dia.substring(1)}',
};

/// Error del horario de un día, o `null`. Abierto: una o dos franjas `HH:mm`,
/// cada una con inicio anterior al fin y sin traslapes (la segunda empieza
/// cuando acaba la primera o después). Cerrado: sin franjas.
String? errorHorarioDia(HorarioDia d) {
  if (!d.abierto) {
    return d.franjas.isEmpty ? null : 'Un día cerrado no lleva franjas.';
  }
  if (d.franjas.isEmpty || d.franjas.length > 2) {
    return 'Un día abierto lleva una o dos franjas.';
  }
  var anterior = -1;
  for (final f in d.franjas) {
    final inicio = minutosDeHora(f.inicio);
    final fin = minutosDeHora(f.fin);
    if (inicio == null || fin == null) {
      return 'Usa horas válidas (HH:mm).';
    }
    if (inicio >= fin) {
      return 'La hora de inicio debe ser anterior a la de fin.';
    }
    if (inicio < anterior) {
      return 'Las franjas no pueden traslaparse.';
    }
    anterior = fin;
  }
  return null;
}

/// Error global de los siete días (cada uno una vez, en orden), o `null`.
/// Una lista que no son los siete días es un dato inválido, no un error de
/// captura.
String? errorHorarios(List<HorarioDia> horarios) {
  if (horarios.length != diasDeLaSemana.length) {
    throw const DatosInvalidosFailure();
  }
  for (var i = 0; i < horarios.length; i++) {
    if (horarios[i].dia != diasDeLaSemana[i]) {
      throw const DatosInvalidosFailure();
    }
    final e = errorHorarioDia(horarios[i]);
    if (e != null) {
      return '${nombreDeDia(horarios[i].dia)}: $e';
    }
  }
  return null;
}

/// Qué acciones permite la visita según su rol y estado. Es solo ayuda de
/// interfaz: la autorización real es del servidor, que responde 403/409.
///
/// Los estados vienen del contrato (`confirmada`, `en_curso`, `cancelada`,
/// `no_presentado`) y de la agenda (`propuesta`, `terminada`).
class AccionesVisita {
  AccionesVisita(this.visita);

  final Visita visita;

  bool get _cliente => visita.rol == 'cliente';
  bool get _tecnico => visita.rol == 'tecnico';
  String get _e => visita.estado;

  bool get reprogramar => _e == 'confirmada';
  bool get responderReprogramacion => _e == 'confirmada';
  bool get cancelar => _e == 'propuesta' || _e == 'confirmada';

  /// «El cliente no se presentó»: solo el técnico (VIS-07).
  bool get clienteAusente => _tecnico && _e == 'confirmada';

  /// El servidor decide si ya se puede llegar con `puedeLlegar`.
  bool get llegada => _tecnico && visita.puedeLlegar;
  bool get aviso =>
      _cliente &&
      visita.puedeAvisar == true &&
      (_e == 'confirmada' || _e == 'en_curso');
  bool get terminar => _tecnico && _e == 'en_curso';
  bool get cotizacionFinal => _tecnico && _e == 'en_curso';
  bool get decidirCotizacion => _cliente && _e == 'en_curso';
  bool get noTerminado => _cliente && _e == 'terminada';
  bool get permisoFotos => _cliente && _e == 'terminada';

  /// Si hay alguna acción disponible; si no, el detalle lo dice.
  bool get alguna =>
      reprogramar ||
      cancelar ||
      clienteAusente ||
      llegada ||
      aviso ||
      terminar ||
      cotizacionFinal ||
      decidirCotizacion ||
      noTerminado ||
      permisoFotos;
}
