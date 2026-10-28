# TT-MOB-08 — tareas

## T1 — Contrato de red y configuración [Mobile]
- **Crear:** `core/red/cliente_api.dart`, `core/red/configuracion_api.dart`, `core/red/cliente_api_provider.dart`; pruebas `configuracion_api_test.dart` y `arquitectura_red_test.dart`.
- **Modificar:** —
- **Verificar:** TC-TT-MOB-08-01, 02 y 12.
- **No hacer:** escribir una URL real; caer al modo simulado ante una URL inválida; importar `features/` desde `core/red/`.
- **Agente:** flutter-builder, con la spec Aprobada por una persona distinta del autor.

## T2 — API simulada y prueba de contrato [Mobile]
- **Crear:** `core/red/simulada/cliente_api_simulado.dart`, `core/red/simulada/respuestas_simuladas.dart`, `app/test/contrato/contrato_s4.json` (con la fuente y el commit de cada §4), `cliente_api_simulado_test.dart` y `mocks_vs_contrato_test.dart`.
- **Modificar:** —
- **Verificar:** TC-TT-MOB-08-03 a 07; comprobar a mano que la prueba de contrato falla con un mock alterado.
- **No hacer:** datos reales, tokens con forma de JWT, assets nuevos en `pubspec.yaml`; escribir nada en `contracts/`.
- **Agente:** flutter-builder.

## T3 — Cliente HTTP de transición [Mobile] (solo si se aprueba D2)
- **Crear:** `core/red/cliente_api_http.dart` y `cliente_api_http_test.dart` (con `HttpServer` en `127.0.0.1`).
- **Modificar:** `core/red/cliente_api_provider.dart` (modo real).
- **Verificar:** TC-TT-MOB-08-08.
- **No hacer:** agregar `dio` o `http`; enviar `Authorization`; seguir redirecciones; registrar URL o cuerpo.
- **Agente:** flutter-builder.

## T4 — Oficios contra la API [Mobile]
- **Crear:** `features/oficios/data/oficios_repository_api.dart`, `oficios_repository_api_test.dart`, `oficios_cambio_de_url_test.dart` y `presentation/oficios_api_simulada_test.dart`.
- **Modificar:** `core/errores/failure.dart` (`SolicitudRechazadaFailure`, D7) y `features/oficios/oficios_providers.dart`.
- **Verificar:** TC-TT-MOB-08-09, 10 y 11; todas las pruebas de TT-PRU-02 y TT-MOB-01 en verde sin cambios.
- **No hacer:** cambiar la pantalla, el controlador ni `OficiosRepositoryDePrueba`; importar `core/red/` desde `presentation/`.
- **Agente:** flutter-builder.

## T5 — Privacidad, verificación y cierre [Pruebas]
- **Crear:** `app/test/core/red/privacidad_red_test.dart`.
- **Modificar:** `docs/architecture/*` (regenerado con `codemap.py`) y `Memoria.md`.
- **Verificar:** TC-TT-MOB-08-13, 14 y 15 (comandos con su salida en el PR), `sdd_lint --trace TT-MOB-08`, CI en verde, captura de la pantalla de oficios en el emulador con `normal` y `error_servidor`.
- **No hacer:** afirmar que las pruebas pasaron sin el resultado real; bajar umbrales.
- **Agente:** persona responsable + `security-reviewer` y `traceability-clerk` antes del PR.
