# TT-MOB-01 — Proyecto Flutter con Clean Architecture (core/features), Riverpod, go_router y las 5 pestañas de la maqueta

> **Jira:** KNOCK-24 (prioridad High) · **Épica:** EP-13 (KNOCK-13) · **Área:** MOB · App móvil base · **Responsable:** Erick Trejo Reséndiz · **Sprint:** S0 (12/10–16/10/2026) · **Puntos:** 3 · **Capas:** Mobile
> **Repositorio:** knock-frontend · **Otra parte en:** — · **Depende de:** TT-REPO-01, TT-STD-01
> **Ficha:** TT-MOB-01_ProyectoFlutterCleanArchitecture_Knock.docx
> **Fuentes:** DECISION_TECNICA.md §9 · FUNCIONES_Y_FLUJOS.md §2 (roles y pestañas: «Una sola cuenta… gana una pestaña extra») · README de la maqueta, sección «Un técnico sigue siendo usuario» (no está en este repositorio)
> **Skills:** story-workflow, flutter-clean-architecture, testing-strategy-frontend, security-core, reuse-before-create
> **Estado:** Aprobada

## 1. Objetivo
Dejar la base de la app móvil con la misma arquitectura del repo móvil del profesor (`MobileDevSecOps`, equivalencia capa por capa en DECISION_TECNICA §9) y la navegación de la maqueta, para que cada historia solo agregue su carpeta en `lib/features/`. Terminada cuando: **la app navega entre las 5 pestañas en Android**.

## 2. Historia y casos de prueba
**TT-MOB-01** — Tarea técnica (no es historia de usuario). Mezcla verificación automática (pruebas de widget e `integration_test`) y evidencia (video y comando), según la ficha.

| Caso | Criterio (Dado / Cuando / Entonces) | Verificación |
|---|---|---|
| TC-TT-MOB-01-01 | (Ficha V1) Dado el proyecto en `app/`, cuando se ejecuta en un emulador Android, entonces la app abre y se puede navegar entre las 5 pestañas (Inicio · Explorar · Actividad · Trabajo · Mi cuenta), cada una mostrando su pantalla. | Manual: emulador Android, video corto adjunto al PR. Automática: `app/integration_test/tabs_navigation_test.dart` → `testWidgets('TC-TT-MOB-01-01 abre la app y navega entre las 5 pestañas', …)` |
| TC-TT-MOB-01-02 | (Ficha V2) Dado que el usuario **no** es técnico (interruptor de prueba en falso), entonces la barra inferior muestra 4 pestañas y **no** aparece Trabajo, y navegar a `/trabajo` redirige a Inicio; dado que sí es técnico, aparece Trabajo entre Actividad y Mi cuenta. | `app/test/core/router/app_shell_test.dart` → `testWidgets('TC-TT-MOB-01-02 oculta la pestaña Trabajo si el usuario no es técnico', …)` |
| TC-TT-MOB-01-03 | (Ficha V3) Dado el código de `app/`, cuando se corre `flutter analyze --fatal-infos` (y `dart format --set-exit-if-changed lib test`), entonces no hay hallazgos. | (comando) Salida de `cd app && flutter analyze --fatal-infos` («No issues found!») pegada en el PR. Es además la evidencia del lado frontend de TC-TT-STD-01-04 si se adopta la plantilla `docs/templates/app/analysis_options.yaml` (ver §8) |
| TC-TT-MOB-01-04 | (Ficha, paso «prueba de widget») Dado el usuario técnico, cuando toca cada pestaña de la barra inferior, entonces se muestra la pantalla de esa pestaña con su título y la pestaña queda seleccionada. | `app/test/core/router/app_shell_test.dart` → `testWidgets('TC-TT-MOB-01-04 tocar cada pestaña muestra su pantalla', …)` |

**Por qué TC-TT-MOB-01-04 es un caso aparte de -01:** la ficha pide explícitamente, en sus pasos, una prueba de widget «tocar cada pestaña muestra su pantalla». V1 (TC-01) es una verificación en emulador con video, que no corre en cada PR; TC-04 es la regresión automática y rápida (sin dispositivo) del mismo comportamiento, y es la que protege la navegación cuando las historias siguientes agreguen sus carpetas.

## 3. Alcance / No-alcance
- **In (este repositorio):**
  - Proyecto Flutter en `app/` para Android e iOS: `flutter create --org mx.knock --platforms android,ios app`; luego el identificador pasa a `app.knock.mobile` (decisión 9).
  - Estructura Clean Architecture por función (skill `flutter-clean-architecture`, DECISION_TECNICA §9):
    - `lib/core/` con `router/` (go_router con `StatefulShellRoute` y la barra inferior). La ficha también nombra `tema`, `errores` y `red` dentro de `core/`; su contenido es de TT-MOB-02 y TT-MOB-03 (ver Out y §8).
    - `lib/features/<función>/{presentation,domain,data}` para `inicio`, `explorar`, `actividad`, `trabajo` y `cuenta`; en esta tarea solo `presentation/` tiene código (una pantalla vacía por pestaña).
  - Dependencias `flutter_riverpod` y `go_router` (con evaluación registrada en `Memoria.md`, constitución: «No se agregan dependencias sin evaluar»).
  - Barra inferior Inicio · Explorar · Actividad · Trabajo · Mi cuenta; cada pestaña es una pantalla vacía con su título y el estilo de la maqueta solo como referencia.
  - Trabajo solo visible si el usuario es técnico, por ahora con un **interruptor de prueba** (no hay sesión todavía).
  - Pruebas: widget (TC-02, TC-04) e `integration_test` de humo (TC-01).
  - `app/README.md`: cómo correr la app (requisitos, `flutter pub get`, `flutter run` en emulador Android, pruebas y análisis).
  - `Memoria.md`: estado, evaluación de dependencias y decisiones.
- **Out:**
  - Tema (paleta de la maqueta, claro/oscuro) e idiomas (ARB es/en): TT-MOB-02.
  - Llamadas a la API, cliente `packages/knock_api`, interceptor de red y errores `Failure`: TT-MOB-03 (Sprint 1).
  - Sesión, Firebase (configuración, `google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart`) y el comportamiento «sin cuenta no hay barra de pestañas» (FUNCIONES_Y_FLUJOS §2): tareas e historias posteriores.
  - Contenido real de cada pestaña (mapa, listas, «Mi negocio», capa «Mi agenda»): sus historias.
  - Plantillas `mutation_test.xml` y `layer_rules_test.dart` que menciona `docs/templates/README.md` (no existen aún en `docs/templates/app/`; TT-QA-01).
  - Workflows de CI que construyen y prueban la app: TT-CI-01.
  - Compilar o probar en iOS (requiere macOS; la ficha solo exige Android).
  - Firma, publicación en tiendas y el panel Angular.

## 4. Contratos API y eventos
— Sin endpoints ni eventos. No consume `contracts/openapi.v1.json` ni genera `app/packages/knock_api/`.

## 5. Modelo de datos
- Sin entidades de dominio ni persistencia.
- Estado local: un indicador «es técnico» (booleano) expuesto con Riverpod y leído por el router para mostrar u ocultar la rama Trabajo. Vive en memoria, no se guarda en disco; empieza en falso (§8, decisión 1).

## 6. Seguridad, privacidad y amenazas
Riesgo bajo: sin red, sin sesión, sin datos personales. STRIDE breve sobre lo que sí introduce la tarea:

| Amenaza | Control | Caso que lo prueba |
|---|---|---|
| Fuga de secretos: archivos de Firebase (`google-services.json`, `GoogleService-Info.plist`) o de firma (`key.properties`, `*.jks`, `*.keystore`) versionados al crear el proyecto | Ya ignorados en `.gitignore` (líneas 17–21, 49–51); la tarea no agrega Firebase; ninguna clave en el código; revisión del diff (`git status`/`git ls-files app/`) antes del commit y gitleaks en el CI | TC-TT-CI-01-02 (gitleaks) · revisión de `security-reviewer` (check 13) |
| Cadena de suministro: `flutter_riverpod` y `go_router` agregados sin evaluar, con versiones abiertas o vulnerables | Evaluación de necesidad, licencia, mantenimiento y vulnerabilidades registrada en `Memoria.md` y en el PR; versiones fijadas en `pubspec.yaml` y `pubspec.lock` versionado; OSV-Scanner en el CI | TC-TT-CI-01-02 / TC-TT-CI-01-03 (job de dependencias) · revisión de `security-reviewer` (check 14) |
| Elevación (solo de interfaz): un no técnico ve la pestaña Trabajo | La barra solo construye la rama Trabajo si el indicador es verdadero. **No es un control de seguridad:** la autorización real la hará la API cuando exista; el interruptor de prueba no debe quedar como mecanismo de producción | TC-TT-MOB-01-02 |
| Fuga de datos personales a la IA o en fixtures | Pantallas vacías y pruebas sin datos reales; no se pasan secretos ni datos personales a herramientas de IA (ficha, constitución) | Revisión del diff (`security-reviewer`, checks 7 y 16) |
| Advertencias ocultas que esconden defectos | `flutter analyze --fatal-infos` sin hallazgos; sin `// ignore` ni supresiones sin `EXC-NNN` | TC-TT-MOB-01-03 |

## 7. Pantallas
- **Shell con barra inferior** (`StatefulShellRoute`): destinos en este orden: Inicio · Explorar · Actividad · Trabajo · Mi cuenta (Trabajo solo si es técnico). Cada destino con icono y etiqueta de texto visible.
- **Pantallas** `inicio`, `explorar`, `actividad`, `trabajo`, `cuenta`: vacías, con su título. Estilo de la maqueta solo como referencia (el tema real es TT-MOB-02).
- **Estados (cargando, vacío, error, datos):** no aplican todavía: no hay datos ni llamadas. Cada historia los agrega con su contenido.
- **Textos:** «Inicio», «Explorar», «Actividad», «Trabajo», «Mi cuenta». Literales en español hasta que TT-MOB-02 los pase a ARB (§8, decisión 11).
- **Accesibilidad:** etiquetas de texto en cada destino (lectores de pantalla), áreas táctiles ≥ 48 dp, texto escalable; se comprueba con `meetsGuideline` en la prueba de widget (ver §8).

## 8. Pruebas, gates y límites
**Plan de pruebas** (meta de mutación: N/A, `domain/` vacío):

| Tipo | ¿Aplica? | Motivo / herramienta |
|---|---|---|
| Unitarias (UM) | No | Sin casos de uso ni lógica de dominio; el indicador «es técnico» se ejercita en las pruebas de widget |
| Widget (W) | Sí | `testWidgets` para TC-02 y TC-04 en `app/test/core/router/app_shell_test.dart`, con `ProviderScope` y override del indicador; sin red |
| Aceptación (ACC) | Sí | Cada caso con su ID en el nombre de la prueba; TC-03 por comando |
| Contrato (CON) | No | No consume la API |
| E2E | Sí | `integration_test` de humo en emulador Android para TC-01, además del video; `integration_test` (SDK) en `dev_dependencies` |
| Accesibilidad (A11Y) | Sí | En el archivo de TC-04: `meetsGuideline(androidTapTargetGuideline)` y `meetsGuideline(labeledTapTargetGuideline)` sobre la barra inferior |
| Compatibilidad | Parcial | Android en emulador (TC-01). iOS: el proyecto se crea, pero no se compila ni prueba sin macOS (nightly, TT-CI-01) |
| Mutación (MUT) | No | `domain/` vacío; meta 70 % aplica a features críticas cuando existan |
| Regresión visual (doradas) | No | El estilo real llega con TT-MOB-02 |
| Usabilidad (USA) | No | Pantallas vacías |

**Cobertura:** app ≥ 50 % líneas (`flutter test --coverage`).
**Gates:** `AGENTS.md §5` (App): `dart format --set-exit-if-changed lib test` sin cambios, `flutter analyze --fatal-infos` limpio, `flutter test` verde, cobertura ≥ 50 %; `sdd_lint.py`, `sdd_lint.py --trace TT-MOB-01`, `codemap.py --check`, `check_exceptions.py`, `sync_agents.py --check` en OK; `security-reviewer` LIBERA; `Memoria.md` al día; «Uso de IA» en el PR.

**Decisiones (propuestas por el agente a partir de la documentación; las confirma quien aprueba):**
1. **Interruptor de «técnico»:** `Notifier<bool>` de Riverpod (`esTecnicoProvider`) en `lib/core/sesion/`, con valor inicial **falso** (por defecto la cuenta es cliente; FUNCIONES_Y_FLUJOS §2: «si se registra como técnico… gana una pestaña extra»). Vive en `core/` porque lo leen el router y Mi cuenta, y una feature no usa internos de otra (AGENTS.md §4). Para la demo (V1), Mi cuenta muestra un `SwitchListTile` «Modo técnico (prueba)» **solo si `!kReleaseMode`**, así no llega a una compilación de tienda. Se retira cuando la sesión real dé el rol (historia de sesión). Las pruebas usan override del provider.
2. **Acceso a Trabajo sin ser técnico:** `redirect` de go_router (AGENTS.md §6: «go_router con redirect») que manda `/trabajo` a `/inicio` si el indicador es falso; el router se refresca al cambiar el indicador. Se prueba en TC-02.
3. **Dependencias:** solo `flutter_riverpod` (MIT, mantenido por el autor de Riverpod) y `go_router` (BSD-3, publicado por flutter.dev); última versión estable al crear el proyecto, restricción `^x.y.z` en `pubspec.yaml` y versión exacta fijada en `pubspec.lock` (versionado). **Sin** `riverpod_annotation` ni generador: la ficha solo nombra las dos y evita `build_runner`. En `dev_dependencies` solo `integration_test` (SDK, ya lo lista `docs/templates/README.md`). Evaluación (necesidad, licencia, mantenimiento, avisos de seguridad en pub.dev/OSV) en `Memoria.md` y en el PR.
4. **Flutter/Dart:** canal **stable**, la versión exacta instalada al hacer `flutter create`; se registra en `pubspec.yaml` (`environment: sdk` y `flutter`), en `app/README.md` y en `Memoria.md` para que TT-CI-01 use la misma. Sin FVM (herramienta extra no evaluada).
5. **Rama y commits:** `chore/KNOCK-24-flutter-base-project` (convención en inglés; la ficha dice `chore/…`); commits `chore(app): … (KNOCK-24)`.
6. **`analysis_options.yaml`:** se copia `docs/templates/app/analysis_options.yaml` a `app/` (lo indica `docs/templates/README.md`) y el código generado se ajusta hasta pasar `--fatal-infos`. Cierra también el lado frontend de TC-TT-STD-01-04.
7. **E2E de TC-01:** se automatiza con `integration_test` (testing-strategy-frontend: recorrido principal en emulador Android) **y** se adjunta el video.
8. **Trazabilidad de TC-03:** es un caso por comando; `sdd_lint.py --trace` lo marcará FALTA. Se acepta como drift documentado en el PR (con la salida del comando como evidencia) y se propone, en otra tarea, que `sdd_lint.py` admita un marcador «(comando)». **Actualizado el 2026-10-15:** `sdd_lint.py` ya acepta «(comando)» (KNOCK-19) y TC-03 lo lleva en su columna Verificación. `scripts/` es protegido y no se toca aquí. No se agregan referencias falsas a TC-03 en pruebas para engañar al trace.
9. **Nombres:** se sigue la ficha al pie de la letra: `flutter create --org mx.knock --platforms android,ios app` → paquete Dart `app` (imports `package:app/…`), `applicationId`/bundle `mx.knock.app` (dato que necesita TT-FB-01). **Actualizado el 2026-10-15 (revisión del PR):** el identificador es `app.knock.mobile` (`namespace` y `applicationId` de Android, `PRODUCT_BUNDLE_IDENTIFIER` de iOS, incluido RunnerTests, y `MainActivity` en `app/knock/mobile`), porque así quedaron registradas las apps Android e iOS en Firebase (TT-FB-01). El paquete Dart sigue siendo `app`. Carpetas de features en español como la ficha (`inicio`, `explorar`, `actividad`, `trabajo`, `cuenta`); rutas `/inicio`, `/explorar`, `/actividad`, `/trabajo`, `/cuenta`; ruta inicial `/inicio`.
10. **Carpetas vacías:** `domain/` y `data/` de cada feature y `core/{tema,errores,red}` con `.gitkeep`, para que la estructura de 3 capas quede visible y cada historia «solo agregue su carpeta» (objetivo de la ficha).
11. **Textos:** literales en español por ahora; TT-MOB-02 los migra a ARB es/en (fuera de alcance aquí, §3).
12. **Evidencia de V1:** video corto adjunto al PR (no se versiona): arranca con 4 pestañas, activa «Modo técnico (prueba)» en Mi cuenta, aparece Trabajo y recorre las 5.
13. **iOS:** se generan los archivos de iOS sin verificarlos (sin macOS; la ficha solo exige Android). Queda anotado como límite.

## Aprobación
- [x] Revisor 1 — nombre: Erick Trejo Reséndiz fecha: 2026-10-13
- [x] Sin conflicto con la constitución
- **Estados:** Borrador (agente) → Aprobada (persona; habilita el código) → Firmada (tras el merge)
