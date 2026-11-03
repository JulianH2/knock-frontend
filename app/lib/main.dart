import 'package:app/app.dart';
import 'package:app/core/red/cliente_api_provider.dart';
import 'package:app/core/red/configuracion_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  // TT-MOB-08: una configuración de la API no permitida (URL inválida,
  // release sin URL o modo real sin cliente real) falla aquí, al arrancar,
  // con `ErrorDeConfiguracionApi`, y no al abrir la primera pantalla.
  crearClienteApi(ConfiguracionApi.desdeEntorno());
  runApp(const ProviderScope(child: KnockApp()));
}
