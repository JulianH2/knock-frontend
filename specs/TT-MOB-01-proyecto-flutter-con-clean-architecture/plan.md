# plan.md — TT-MOB-01 Proyecto Flutter con Clean Architecture (core/features), Riverpod, go_router y las 5 pestañas de la maqueta

## 1. Mapeo de archivos
- **Reutilizar (buscado con `codemap.py --query`):** no hay código de producto todavía (`app/` no existe). Reutilizar `docs/templates/app/analysis_options.yaml` (spec §8, decisión 6) y las entradas existentes de `.gitignore` para Flutter, Firebase y firma.
- **Crear:**
  - `app/` con `flutter create --org mx.knock --platforms android,ios app` (paquete `app`; el identificador queda en `app.knock.mobile`, como está registrado en Firebase; decisión 9).
  - `app/lib/main.dart` (arranque con `ProviderScope`).
  - `app/lib/core/router/` — `GoRouter` con `StatefulShellRoute`, barra inferior y `redirect` de `/trabajo` a `/inicio` si no es técnico; lee el indicador «es técnico».
  - `app/lib/core/sesion/` — `esTecnicoProvider` (`Notifier<bool>`, inicia en falso; decisión 1) e `interruptorDePruebaProvider` (`!kReleaseMode`).
  - `app/lib/core/widgets/pantalla_titulada.dart` — barra con título + cuerpo que comparten las 5 pantallas (agregado al implementar: evita clones).
  - `app/lib/features/{inicio,explorar,actividad,trabajo,cuenta}/presentation/<x>_screen.dart` — pantalla vacía con título; Mi cuenta con el interruptor «Modo técnico (prueba)» solo si `!kReleaseMode`.
  - `app/lib/features/<x>/{domain,data}/.gitkeep` y `app/lib/core/{tema,errores,red}/.gitkeep` (decisión 10).
  - `app/test/core/router/app_shell_test.dart` — TC-TT-MOB-01-02 y TC-TT-MOB-01-04 (+ A11Y).
  - `app/test/core/router/rutas_test.dart` — unitarias de la regla de rol (`redireccionPorRol`, `ramasVisibles`), TC-TT-MOB-01-02 (agregado al implementar).
  - `app/integration_test/tabs_navigation_test.dart` — TC-TT-MOB-01-01 (decisión 7).
  - `app/README.md` — versión de Flutter y cómo correr la app.
- **Modificar:** `app/pubspec.yaml` (`flutter_riverpod`, `go_router`; `integration_test` en `dev_dependencies`), `app/analysis_options.yaml` (copia de la plantilla), `Memoria.md`.
- **No tocar:** `contracts/`, `app/packages/knock_api/`, `panel/`, `.gitignore` (ya cubre los archivos sensibles), workflows (TT-CI-01), scripts de gobierno.

## 2. Riesgos y efectos secundarios
- **Dependencias:** dos paquetes nuevos de producción; evaluar y fijar versión antes de agregarlos (constitución). La versión de Flutter elegida condiciona TT-CI-01.
- **Arquitectura:** el router está en `core/` y no debe importar internos (`data/`, `domain/`) de una feature; solo sus pantallas públicas de `presentation/`. El mapa de código (`codemap.py`) detecta importaciones cruzadas a `data|domain`.
- **Archivos generados por `flutter create`:** revisar que no se versionen artefactos (`build/`, `.dart_tool/`) ni archivos de firma o Firebase; `.gitignore` raíz ya los cubre, más el `.gitignore` propio que genera Flutter.
- **Mapa de código:** al existir `app/lib`, `docs/architecture/*` cambia; regenerar con `python scripts/codemap.py` e incluirlo en el PR.
- **Trazabilidad:** con pruebas en `app/test/`, `sdd_lint.py --trace` deja de devolver «AVISO» y reporta FALTA para casos manuales o por comando: TC-03 saldrá FALTA y se documenta en el PR (spec §8, decisión 8).

## 3. Pruebas por caso
| Caso | Prueba | Suite |
|---|---|---|
| TC-TT-MOB-01-01 | Video en emulador Android + `testWidgets('TC-TT-MOB-01-01 abre la app y navega entre las 5 pestañas', …)` en `app/integration_test/tabs_navigation_test.dart` | manual + E2E (`flutter test integration_test`) |
| TC-TT-MOB-01-02 | `testWidgets('TC-TT-MOB-01-02 oculta la pestaña Trabajo si el usuario no es técnico', …)` — con override falso: 4 destinos y sin «Trabajo»; con verdadero: 5 destinos; sin interruptor de prueba (release) Mi cuenta no ofrece «Modo técnico»; más unitarias en `rutas_test.dart` | widget + unitaria (`flutter test`) |
| TC-TT-MOB-01-03 | `cd app && flutter analyze --fatal-infos` → «No issues found!» y `dart format --set-exit-if-changed lib test` sin cambios | comando |
| TC-TT-MOB-01-04 | `testWidgets('TC-TT-MOB-01-04 tocar cada pestaña muestra su pantalla', …)` — por cada destino: tap, `pumpAndSettle`, título visible y destino seleccionado; más `meetsGuideline` de tamaño táctil y etiquetas | widget (`flutter test`) |

## 4. Secuencia
1. Decisiones de §8 de la spec resueltas y spec Aprobada; evaluar dependencias y registrar en `Memoria.md`.
2. `flutter create`, estructura `core/` y `features/`, `analysis_options.yaml`.
3. Agregar `flutter_riverpod` y `go_router`; router con `StatefulShellRoute`, barra inferior e indicador «es técnico».
4. Pantallas vacías con título.
5. Pruebas de widget (TC-02, TC-04, A11Y) y `integration_test` (TC-01).
6. Verificación en emulador (video), `app/README.md`.
7. Gates + `codemap.py` + `Memoria.md` + informe final en el PR.

## 5. Verificación (comandos exactos)
```bash
cd app && flutter pub get
dart format --set-exit-if-changed lib test
flutter analyze --fatal-infos
flutter test --coverage
flutter test integration_test            # emulador Android encendido
cd .. && python scripts/codemap.py && python scripts/codemap.py --check
python scripts/sdd_lint.py && python scripts/sdd_lint.py --trace TT-MOB-01
python scripts/ci/check_exceptions.py && python scripts/sync_agents.py --check
```
