# HU-052 — tareas

> Ninguna tarea empieza antes de que el PR #16 (TT-MOB-02) esté fusionado en `sprint-02`, esta rama rebasada y la spec Aprobada por una persona distinta del autor.

## T1 — Evaluar y agregar `shared_preferences` [Mobile]
- **Crear:** —
- **Modificar:** `app/pubspec.yaml`, `app/pubspec.lock` (con `flutter pub add shared_preferences`), `Memoria.md` (evaluación: necesidad, licencia, editor, mantenimiento, OSV, transitivas).
- **Verificar:** TC-HU-052-11 (comando).
- **No hacer:** agregar otros paquetes (`hive`, `flutter_secure_storage` para esto, `mocktail` si no hace falta); fijar versiones a mano en el lock.
- **Agente:** persona responsable (decide la dependencia) + flutter-builder.

## T2 — Almacén de preferencias y arranque [Mobile]
- **Crear:** `core/preferencias/almacen_preferencias.dart`, `core/preferencias/arranque.dart`; pruebas `almacen_preferencias_test.dart`, `arranque_test.dart`, `arquitectura_preferencias_test.dart`.
- **Modificar:** `core/preferencias/preferencias_provider.dart` (carga en `build()`, guardado en `cambiarTema`/`cambiarIdioma`), `main.dart`.
- **Verificar:** TC-HU-052-05, 06, 07 y 08; TC-TT-MOB-02-01 sigue verde.
- **No hacer:** crear un segundo proveedor de tema o idioma; guardar algo distinto de las dos claves; registrar errores en logs; volver asíncrono el `build()` del proveedor.
- **Agente:** flutter-builder.

## T3 — Pantalla Configuración, ruta y Mi cuenta [Mobile]
- **Crear:** `features/cuenta/presentation/configuracion_screen.dart`; pruebas `configuracion_screen_test.dart`, `cuenta_screen_test.dart`, `rutas_configuracion_test.dart`.
- **Modificar:** `core/router/rutas.dart`, `core/router/app_router.dart`, `features/cuenta/presentation/cuenta_screen.dart`, `features/cuenta/presentation/widgets/menu_de_prueba.dart`, `lib/l10n/app_es.arb`, `lib/l10n/app_en.arb` y `lib/l10n/generado/*` (con `flutter gen-l10n`).
- **Verificar:** TC-HU-052-01, 03, 04, 09 y 10.
- **No hacer:** textos escritos directo; mostrar «Modo técnico (prueba)» en release; dejar selectores de tema o idioma en el menú de prueba; editar a mano los `.dart` generados; cambiar la paleta o los roles de color.
- **Agente:** flutter-builder.

## T4 — Ajustar pruebas de TT-MOB-02 y respaldo al español [Pruebas]
- **Crear:** `test/l10n/respaldo_espanol_test.dart` y `test/l10n/respaldo/app_es.arb`, `app_en.arb`.
- **Modificar:** `test/features/cuenta/menu_de_prueba_test.dart` y `test/l10n/textos_desde_arb_test.dart` (solo el camino a los selectores y las claves; aserciones e IDs iguales, spec §8 duda 2); `test/soporte/montar_app.dart` solo si hace falta.
- **Verificar:** TC-HU-052-02; TC-TT-MOB-02-01, 02 y 04 siguen verdes; las pruebas de TT-MOB-01 y TT-PRU-02 sin cambios.
- **No hacer:** quitar una traducción de `app_en.arb` para probar el respaldo; relajar la comparación de claves de TC-TT-MOB-02-02; borrar o renombrar casos de otra spec.
- **Agente:** flutter-builder.

## T5 — E2E, verificación y cierre [Pruebas]
- **Crear:** `app/integration_test/configuracion_test.dart`.
- **Modificar:** `docs/architecture/*` (con `python scripts/codemap.py`), `app/README.md`, `Memoria.md`.
- **Verificar:** TC-HU-052-05 (emulador y evidencia manual del reinicio), TC-HU-052-11 y 12 (comandos), `sdd_lint --trace HU-052`, CI en verde; capturas en claro, oscuro, español e inglés en el PR.
- **No hacer:** afirmar que algo pasó sin ejecutarlo; bajar umbrales o saltar pruebas.
- **Agente:** persona responsable + `security-reviewer` y `traceability-clerk` antes del PR.
