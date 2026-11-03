# TT-MOB-03 — tareas

## T0 — Respuestas del líder y orden de PR [Gestión]
- **Hacer:** obtener respuesta a §8 D1 a D15; acordar el PR del líder con `scripts/sync_contract.py`, `scripts/gen_clients.sh` y el job `contract` (D1).
- **Verificar:** spec Aprobada por una persona distinta del autor; TT-MOB-08 fusionada en `sprint-02`.
- **No hacer:** empezar código con la spec en Borrador.
- **Responsable:** Erick Trejo Reséndiz + líder.

## T1 — Spike del generador y evaluación de dependencias [Mobile]
- **Crear:** configuración y script del generador en `app/tool/` con versión fija (D2).
- **Modificar:** `Memoria.md` (licencia, mantenimiento, publicador y OSV de cada paquete nuevo).
- **Verificar:** el contrato vigente genera y compila sin editar nada a mano; si no, informar al líder antes de seguir.
- **No hacer:** `pub add` sin la evaluación escrita; editar el contrato o el paquete generado.
- **Agente:** persona responsable (los archivos protegidos los escribe una persona).

## T2 — Contrato vendorizado y cliente generado [Mobile]
- **Crear:** `contracts/openapi.v1.json` (persona), `app/packages/knock_api/` (generado), `cliente_generado_test.dart`.
- **Modificar:** `app/pubspec.yaml`/`pubspec.lock`.
- **Verificar:** TC-TT-MOB-03-01, 02, 03 y 04.
- **No hacer:** tocar `scripts/` ni `.github/` sin permiso del líder (D1).
- **Agente:** persona + flutter-builder para la prueba.

## T3 — Cliente real, simulación por adaptador y proveedor [Mobile]
- **Crear:** `core/red/cliente_real.dart`, `core/red/adaptador_simulado.dart`, `cliente_real_test.dart`, `cliente_api_provider_test.dart`.
- **Modificar:** `core/red/cliente_api_provider.dart`; pruebas de TT-MOB-08 que dependan de `ClienteApi` (mismos nombres `TC-TT-MOB-08-KK`).
- **Verificar:** TC-TT-MOB-03-05 y 12; `sdd_lint --trace TT-MOB-08` sigue en OK.
- **No hacer:** rutas escritas a mano (D3); seguir redirecciones; registrar peticiones.
- **Agente:** flutter-builder.

## T4 — Sesión: almacén, interceptor y renovador [Mobile]
- **Crear:** `core/sesion/almacen_de_sesion.dart`, `core/red/interceptor_sesion.dart`, `core/red/renovador_de_sesion.dart` y sus pruebas.
- **Modificar:** `AndroidManifest.xml` solo si D5 trae el almacén seguro aquí.
- **Verificar:** TC-TT-MOB-03-06, 07 y 13.
- **No hacer:** `SharedPreferences` o archivos para tokens; `/auth/refresh`, rotación o cola (HU-003).
- **Agente:** flutter-builder.

## T5 — Errores y textos [Mobile]
- **Crear:** `core/red/traductor_errores.dart`, `core/errores/mensaje_de_failure.dart` y sus pruebas.
- **Modificar:** `core/errores/failure.dart` (D7), ARB es/en, `features/oficios/data/oficios_repository_api.dart` (cliente generado).
- **Verificar:** TC-TT-MOB-03-08 y 09; pruebas de TT-PRU-02 en verde sin cambios.
- **No hacer:** mostrar `title`/`detail` del servidor; cambiar la pantalla de oficios.
- **Agente:** flutter-builder.

## T6 — Servidor local, capas y cierre [Pruebas]
- **Crear:** `oficios_cambio_de_url_test.dart`, `cliente_real_local_test.dart`, `arquitectura_cliente_test.dart`.
- **Modificar:** `docs/architecture/*` (regenerado), `Memoria.md`.
- **Verificar:** TC-TT-MOB-03-10, 11, 14, 15 y 16; mutación manual de los casos 06 a 08; `sdd_lint --trace TT-MOB-03`; CI en verde.
- **No hacer:** llamadas a internet en pruebas; bajar umbrales; afirmar resultados sin ejecutarlos.
- **Agente:** persona responsable + `security-reviewer` y `traceability-clerk` antes del PR.
