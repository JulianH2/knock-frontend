# plan.md — HU-052 Elegir idioma y tema en Configuración

> **Precondición:** el PR #16 (TT-MOB-02, KNOCK-25) fusionado en `sprint-02` y esta rama rebasada sobre `sprint-02`. Antes de eso no se escribe código.

## 1. Mapeo de archivos
- **Reutilizar (leído en `origin/chore/KNOCK-25-theme-and-languages`; volver a buscar con `python scripts/codemap.py --query "preferencias"` y `--query "configuracion"` después del rebase):**
  - `core/preferencias/preferencias_provider.dart` (`Preferencias`, `PreferenciasNotifier`, `preferenciasProvider`, `idiomasSoportados`): **se extiende**, no se duplica.
  - `app.dart` (`KnockApp` ya lee `themeMode` y `locale`), `core/tema/` (temas y colores), `core/widgets/pantalla_titulada.dart`, `core/router/` (`Rutas`, `appRouterProvider`, `_rama` con subrutas), `core/sesion/es_tecnico_provider.dart` (`interruptorDePruebaProvider`).
  - Widgets `_Encabezado` y `_Opcion` de `features/cuenta/presentation/widgets/menu_de_prueba.dart` (se mueven a Configuración).
  - Arnés de pruebas `test/soporte/montar_app.dart` (`montarApp`, `leerArb`, `enLaBarra`, `enElTitulo`, `ubicacion`, `tocarTexto`) y el método de `test/features/oficios/arquitectura_test.dart` para leer `import`.
- **Crear (`app/lib/`):**
  - `core/preferencias/almacen_preferencias.dart` — interfaz `AlmacenPreferencias`, `AlmacenPreferenciasShared` (sobre `SharedPreferences`, claves `knock.preferencias.tema` / `.idioma`, conversión estricta) y `AlmacenPreferenciasEnMemoria`; `almacenPreferenciasProvider` (por defecto en memoria, spec §8 duda 5).
  - `core/preferencias/arranque.dart` (o nombre equivalente) — función que obtiene `SharedPreferences.getInstance()` y devuelve el almacén, o el de memoria si falla (TC-05, TC-08).
  - `features/cuenta/presentation/configuracion_screen.dart` — `ConfiguracionScreen`.
- **Crear (`app/test/` y `app/integration_test/`):**
  - `test/core/preferencias/almacen_preferencias_test.dart` (TC-06, 07, 08), `test/core/preferencias/arranque_test.dart` (TC-05, 08), `test/core/preferencias/arquitectura_preferencias_test.dart` (TC-06).
  - `test/features/cuenta/configuracion_screen_test.dart` (TC-01, 03, 04, 10), `test/features/cuenta/cuenta_screen_test.dart` (TC-09), `test/core/router/rutas_configuracion_test.dart` (TC-09).
  - `test/l10n/respaldo_espanol_test.dart` y `test/l10n/respaldo/app_es.arb`, `app_en.arb` (TC-02; ARB de prueba, no se cargan en la app).
  - `integration_test/configuracion_test.dart` (TC-05, emulador).
- **Modificar:**
  - `core/preferencias/preferencias_provider.dart` — `build()` lee del almacén; `cambiarTema` / `cambiarIdioma` guardan después de cambiar el estado. Se actualiza el comentario «solo en memoria».
  - `main.dart` — `async`, `ensureInitialized`, almacén antes de `runApp`, override en `ProviderScope`.
  - `core/router/rutas.dart` (`Rutas.configuracion = '/cuenta/configuracion'`) y `core/router/app_router.dart` (subruta `configuracion` de la rama Mi cuenta).
  - `features/cuenta/presentation/cuenta_screen.dart` (lista con la entrada «Configuración» siempre y el menú de prueba solo fuera de release) y `widgets/menu_de_prueba.dart` (solo el interruptor de técnico).
  - `lib/l10n/app_es.arb`, `lib/l10n/app_en.arb` (claves `configuracion…`, se quitan las `pruebaTema…`/`pruebaIdioma…`) y `lib/l10n/generado/*` **regenerados con `flutter gen-l10n`** (no a mano).
  - `pubspec.yaml` y `pubspec.lock` (`shared_preferences`, con `flutter pub add`).
  - Pruebas de TT-MOB-02, solo el camino y las claves (spec §8 duda 2): `test/features/cuenta/menu_de_prueba_test.dart`, `test/l10n/textos_desde_arb_test.dart`; y, si hace falta, el arnés `test/soporte/montar_app.dart` (p. ej. parámetro para el almacén).
  - `docs/architecture/*` regenerado con `python scripts/codemap.py`, `app/README.md` (sección de preferencias guardadas) y `Memoria.md`.
- **No tocar:** `contracts/`, `app/packages/knock_api/`, `.github/`, `scripts/`, la constitución, `core/tema/` (paleta y contrastes), `l10n.yaml`, la regla de la pestaña Trabajo y `es_tecnico_provider.dart`, las pruebas de TT-MOB-01 y TT-PRU-02 (deben seguir en verde sin cambios) y las aserciones de las pruebas de TT-MOB-02.

## 2. Riesgos y efectos secundarios
- **PR #16 sin fusionar:** si cambia antes del merge, los nombres de este plan pueden no coincidir; revisar después del rebase.
- **`KnockApp` y el router:** cambiar `main.dart` no debe recrear el router ni el `MaterialApp` al cambiar tema o idioma (TC-01 y TC-TT-MOB-02-01 lo vigilan).
- **Pruebas que montan `KnockApp` sin overrides** (`rutas_oficios_test.dart`, `app_shell_test.dart`…): con el almacén en memoria por defecto siguen igual; si se elige la alternativa de la duda 5, hay que tocar su arnés.
- **`SharedPreferences.setMockInitialValues` es global por proceso de prueba:** cada prueba lo fija en su `setUp` para no arrastrar valores de otra.
- **`platformBrightnessTestValue`** se limpia con `addTearDown(clearPlatformBrightnessTestValue)` para no afectar otras pruebas.
- **Prueba de gen-l10n con `Process.run`** (TC-02): depende de `flutter` en el `PATH`; si resulta frágil en el CI, se pasa a «(comando)» con permiso del revisor.
- **Claves ARB borradas:** el job del CI que regenera `gen-l10n` falla si no se regeneran y versionan los `.dart`.

## 3. Pruebas por caso
| Caso | Prueba | Suite |
|---|---|---|
| TC-HU-052-01 | English cambia los textos sin reiniciar y conserva la ruta | `app/test/features/cuenta/configuracion_screen_test.dart` |
| TC-HU-052-02 | Respaldo al español con ARB de prueba y gen-l10n; idioma no soportado → español | `app/test/l10n/respaldo_espanol_test.dart` |
| TC-HU-052-03 | Oscuro en las 5 pestañas y Configuración | `configuracion_screen_test.dart` |
| TC-HU-052-04 | Automático sigue al teléfono; Claro lo ignora | `configuracion_screen_test.dart` |
| TC-HU-052-05 | Reinicio simulado: inglés y oscuro desde el primer cuadro; sin datos, español y Automático; plugin real en emulador | `app/test/core/preferencias/arranque_test.dart` · `app/integration_test/configuracion_test.dart` · manual |
| TC-HU-052-06 | Solo dos claves con valores permitidos; solo `core/preferencias/` importa el paquete | `almacen_preferencias_test.dart` · `arquitectura_preferencias_test.dart` |
| TC-HU-052-07 | Valores y tipos inválidos → por defecto, sin reescribir | `almacen_preferencias_test.dart` |
| TC-HU-052-08 | Fallo al leer o guardar no rompe la app | `almacen_preferencias_test.dart` · `arranque_test.dart` |
| TC-HU-052-09 | Configuración visible en release; menú de prueba solo con el modo técnico; ruta `/cuenta/configuracion` | `app/test/features/cuenta/cuenta_screen_test.dart` · `app/test/core/router/rutas_configuracion_test.dart` |
| TC-HU-052-10 | Semántica de radio, encabezados, guías de tamaño, etiqueta y contraste en claro y oscuro; texto al 200 % | `configuracion_screen_test.dart` |
| TC-HU-052-11 | Dependencia evaluada y OSV limpio (comando) | `git diff`, `flutter pub deps`, OSV-Scanner del CI (salida en el PR) |
| TC-HU-052-12 | Formato, análisis, gen-l10n al día y pruebas (comando) | CI de la app |

## 4. Secuencia
1. Esperar el merge del PR #16; rebasar sobre `sprint-02`; repetir `codemap.py --query`. Spec Aprobada por una persona distinta del autor.
2. Evaluar `shared_preferences` y registrarlo en `Memoria.md`; `flutter pub add shared_preferences` (TC-11).
3. Almacén, conversión y arranque con sus unitarias (TC-05 parte unitaria, 06, 07, 08).
4. Extender `PreferenciasNotifier` y `main.dart`; prueba del primer cuadro (TC-05).
5. Ruta, Mi cuenta, Configuración y menú de prueba reducido; ARB y `flutter gen-l10n` (TC-01, 03, 04, 09, 10).
6. Ajustar las dos pruebas de TT-MOB-02 (solo camino y claves) y comprobar que TT-MOB-01, TT-MOB-02 y TT-PRU-02 siguen verdes.
7. Respaldo al español (TC-02) y E2E en emulador (TC-05).
8. Gates (TC-12), `codemap.py`, `Memoria.md`, capturas y video del reinicio, informe con «Uso de IA».

## 5. Verificación (comandos exactos)
```bash
cd app && flutter pub get
cd app && dart format --set-exit-if-changed lib test integration_test
cd app && flutter analyze --fatal-infos
cd app && flutter gen-l10n && git status --porcelain lib/l10n/generado
cd app && flutter test --coverage
cd app && flutter test integration_test        # emulador Android
git diff origin/sprint-02 -- app/pubspec.yaml
cd app && flutter pub deps --style=compact | grep shared_preferences
python scripts/sdd_lint.py
python scripts/sdd_lint.py --trace HU-052
python scripts/codemap.py --check
python scripts/ci/check_exceptions.py
python scripts/sync_agents.py --check
```
