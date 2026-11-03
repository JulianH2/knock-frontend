import 'dart:convert';

import 'package:app/core/errores/failure.dart';
import 'package:app/core/red/cliente_api.dart';
import 'package:app/features/oficios/data/oficio_mapper.dart';
import 'package:app/features/oficios/domain/oficio.dart';
import 'package:app/features/oficios/domain/oficios_repository.dart';

/// Oficios desde la API (`GET /api/v1/oficios`, §4 de TT-PRU-01) por medio de
/// `clienteApiProvider`: hoy la API simulada y, con TT-MOB-03, la real.
///
/// Traduce la respuesta a entidades con [OficioMapper] y los errores a
/// `Failure` (spec §8 D7); nunca deja salir una excepción cruda ni un `null`.
class OficiosRepositoryApi implements OficiosRepository {
  const OficiosRepositoryApi(this._cliente);

  static const ruta = '/api/v1/oficios';

  final ClienteApi _cliente;

  @override
  Future<List<Oficio>> listar() async {
    final RespuestaApi respuesta;
    try {
      respuesta = await _cliente.enviar(
        const PeticionApi(metodo: 'GET', ruta: ruta),
      );
    } on ErrorDeRedApi {
      throw const ServicioNoDisponibleFailure();
    }
    final estado = respuesta.estado;
    if (estado >= 400 && estado < 500) {
      throw SolicitudRechazadaFailure(estado);
    }
    if (estado != 200) {
      throw const ServicioNoDisponibleFailure();
    }
    if (respuesta.tipoDeContenido != 'application/json') {
      throw const DatosInvalidosFailure();
    }
    final Object? json;
    try {
      json = jsonDecode(respuesta.cuerpo);
    } on FormatException {
      throw const DatosInvalidosFailure();
    }
    return OficioMapper.listaDesdeContrato(json);
  }
}
