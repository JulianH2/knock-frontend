import 'package:app/core/errores/failure.dart';
import 'package:app/features/visitas/domain/visita.dart';
import 'package:app/features/visitas/domain/visita_acciones.dart';

/// Visitas ficticias en memoria. `falla` rompe toda llamada; `fallaAcciones`
/// solo las acciones (todo menos leer la agenda y el detalle), para simular el
/// 404 de ruta que hoy dan muchas del gateway. Imita las reglas del contrato
/// que la interfaz necesita ver (código de llegada, una sola cotización,
/// un solo reporte de no terminado) con códigos de dominio ficticios.
class VisitasRepositoryDePrueba implements VisitasRepository {
  VisitasRepositoryDePrueba({
    List<Visita>? visitas,
    List<HorarioDia>? horarios,
    this.falla,
    this.fallaAcciones,
    this.fallaHorarios,
    this.retraso = Duration.zero,
    this.codigoLlegada = '1234',
  }) : _visitas = [...visitas ?? _ficticias],
       _horarios = [...horarios ?? horarioCerrado()];

  final List<Visita> _visitas;
  List<HorarioDia> _horarios;
  final Failure? falla;
  final Failure? fallaAcciones;

  /// Falla solo las llamadas de horarios (sus rutas no existen en el gateway).
  final Failure? fallaHorarios;

  /// Espera antes de responder una acción (para probar el doble envío).
  final Duration retraso;
  final String codigoLlegada;

  /// Bitácora de acciones, para las pruebas.
  final List<String> acciones = [];
  final Map<String, int> _intentos = {};
  final Set<String> _conCotizacion = {};
  final Set<String> _conReporte = {};

  /// Último rango pedido a la agenda.
  /// Veces que se pidió la agenda.
  int llamadasAgenda = 0;

  DateTime? ultimoDesde;
  DateTime? ultimoHasta;

  Future<void> _revisar({bool accion = false}) async {
    if (accion && retraso > Duration.zero) {
      await Future<void>.delayed(retraso);
    }
    final error = falla ?? (accion ? fallaAcciones : null);
    if (error != null) {
      throw error;
    }
  }

  int _indice(String id) {
    final i = _visitas.indexWhere((v) => v.id == id);
    if (i < 0) {
      throw const NoEncontradoFailure();
    }
    return i;
  }

  void _cambiar(
    int i, {
    String? estado,
    bool? puedeLlegar,
    DateTime? llegadaEn,
  }) {
    final v = _visitas[i];
    _visitas[i] = Visita(
      id: v.id,
      rol: v.rol,
      estado: estado ?? v.estado,
      modalidad: v.modalidad,
      dia: v.dia,
      hora: v.hora,
      precio: v.precio,
      tope: v.tope,
      tecnico: v.tecnico,
      coloniaCliente: v.coloniaCliente,
      lugar: v.lugar,
      codigo: v.codigo,
      codigoVenceEn: v.codigoVenceEn,
      motivoCodigo: v.motivoCodigo,
      reglaSeguridad: v.reglaSeguridad,
      puedeAvisar: v.puedeAvisar,
      puedeLlegar: puedeLlegar ?? v.puedeLlegar,
      llegadaEn: llegadaEn ?? v.llegadaEn,
    );
  }

  void _exigirEstado(int i, String estado, String codigo) {
    if (_visitas[i].estado != estado) {
      throw ReglaDeNegocioFailure(codigo);
    }
  }

  @override
  Future<PaginaAgenda> agenda({
    DateTime? desde,
    DateTime? hasta,
    String? cursor,
    int limite = 20,
  }) async {
    await _revisar();
    llamadasAgenda++;
    ultimoDesde = desde;
    ultimoHasta = hasta;
    final inicio = (int.tryParse(cursor ?? '0') ?? 0).clamp(0, _visitas.length);
    final fin = (inicio + limite).clamp(0, _visitas.length);
    return PaginaAgenda(
      items: [
        for (final v in _visitas.sublist(inicio, fin))
          AgendaItem(
            id: v.id,
            estado: v.estado,
            modalidad: v.modalidad,
            fechaHora: DateTime.utc(2026, 11, 25, 16),
            dia: v.dia,
            hora: v.hora,
            precio: v.precio,
          ),
      ],
      nextCursor: fin < _visitas.length ? '$fin' : null,
    );
  }

  @override
  Future<Visita> obtener(String id) async {
    await _revisar();
    return _visitas[_indice(id)];
  }

  @override
  Future<PropuestaReprogramacion> reprogramar(
    String id, {
    required DateTime fechaHora,
  }) async {
    await _revisar(accion: true);
    _indice(id);
    acciones.add('reprogramar:$id');
    return PropuestaReprogramacion(
      visitaId: id,
      fechaHora: fechaHora.toUtc(),
      propuestaPor: _visitas[_indice(id)].rol,
      venceEn: fechaHora.toUtc().subtract(const Duration(hours: 2)),
    );
  }

  @override
  Future<RespuestaReprogramacion> responderReprogramacion(
    String id, {
    required bool acepta,
  }) async {
    await _revisar(accion: true);
    _indice(id);
    acciones.add('respuesta:$id:$acepta');
    return RespuestaReprogramacion(
      visitaId: id,
      aceptada: acepta,
      fechaHora: DateTime.utc(2026, 11, 26, 16),
      reprogramaciones: 1,
    );
  }

  @override
  Future<ResultadoCancelacion> cancelar(
    String id, {
    required String motivo,
  }) async {
    await _revisar(accion: true);
    final i = _indice(id);
    validarMotivoCancelacion(motivo);
    acciones.add('cancelar:$id');
    _cambiar(i, estado: 'cancelada', puedeLlegar: false);
    return ResultadoCancelacion(
      visitaId: id,
      estado: 'cancelada',
      tardia: false,
    );
  }

  @override
  Future<ResultadoAusencia> noSePresento(String id) async {
    await _revisar(accion: true);
    final i = _indice(id);
    acciones.add('ausente:$id');
    return ResultadoAusencia(
      visitaId: id,
      estado: 'no_presentado',
      quienFalto: _visitas[i].rol == 'tecnico' ? 'cliente' : 'tecnico',
    );
  }

  @override
  Future<Visita> llegada(String id, {required String codigo}) async {
    await _revisar(accion: true);
    final i = _indice(id);
    if (errorCodigoLlegada(codigo) != null) {
      throw const DatosInvalidosFailure();
    }
    if (!_visitas[i].puedeLlegar) {
      throw const ReglaDeNegocioFailure('outside_window');
    }
    final intentos = _intentos[id] ?? 0;
    if (intentos >= 3) {
      throw const ReglaDeNegocioFailure('visit_locked');
    }
    if (codigo != codigoLlegada) {
      _intentos[id] = intentos + 1;
      throw ReglaDeNegocioFailure(
        _intentos[id]! >= 3 ? 'visit_locked' : 'wrong_code',
      );
    }
    acciones.add('llegada:$id');
    _cambiar(
      i,
      estado: 'en_curso',
      puedeLlegar: false,
      llegadaEn: DateTime.utc(2026, 11, 25, 16),
    );
    return _visitas[i];
  }

  @override
  Future<AvisoConfianza> avisoConfianza(String id) async {
    await _revisar(accion: true);
    final i = _indice(id);
    if (_visitas[i].estado != 'confirmada' &&
        _visitas[i].estado != 'en_curso') {
      throw const ReglaDeNegocioFailure('visit_not_active');
    }
    acciones.add('aviso:$id');
    return const AvisoConfianza(
      texto:
          'Hoy un técnico de Knock irá a mi casa. Si no sabes de mí, '
          'escríbeme.',
      incluyeCodigo: false,
      incluyeDireccion: false,
    );
  }

  @override
  Future<ResultadoTermino> terminar(
    String id, {
    required String descripcion,
    required String recomendacion,
    required List<String> fotos,
  }) async {
    await _revisar(accion: true);
    final i = _indice(id);
    if (errorDescripcionTrabajo(descripcion) != null ||
        errorRecomendacion(recomendacion) != null ||
        errorFotos(fotos.length) != null) {
      throw const DatosInvalidosFailure();
    }
    _exigirEstado(i, 'en_curso', 'visit_not_active');
    acciones.add('terminar:$id:${fotos.length}');
    _cambiar(i, estado: 'terminada');
    return ResultadoTermino(
      visitaId: id,
      estado: 'terminada',
      terminadaEn: DateTime.utc(2026, 11, 25, 18),
    );
  }

  @override
  Future<ResultadoNoTerminado> noTerminado(
    String id, {
    required String texto,
  }) async {
    await _revisar(accion: true);
    final i = _indice(id);
    if (errorTextoNoTerminado(texto) != null) {
      throw const DatosInvalidosFailure();
    }
    _exigirEstado(i, 'terminada', 'visit_not_finished');
    if (!_conReporte.add(id)) {
      throw const ReglaDeNegocioFailure('already_reported');
    }
    acciones.add('no_terminado:$id');
    return ResultadoNoTerminado(visitaId: id, estado: 'en_revision');
  }

  @override
  Future<CotizacionFinal> enviarCotizacionFinal(
    String id, {
    required int precio,
    required String descripcion,
  }) async {
    await _revisar(accion: true);
    final i = _indice(id);
    if (errorPrecio('$precio') != null ||
        errorDescripcionTrabajo(descripcion) != null) {
      throw const DatosInvalidosFailure();
    }
    _exigirEstado(i, 'en_curso', 'visit_not_active');
    if (!_conCotizacion.add(id)) {
      throw const ReglaDeNegocioFailure('final_quote_exists');
    }
    acciones.add('cotizacion:$id:$precio');
    return CotizacionFinal(
      visitaId: id,
      precio: precio,
      estado: 'pendiente',
      venceEn: DateTime.utc(2026, 11, 26, 18),
    );
  }

  @override
  Future<DecisionCotizacion> decidirCotizacionFinal(
    String id, {
    required bool aprueba,
  }) async {
    await _revisar(accion: true);
    _indice(id);
    if (!_conCotizacion.contains(id)) {
      throw const ReglaDeNegocioFailure('final_quote_missing');
    }
    acciones.add('decision:$id:$aprueba');
    return DecisionCotizacion(
      visitaId: id,
      estado: aprueba ? 'aprobada' : 'rechazada',
      resultado: aprueba ? null : 'solo_visita',
    );
  }

  @override
  Future<PermisoFotos> permisoFotos(String id, {required bool permiso}) async {
    await _revisar(accion: true);
    final i = _indice(id);
    _exigirEstado(i, 'terminada', 'visit_not_finished');
    acciones.add('permiso:$id:$permiso');
    return PermisoFotos(visitaId: id, permiso: permiso);
  }

  @override
  Future<List<HorarioDia>> horarios() async {
    final error = fallaHorarios ?? falla;
    if (error != null) {
      throw error;
    }
    return [..._horarios];
  }

  @override
  Future<List<HorarioDia>> guardarHorarios(List<HorarioDia> horarios) async {
    final error = fallaHorarios ?? falla ?? fallaAcciones;
    if (error != null) {
      throw error;
    }
    if (errorHorarios(horarios) != null) {
      throw const DatosInvalidosFailure();
    }
    acciones.add('horarios');
    _horarios = [...horarios];
    return [..._horarios];
  }
}

final _ficticias = [
  const Visita(
    id: 'v1',
    rol: 'cliente',
    estado: 'confirmada',
    modalidad: 'domicilio',
    dia: 'Miércoles 25 de noviembre',
    hora: '10:00',
    precio: 350,
    tope: 500,
    tecnico: VisitaTecnico(
      nombre: 'Luis Prueba',
      verificado: true,
      nivelVerificacion: 'basico',
    ),
    coloniaCliente: 'Colonia Ficticia',
    lugar: VisitaLugar(tipo: 'domicilio_cliente'),
    puedeAvisar: true,
    codigo: '1234',
    puedeLlegar: false,
  ),
  const Visita(
    id: 'v2',
    rol: 'cliente',
    estado: 'propuesta',
    modalidad: 'taller',
    dia: 'Jueves 26 de noviembre',
    hora: '12:30',
    tope: 800,
    lugar: VisitaLugar(tipo: 'taller', direccion: 'Calle Ficticia 123'),
    puedeLlegar: false,
  ),
  const Visita(
    id: 't1',
    rol: 'tecnico',
    estado: 'confirmada',
    modalidad: 'domicilio',
    dia: 'Viernes 27 de noviembre',
    hora: '09:00',
    precio: 400,
    tope: 600,
    coloniaCliente: 'Colonia Ficticia',
    lugar: VisitaLugar(tipo: 'domicilio_cliente', direccion: 'Calle Falsa 1'),
    puedeLlegar: true,
  ),
  const Visita(
    id: 't2',
    rol: 'tecnico',
    estado: 'en_curso',
    modalidad: 'domicilio',
    dia: 'Sábado 28 de noviembre',
    hora: '11:00',
    tope: 600,
    coloniaCliente: 'Colonia Ficticia',
    lugar: VisitaLugar(tipo: 'domicilio_cliente', direccion: 'Calle Falsa 2'),
    puedeLlegar: false,
    llegadaEn: null,
  ),
  const Visita(
    id: 'c1',
    rol: 'cliente',
    estado: 'en_curso',
    modalidad: 'domicilio',
    dia: 'Domingo 29 de noviembre',
    hora: '13:00',
    tope: 600,
    tecnico: VisitaTecnico(
      nombre: 'Ana Prueba',
      verificado: false,
      nivelVerificacion: 'ninguno',
    ),
    lugar: VisitaLugar(tipo: 'domicilio_cliente'),
    puedeAvisar: true,
    puedeLlegar: false,
  ),
  const Visita(
    id: 'c2',
    rol: 'cliente',
    estado: 'terminada',
    modalidad: 'taller',
    dia: 'Lunes 30 de noviembre',
    hora: '15:00',
    tope: 600,
    lugar: VisitaLugar(tipo: 'taller', direccion: 'Calle Ficticia 9'),
    puedeLlegar: false,
  ),
];
