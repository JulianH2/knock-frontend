# TT-PRU-02 — tareas

## T1 — Dominio, errores y mapeador del contrato [Mobile]
- **Crear:** `core/errores/failure.dart`, `features/oficios/domain/` (`Oficio`, `Modalidad`, `OficiosRepository`) y `features/oficios/data/oficio_mapper.dart`; pruebas `modalidad_test.dart` y `oficio_mapper_test.dart`.
- **Modificar:** —
- **Verificar:** TC-TT-PRU-02-06 (parte de dominio), 07 y 08.
- **No hacer:** importar `flutter`, `dio`, `flutter_riverpod` ni `knock_api` en `domain/`; inventar un contrato provisional.
- **Agente:** flutter-builder, con la spec Aprobada por una persona distinta del autor.

## T2 — Repositorio con datos de prueba [Mobile]
- **Crear:** `features/oficios/data/oficios_repository_de_prueba.dart` (los 3 oficios del contrato de TT-PRU-01 pasando por el mapeador).
- **Modificar:** —
- **Verificar:** TC-TT-PRU-02-07 (los datos salen del mapeador) y TC-TT-PRU-02-11 (sin red ni datos reales).
- **No hacer:** agregar `dio` ni ninguna dependencia; hacer llamadas de red.
- **Agente:** flutter-builder.

## T3 — Controlador y pantalla con los cuatro estados [Mobile]
- **Crear:** `features/oficios/presentation/oficios_controller.dart` y `oficios_screen.dart`; `oficios_screen_test.dart`.
- **Modificar:** —
- **Verificar:** TC-TT-PRU-02-01 a 06 y 09 (carga, datos, vacío, error con Reintentar, íconos, modalidad desconocida y texto al 200 %).
- **No hacer:** importar `dio`, `knock_api` o `data/` desde `presentation/`; mostrar detalles técnicos del error; reordenar la lista.
- **Agente:** flutter-builder.

## T4 — Ruta y acceso desde Explorar [Mobile]
- **Crear:** `test/core/router/rutas_oficios_test.dart`.
- **Modificar:** `core/router/rutas.dart`, `core/router/app_router.dart` y `features/explorar/presentation/explorar_screen.dart` (acceso temporal, duda 2).
- **Verificar:** TC-TT-PRU-02-10 y que las pruebas de TT-MOB-01 siguen en verde sin cambios.
- **No hacer:** cambiar las 5 pestañas ni la barra inferior; redirecciones nuevas.
- **Agente:** flutter-builder.

## T5 — Verificación y cierre [Pruebas]
- **Crear:** —
- **Modificar:** `Memoria.md`.
- **Verificar:** TC-TT-PRU-02-11 y 12 (comandos), `sdd_lint --trace TT-PRU-02`, CI en verde; la captura de la pantalla y la nota de cuánto tardó y qué fue difícil (ficha §5) en el PR.
- **No hacer:** afirmar que las pruebas pasaron sin el resultado real del CI (Flutter local 3.29.0 frente a 3.47.7).
- **Agente:** persona responsable + `security-reviewer` y `traceability-clerk` antes del PR.
