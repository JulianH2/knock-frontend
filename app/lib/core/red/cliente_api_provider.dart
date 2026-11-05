import 'package:app/core/errores/failure.dart';
import 'package:app/core/red/configuracion_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:knock_api/api.dart';

/// URL base cruda de la API. Las pruebas la reemplazan con `overrideWithValue`.
final urlApiProvider = Provider<String>((ref) => urlApiDefinida);

/// Transporte HTTP del cliente generado. Las pruebas lo reemplazan por un
/// cliente que apunta a un servidor simulado.
final transporteHttpProvider = Provider<http.Client>((ref) {
  final cliente = http.Client();
  ref.onDispose(cliente.close);
  return cliente;
});

/// Cliente generado de la API (spec 006). Es la única puerta de la app hacia
/// HTTP: nadie arma peticiones a mano. Lanza [ApiNoConfiguradaFailure] al
/// leerse si la URL base falta o no es válida.
final clienteApiProvider = Provider<ApiClient>((ref) {
  final url = normalizarUrlApi(ref.watch(urlApiProvider));
  if (url == null) throw const ApiNoConfiguradaFailure();
  return ApiClient(basePath: url)..client = ref.watch(transporteHttpProvider);
});

/// Operaciones de autenticación del contrato (`/api/v{version}/auth/...`).
final authApiProvider = Provider<AuthApi>(
  (ref) => AuthApi(ref.watch(clienteApiProvider)),
);
