import 'package:app/core/errores/failure.dart';
import 'package:app/features/visitas/domain/visita.dart';

/// Visitas ficticias en memoria. `falla` rompe toda llamada; `fallaAcciones`
/// solo las acciones (reprogramar, responder, cancelar, no se presentó), para
/// simular el 404 de ruta que hoy dan muchas del gateway.
class VisitasRepositoryDePrueba implements VisitasRepository {
  VisitasRepositoryDePrueba({
    List<Visita>? visitas,
    this.falla,
    this.fallaAcciones,
  }) : _visitas = [...visitas ?? _ficticias];

  final List<Visita> _visitas;
  final Failure? falla;
  final Failure? fallaAcciones;
  final List<String> acciones = [];

  void _revisar({bool accion = false}) {
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

  @override
  Future<PaginaAgenda> agenda({
    DateTime? desde,
    DateTime? hasta,
    String? cursor,
    int limite = 20,
  }) async {
    _revisar();
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
    _revisar();
    return _visitas[_indice(id)];
  }

  @override
  Future<PropuestaReprogramacion> reprogramar(
    String id, {
    required DateTime fechaHora,
  }) async {
    _revisar(accion: true);
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
    _revisar(accion: true);
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
    _revisar(accion: true);
    final i = _indice(id);
    validarMotivoCancelacion(motivo);
    acciones.add('cancelar:$id');
    final v = _visitas[i];
    _visitas[i] = Visita(
      id: v.id,
      rol: v.rol,
      estado: 'cancelada',
      modalidad: v.modalidad,
      dia: v.dia,
      hora: v.hora,
      precio: v.precio,
      tope: v.tope,
      tecnico: v.tecnico,
      coloniaCliente: v.coloniaCliente,
      lugar: v.lugar,
      puedeLlegar: false,
    );
    return ResultadoCancelacion(
      visitaId: id,
      estado: 'cancelada',
      tardia: false,
    );
  }

  @override
  Future<ResultadoAusencia> noSePresento(String id) async {
    _revisar(accion: true);
    final i = _indice(id);
    acciones.add('ausente:$id');
    return ResultadoAusencia(
      visitaId: id,
      estado: 'no_presentado',
      quienFalto: _visitas[i].rol == 'tecnico' ? 'cliente' : 'tecnico',
    );
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
];
