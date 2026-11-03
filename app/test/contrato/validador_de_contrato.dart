import 'dart:convert';
import 'dart:io';

import 'package:app/core/red/cliente_api.dart';

/// Tabla de contrato de la §4 (`contrato_s4.json`) y un validador de un
/// subconjunto de JSON Schema (`type`, `required`, `properties`,
/// `additionalProperties`, `nullable`, `maxLength`, `pattern`, `items` y
/// `$ref` a `definiciones`), sin dependencias (spec §8 D5).
final class TablaDeContrato {
  TablaDeContrato(this.json);

  /// La tabla versionada. `flutter test` corre desde `app/`.
  factory TablaDeContrato.versionada() => TablaDeContrato(
    jsonDecode(File('test/contrato/contrato_s4.json').readAsStringSync())
        as Map<String, Object?>,
  );

  final Map<String, Object?> json;

  Map<String, Object?> get _definiciones =>
      json['definiciones']! as Map<String, Object?>;

  List<Map<String, Object?>> get endpoints => [
    for (final e in json['endpoints']! as List<Object?>)
      e! as Map<String, Object?>,
  ];

  /// Las filas `MÉTODO ruta estado` de la tabla.
  Set<String> get filas => {
    for (final endpoint in endpoints)
      for (final estado
          in (endpoint['respuestas']! as Map<String, Object?>).keys)
        fila(
          endpoint['metodo']! as String,
          endpoint['ruta']! as String,
          estado,
        ),
  };

  static String fila(String metodo, String ruta, Object estado) =>
      '$metodo $ruta $estado';

  /// Errores de una respuesta simulada contra su fila; vacío si cumple. Si no
  /// hay fila para ese endpoint y estado, lo dice como error.
  List<String> errores(PeticionApi peticion, RespuestaApi respuesta) {
    final nombre = fila(peticion.metodo, peticion.ruta, respuesta.estado);
    final endpoint = endpoints
        .where(
          (e) => e['metodo'] == peticion.metodo && e['ruta'] == peticion.ruta,
        )
        .firstOrNull;
    final filaDeRespuesta =
        (endpoint?['respuestas']
                as Map<String, Object?>?)?['${respuesta.estado}']
            as Map<String, Object?>?;
    if (endpoint == null || filaDeRespuesta == null) {
      return ['$nombre: mock sin fila en la tabla'];
    }
    final errores = <String>[];
    if (respuesta.tipoDeContenido != filaDeRespuesta['contentType']) {
      errores.add('$nombre: Content-Type ${respuesta.tipoDeContenido}');
    }
    final encabezados = {
      ...?endpoint['encabezados'] as Map<String, Object?>?,
      ...?filaDeRespuesta['encabezados'] as Map<String, Object?>?,
    };
    for (final MapEntry(:key, :value) in encabezados.entries) {
      final recibido = respuesta.encabezado(key);
      if (recibido == null || !RegExp(value! as String).hasMatch(recibido)) {
        errores.add('$nombre: encabezado $key ausente o distinto');
      }
    }
    for (final prohibido
        in (endpoint['encabezadosProhibidos'] as List<Object?>?) ?? const []) {
      if (respuesta.encabezado(prohibido! as String) != null) {
        errores.add('$nombre: encabezado $prohibido no permitido');
      }
    }
    final Object? cuerpo;
    try {
      cuerpo = jsonDecode(respuesta.cuerpo);
    } on FormatException {
      return [...errores, '$nombre: el cuerpo no es JSON'];
    }
    errores.addAll(
      erroresDeEsquema(
        cuerpo,
        filaDeRespuesta['esquema']! as Map<String, Object?>,
        nombre,
      ),
    );
    if (respuesta.tipoDeContenido == 'application/problem+json' &&
        cuerpo is Map<String, Object?> &&
        cuerpo['status'] != respuesta.estado) {
      errores.add('$nombre: status del cuerpo distinto del estado');
    }
    return errores;
  }

  /// Errores de [valor] contra [esquema]; vacío si cumple.
  List<String> erroresDeEsquema(
    Object? valor,
    Map<String, Object?> esquema,
    String ruta,
  ) {
    final referencia = esquema[r'$ref'];
    if (referencia is String) {
      return erroresDeEsquema(
        valor,
        _definiciones[referencia]! as Map<String, Object?>,
        ruta,
      );
    }
    final desconocidas = esquema.keys.toSet().difference(_palabras);
    if (desconocidas.isNotEmpty) {
      return ['$ruta: palabras no soportadas $desconocidas'];
    }
    if (valor == null) {
      return esquema['nullable'] == true ? const [] : ['$ruta: null'];
    }
    final tipo = esquema['type'];
    final tipoCorrecto = switch (tipo) {
      'string' => valor is String,
      'integer' => valor is int,
      'number' => valor is num,
      'boolean' => valor is bool,
      'object' => valor is Map<String, Object?>,
      'array' => valor is List<Object?>,
      _ => false,
    };
    if (!tipoCorrecto) {
      return ['$ruta: se esperaba $tipo'];
    }
    return switch (valor) {
      final String texto => _erroresDeTexto(texto, esquema, ruta),
      final List<Object?> lista => [
        for (final (i, elemento) in lista.indexed)
          ...erroresDeEsquema(
            elemento,
            esquema['items']! as Map<String, Object?>,
            '$ruta[$i]',
          ),
      ],
      final Map<String, Object?> objeto => _erroresDeObjeto(
        objeto,
        esquema,
        ruta,
      ),
      _ => const [],
    };
  }

  static const _palabras = {
    'type',
    'required',
    'properties',
    'additionalProperties',
    'nullable',
    'maxLength',
    'pattern',
    'items',
  };

  List<String> _erroresDeTexto(
    String texto,
    Map<String, Object?> esquema,
    String ruta,
  ) {
    final maximo = esquema['maxLength'] as int?;
    final patron = esquema['pattern'] as String?;
    return [
      if (maximo != null && texto.length > maximo) '$ruta: más de $maximo',
      if (patron != null && !RegExp(patron).hasMatch(texto))
        '$ruta: no cumple $patron',
    ];
  }

  List<String> _erroresDeObjeto(
    Map<String, Object?> objeto,
    Map<String, Object?> esquema,
    String ruta,
  ) {
    final propiedades =
        (esquema['properties'] as Map<String, Object?>?) ?? const {};
    final requeridas = (esquema['required'] as List<Object?>?) ?? const [];
    return [
      for (final requerida in requeridas)
        if (!objeto.containsKey(requerida)) '$ruta.$requerida: falta',
      if (esquema['additionalProperties'] == false)
        for (final clave in objeto.keys)
          if (!propiedades.containsKey(clave)) '$ruta.$clave: campo de más',
      for (final MapEntry(:key, :value) in objeto.entries)
        if (propiedades[key] case final Map<String, Object?> subesquema)
          ...erroresDeEsquema(value, subesquema, '$ruta.$key'),
    ];
  }
}
