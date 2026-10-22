# TT-MOB-02 — Tema claro y oscuro con la paleta de la maqueta y archivos de traducción (ARB es/en)

> **Jira:** KNOCK-25 · **Épica:** EP-13 (KNOCK-13) · **Área:** MOB · App móvil base · **Responsable:** Erick Trejo Reséndiz · **Sprint:** S0 (12/10–16/10/2026) · **Puntos:** 2 · **Capas:** Mobile
> **Repositorio:** knock-frontend · **Otra parte en:** — · **Depende de:** TT-MOB-01 (KNOCK-24)
> **Ficha:** TT-MOB-02_TemaClaroOscuroPaleta_Knock.docx (`docs/backlog/TT-MOB-02.md`)
> **Fuentes:** DECISIONES.md #14 («Textos en archivos de traducción desde el día uno… y tema claro/oscuro (Alta). La traducción completa al inglés queda en Media») · FUNCIONES_Y_FLUJOS.md (Mi cuenta → Configuración: «Idioma (Español/English), apariencia (claro/oscuro/automático)») · ficha HU-052 (§8 «Idioma por defecto: español») · maqueta `css/knock.css` y `js/i18n/` (no están en este repositorio)
> **Skills:** story-workflow, flutter-clean-architecture, testing-strategy-frontend, security-core, reuse-before-create
> **Estado:** Borrador

## 1. Objetivo
Que la app nazca con el tema claro y oscuro de la maqueta y con todos sus textos visibles en archivos de traducción (ARB es/en con `gen-l10n`), para que ninguna historia posterior tenga que rehacer pantallas. Terminada cuando (ficha): **cambiar tema e idioma funciona sin reiniciar**. La pantalla de Configuración y el guardado de la preferencia son de HU-052; aquí solo hay un menú de prueba.

## 2. Historia y casos de prueba
**TT-MOB-02** — Tarea técnica (no es historia de usuario). Los criterios V1–V3 de la ficha y la prueba de widget de su paso 6 pasan a casos automatizados; V1 conserva además la evidencia manual (capturas, ficha §10).

| Caso | Criterio (Dado / Cuando / Entonces) | Verificación |
|---|---|---|
| TC-TT-MOB-02-01 | (Ficha V1) Dada la app abierta en una pestaña distinta de Inicio, cuando desde el menú de prueba se cambia el tema (sistema → claro → oscuro) y el idioma (español → inglés → español), entonces el tema (`Theme.of(context).brightness` y el color de fondo) y los textos cambian en el mismo árbol de widgets, **sin** volver a montar la app, y la pestaña seleccionada y la ruta actual se conservan. Además, el estado inicial es tema «sistema» e idioma español. | `app/test/core/preferencias/preferencias_test.dart` → `test('TC-TT-MOB-02-01 estado inicial sistema y español; cambiar tema e idioma actualiza el estado', …)` · `app/test/features/cuenta/menu_de_prueba_test.dart` → `testWidgets('TC-TT-MOB-02-01 cambia tema e idioma sin reiniciar la app', …)` · Manual: emulador Android, capturas en claro, oscuro, español e inglés adjuntas al PR (ficha §10) |
| TC-TT-MOB-02-02 | (Ficha V2) Dado el código de `app/lib/`, entonces ningún widget muestra un texto escrito directo: con la app montada en español y en inglés, y recorriendo las 5 pestañas como técnico, todo texto visible (`Text`, etiquetas de `NavigationDestination`, títulos) es un valor del ARB del idioma activo; y `app_es.arb` y `app_en.arb` tienen exactamente las mismas claves. | `app/test/l10n/textos_desde_arb_test.dart` → `testWidgets('TC-TT-MOB-02-02 todo texto visible sale del ARB del idioma activo', …)` y `test('TC-TT-MOB-02-02 app_es.arb y app_en.arb tienen las mismas claves', …)` · más revisión del PR (ficha) |
| TC-TT-MOB-02-03 | (Ficha V3) Dado el tema claro y el oscuro, entonces cada color que se usa como texto sobre su fondo (incluido el crema `#FBF5E9`) y cada par `onX`/`X` del `ColorScheme` tienen una relación de contraste WCAG 2.x ≥ 4.5:1, calculada con la luminancia relativa `(L1 + 0.05) / (L2 + 0.05)` (§8 decisión 1). | `app/test/core/tema/contraste_test.dart` → `test('TC-TT-MOB-02-03 la fórmula de contraste da 21:1 con blanco y negro y 1:1 con el mismo color', …)` y `test('TC-TT-MOB-02-03 el texto sobre crema cumple al menos 4.5:1', …)` |
| TC-TT-MOB-02-04 | (Ficha, paso 6) Dada la app en español con la barra inferior (Inicio · Explorar · Actividad · Trabajo · Mi cuenta), cuando el idioma cambia a inglés, entonces las etiquetas de las pestañas pasan a los valores de `app_en.arb` (propuesta: Home · Explore · Activity · Work · My account) y ya no aparece ninguna etiqueta en español. | `app/test/core/router/app_shell_l10n_test.dart` → `testWidgets('TC-TT-MOB-02-04 al cambiar el idioma a inglés las pestañas cambian de texto', …)` |

**Por qué TC-TT-MOB-02-04 es un caso aparte de -01:** la ficha pide esa prueba de widget explícitamente (paso 6). TC-01 verifica el cambio en caliente de tema **e** idioma y que no se pierde el estado; TC-04 es la regresión mínima y estable de lo que más se rompe al migrar textos: la barra inferior.

**Sobre V2:** «sin textos escritos directo» no se puede probar exhaustivamente con una sola prueba (un texto podría estar en una pantalla que la prueba no visita). TC-02 cubre todo lo que existe hoy (las 5 pestañas y el menú de prueba) y la revisión del PR cubre el resto; cada historia nueva hereda la prueba agregando su pantalla al recorrido (§8 duda 8).

## 3. Alcance / No-alcance
- **In (este repositorio):**
  - `lib/core/tema/` (carpeta ya creada en TT-MOB-01 con `.gitkeep`; la ficha la llama `core/theme`, §8 duda 7): colores de la maqueta — naranja `#E9682D` (acciones), azul petróleo `#1C3A4C` (apoyo), crema `#FBF5E9` (fondo) y tinta `#231A15` (texto) — y sus equivalentes oscuros (§8 duda 1); `ThemeData` claro y oscuro (Material 3, `ColorScheme` explícito); tipografía de la maqueta (§8 duda 2); función pura de contraste WCAG para TC-03.
  - Fuente empaquetada como asset en `app/assets/fonts/` con su archivo de licencia, declarada en `pubspec.yaml` (`flutter: fonts:`), si la licencia lo permite (§8 duda 2). **Sin** descarga en tiempo de ejecución.
  - Traducciones con `gen-l10n`: `flutter_localizations` (SDK) e `intl` en `pubspec.yaml`, `flutter: generate: true`, `app/l10n.yaml`, `lib/l10n/app_es.arb` (plantilla, idioma fuente) y `lib/l10n/app_en.arb`; idiomas soportados `es` y `en`.
  - Migrar **todos** los literales visibles de TT-MOB-01 a ARB (TT-MOB-01 §8 decisión 11): los 5 títulos de pestaña y de pantalla, «Modo técnico (prueba)» y el título de la app. Claves estables con prefijo, en camelCase porque `gen-l10n` no admite puntos (`tabInicio`, `tabExplorar`, `tabActividad`, `tabTrabajo`, `tabCuenta`…; §8 duda 6).
  - Estado de preferencias en `lib/core/preferencias/`: un `Notifier` de Riverpod con estado inmutable (modo de tema: sistema, claro u oscuro; idioma: `es` o `en`), que lee `KnockApp` (`theme`, `darkTheme`, `themeMode`, `locale`, `supportedLocales`, `localizationsDelegates`, `onGenerateTitle`). Inicia en tema sistema e idioma español. Solo en memoria (§8 duda 5).
  - Menú de prueba en Mi cuenta, junto al interruptor «Modo técnico (prueba)» y con la misma condición `interruptorDePruebaProvider` (`!kReleaseMode`, TT-MOB-01 §8 decisión 1) para elegir tema e idioma (§8 duda 4).
  - Nombre visible de la app «Knock» en Android (`android:label`) e iOS (`CFBundleDisplayName`, `CFBundleName`), hoy «app»/«App» (pendiente anotado en `Memoria.md` por TT-MOB-01; §8 duda 3).
  - Pruebas unitarias y de widget de TC-01 a TC-04; las pruebas de TT-MOB-01 siguen en verde sin cambiar sus aserciones (el idioma inicial es español).
  - `app/README.md` (tema, idiomas, cómo agregar un texto, cómo correr `flutter gen-l10n`) y `Memoria.md` (evaluación de dependencias y decisiones).
- **Out:**
  - Pantalla de Configuración para elegir idioma y tema, y guardar la preferencia en el dispositivo (`shared_preferences`): HU-052 (Sprint 1, KNOCK-49).
  - Respaldo a español de un texto no traducido como comportamiento de producto (HU-052 CA2) y traducción completa de la app al inglés: HU-053 (KNOCK-125, Media). Aquí el inglés solo cubre los textos que existen hoy.
  - Seguir el idioma del teléfono («automático» para idioma): no lo piden la ficha ni FUNCIONES_Y_FLUJOS (solo Español/English).
  - Componentes visuales de las historias (tarjetas, botones con estilo propio, mapa, iconografía de la maqueta) y pruebas doradas: sus historias.
  - Paquete `google_fonts` o cualquier fuente descargada en tiempo de ejecución (§8 duda 2).
  - Red, API, sesión, Firebase y el panel Angular (el tema del panel es de sus historias).
  - Cambiar la estructura del router o la regla de la pestaña Trabajo (TT-MOB-01, Firmada).

## 4. Contratos API y eventos
— Sin endpoints ni eventos. No consume `contracts/openapi.v1.json` ni genera `app/packages/knock_api/`.

## 5. Modelo de datos
- Sin entidades de dominio ni persistencia.
- Estado local (en memoria): `Preferencias` inmutable con `modoTema` (`ThemeMode.system` | `light` | `dark`) e `idioma` (`Locale('es')` | `Locale('en')`), expuesto con `NotifierProvider` en `lib/core/preferencias/`. Valor inicial: `system` y `es` (HU-052 §8: «Idioma por defecto: español»). Se pierde al cerrar la app hasta que HU-052 lo guarde.
- Vive en `core/` porque lo leen `KnockApp` y el menú de prueba de Mi cuenta (una feature no usa internos de otra, AGENTS.md §4) y porque HU-052 lo reutilizará.

## 6. Seguridad, privacidad y amenazas
Riesgo bajo: cambio de estilo y textos, sin red, sin sesión, sin datos personales. STRIDE breve sobre lo que sí introduce:

| Amenaza | Control | Caso que lo prueba |
|---|---|---|
| Fuga de información / privacidad: una fuente descargada en tiempo de ejecución (p. ej. `google_fonts`) manda la IP y el uso de la app a un tercero y abre una dependencia de red | La fuente se empaqueta como asset; no se agrega `google_fonts` ni otro paquete de red; las pruebas corren sin red (testing-strategy-frontend) | TC-TT-MOB-02-02 y TC-TT-MOB-02-03 corren con `flutter test` sin red · revisión de `security-reviewer` (check 14) |
| Cadena de suministro: `flutter_localizations`, `intl` o la fuente agregados sin evaluar, con versión abierta o con una licencia que no permite redistribuir la fuente | Evaluación de necesidad, licencia, mantenimiento y avisos (OSV, ecosistema Pub) registrada en `Memoria.md` y en el PR; `intl` ya está en `pubspec.lock` como transitiva (0.20.3) y se fija a la versión que exige `flutter_localizations`; archivo de licencia de la fuente versionado junto a ella | (comando) `flutter pub get` + `flutter pub deps` en el PR · TC-TT-CI-01-02 / TC-TT-CI-01-03 (OSV-Scanner) · `security-reviewer` (check 14) |
| Elevación (solo de interfaz): el menú de prueba de tema e idioma llega a una compilación de tienda | Misma condición que el interruptor de técnico: `interruptorDePruebaProvider` (`!kReleaseMode`); en release Mi cuenta no muestra el menú | `app/test/features/cuenta/menu_de_prueba_test.dart` → `testWidgets('TC-TT-MOB-02-01 sin modo de prueba (release) Mi cuenta no muestra el menú de tema e idioma', …)` |
| Accesibilidad como riesgo de producto: texto ilegible en claro u oscuro (el naranja de la maqueta sobre crema da 2.98:1 y el blanco sobre naranja 3.24:1, ambos < 4.5:1) | Contraste calculado en prueba unitaria para los pares de texto; el naranja no se usa como color de texto normal sobre crema y `onPrimary` es tinta (§8 duda 1) | TC-TT-MOB-02-03 |
| Fuga de datos personales en ARB, fixtures o prompts de IA | Los ARB solo tienen textos de interfaz; pruebas sin datos reales; nada de datos personales a la IA (ficha §8) | Revisión del diff (`security-reviewer`, checks 7 y 16) |

## 7. Pantallas
- **App (`KnockApp`):** `MaterialApp.router` con `theme` (claro), `darkTheme` (oscuro), `themeMode`, `locale` y delegados de `gen-l10n` leídos de las preferencias; `onGenerateTitle` con la clave del ARB (`appTitle` = «Knock» en ambos idiomas).
- **Barra inferior y pantallas de las 5 pestañas:** iguales a TT-MOB-01, con etiquetas y títulos desde el ARB y colores del tema.
- **Mi cuenta — menú de prueba** (solo fuera de release, §8 duda 4): debajo de «Modo técnico (prueba)», un selector «Tema (prueba)» con Sistema · Claro · Oscuro y un selector «Idioma (prueba)» con Español · English (p. ej. `SegmentedButton` o `RadioListTile`; lo decide quien implementa con la skill). Todos sus textos en ARB.
- **Estados (cargando, vacío, error, datos):** no aplican: no hay datos ni llamadas.
- **Textos (ARB es → en, propuesta):** `appTitle` Knock → Knock · `tabInicio` Inicio → Home · `tabExplorar` Explorar → Explore · `tabActividad` Actividad → Activity · `tabTrabajo` Trabajo → Work · `tabCuenta` Mi cuenta → My account · `pruebaModoTecnico` Modo técnico (prueba) → Technician mode (test) · `pruebaTema`, `pruebaTemaSistema`, `pruebaTemaClaro`, `pruebaTemaOscuro`, `pruebaIdioma`, `pruebaIdiomaEspanol`, `pruebaIdiomaIngles`. Cada clave de `app_es.arb` con `@clave.description` para quien traduzca. Los nombres de idioma se muestran en su propio idioma («Español», «English») en ambos ARB.
- **Accesibilidad:** contraste ≥ 4.5:1 en texto (TC-03); las etiquetas de la barra cambian de idioma, así que el lector de pantalla también; se mantienen `meetsGuideline` de TT-MOB-01 y se agrega `textContrastGuideline` en la prueba de TC-04 en claro y oscuro (§8, plan de pruebas). Texto escalable: los tamaños del `TextTheme` no fijan `textScaler`.

## 8. Pruebas, gates y límites
**Plan de pruebas** (meta de mutación: N/A, `domain/` vacío; ver fila MUT):

| Tipo | ¿Aplica? | Motivo / herramienta |
|---|---|---|
| Unitarias (UM) | Sí | Notifier de preferencias (estado inicial y cambios, TC-01) y función de contraste (TC-03) en `app/test/core/`; Dart puro, sin red |
| Widget (W) | Sí | TC-01 (cambio en caliente, menú de prueba y caso release), TC-02 (textos desde ARB) y TC-04 (pestañas en inglés) con `ProviderScope`/`UncontrolledProviderScope` y overrides, como en TT-MOB-01 |
| Aceptación (ACC) | Sí | Cada caso con su ID en el nombre de la prueba |
| Contrato (CON) | No | No consume la API |
| E2E | No | El recorrido en emulador ya lo cubre TC-TT-MOB-01-01 (sigue en español); el cambio en caliente se verifica en widget (TC-01) y a mano en el emulador con capturas (ficha §10). Agregar un `integration_test` aquí duplicaría TC-01 sin cubrir nada nuevo |
| Accesibilidad (A11Y) | Sí | Contraste por cálculo (TC-03) y `meetsGuideline(textContrastGuideline)` en el árbol montado, en claro y oscuro, dentro del archivo de TC-04 |
| Compatibilidad | Parcial | Android en emulador (capturas). iOS: se cambia `Info.plist` sin compilar (sin macOS), como en TT-MOB-01 |
| Mutación (MUT) | No | Sin `domain/`; la función de contraste se protege con valores conocidos (21:1 y 1:1) además del umbral |
| Regresión visual (doradas) | No | Aún no hay componentes con diseño propio; las doradas llegan con las historias de pantallas. Las capturas del PR son la evidencia visual |
| Usabilidad (USA) | No | Menú de prueba temporal; la pantalla real es HU-052 |

**Cobertura:** app ≥ 50 % líneas (`flutter test --coverage`).
**Gates:** `AGENTS.md §5` (App): `dart format --set-exit-if-changed lib test` sin cambios, `flutter analyze --fatal-infos` limpio, `flutter test` verde (incluidas las pruebas de TT-MOB-01), cobertura ≥ 50 %; `sdd_lint.py`, `sdd_lint.py --trace TT-MOB-02`, `codemap.py --check`, `check_exceptions.py`, `sync_agents.py --check` en OK; `security-reviewer` LIBERA; `Memoria.md` al día; «Uso de IA» en el PR.

**Dependencias nuevas (evaluación pendiente; la registra quien implemente en `Memoria.md` y en el PR, constitución: «No se agregan dependencias sin evaluar»):**
- `flutter_localizations` (SDK de Flutter, BSD-3). Necesidad: delegados de Material/Cupertino/Widgets en es y en, requeridos por `gen-l10n`. Ya aparece como transitiva en `pubspec.lock` (vía `go_router`).
- `intl` (pub.dev, Dart team, BSD-3). Necesidad: código que genera `gen-l10n` (plurales, fechas). Ya aparece como transitiva (0.20.3); `flutter_localizations` fija su versión, así que la restricción debe ser compatible con la del SDK de Flutter 3.47.7 (la que deje `flutter pub add intl` sin conflicto). Revisar avisos en OSV.
- **Fuente:** archivo(s) `.ttf` empaquetados (no es un paquete de pub). Evaluar licencia (redistribución en una app comercial), origen del archivo y peso (solo los pesos que se usen). **No** `google_fonts` (descarga por red en tiempo de ejecución, contradice la regla «sin red en pruebas» y manda tráfico a un tercero).

**Decisiones (resueltas por el revisor José Julián Hernández Hernández el 2026-10-19 en el PR #16, con datos de la maqueta `maqueta-knock/css/knock.css`):**
1. **Paleta y roles de color. Resuelto: se usan las variables de la maqueta**, que sí define modo oscuro (`[data-theme="dark"]`). V3 (TC-03) se extiende a **todos los pares `onX`/`X`** del `ColorScheme` claro y oscuro.
   - Claro: `--ink:#231A15`, `--ink2:#4A3C33`, `--mut:#6B5D52`, `--amber:#E9682D`, `--amber-ink:#8F3510` (naranja **de texto** sobre crema; reemplaza a la propuesta `#B84A17`), `--navy:#1C3A4C`, `--surface:#FFFFFF`, `--surface2:#FBF5E9` (crema).
   - Oscuro: `--bg:#14110F`, `--stage:#0E0C0A`, `--surface:#1E1B18`, `--surface2:#26211D`, `--line:#3A332D`, `--line2:#302A25`, `--ink:#F6EEE3`, `--ink2:#DCD0C2`, `--mut:#B5A798`, `--navy:#8FC4D6`, `--navybg:#2A5568`, `--navy-soft:#1D3440`. La maqueta no redefine `--amber` en oscuro: se usa `#E9682D`.
   - Contrastes recalculados (WCAG 2.x, 2026-10-20). **Pasan:** claro, sobre crema y blanco: `ink` 15.72 y 17.07, `ink2` 9.74 y 10.58, `mut` 5.84 y 6.34, `amber-ink` 7.20 y 7.82, `navy` 10.99 y 11.94; `ink` sobre `amber` 5.27; blanco o crema sobre `navy` 11.94 y 10.99. Oscuro, sobre `bg`/`stage`/`surface`/`surface2`: `ink` ≥ 13.86, `ink2` ≥ 10.51, `mut` ≥ 6.79, `navy` ≥ 8.37, `amber` ≥ 4.92; `bg` sobre `amber` 5.80 y sobre `navy` 9.88; `ink` sobre `navybg` 7.03 e `ink2` sobre `navybg` 5.33.
   - **No pasan (< 4.5:1), reportados y no ajustados:** claro: `amber` como texto sobre crema **2.98** y sobre blanco **3.24**; blanco sobre `amber` **3.24**. Oscuro: `mut` sobre `navybg` **3.44**, `navy` sobre `navybg` **4.25**, `amber` sobre `navybg` **2.50** y `amber` sobre `navy-soft` **4.01**.
   - **Regla (decisión del líder, 2026-10-21): esos pares no se usan para texto ni para botones.** La spec se firma con la paleta de la maqueta tal cual; el ajuste de contraste de los tokens, sin salir de la identidad visual, es una tarea aparte para el Sprint 3 o 4. Riesgo de accesibilidad conocido, anotado en `Memoria.md`.
   - Asignación de roles, para no usar esos pares: claro `primary` = `amber` con `onPrimary` = `ink`; texto naranja = `amber-ink`; `secondary` = `navy` con `onSecondary` = `surface`. Oscuro `primary` = `amber` con `onPrimary` = `bg`; `secondary` = `navy` con `onSecondary` = `bg`; `secondaryContainer` = `navybg` con `onSecondaryContainer` = `ink`. Sobre `navybg` y `navy-soft` solo `ink` o `ink2` (y `ink` sobre `navy-soft`).
2. **Fuente. Resuelto: Nunito** (la que declara la maqueta), si su `OFL.txt` oficial confirma la licencia SIL OFL. Se empaquetan los `.ttf` oficiales (Flutter no usa `.woff2`) de los pesos 400, 500, 600 y 700 con su `OFL.txt` en `app/assets/fonts/nunito/`, y la evaluación se registra en `Memoria.md`. Si la licencia no lo permite, Inter (OFL). Nunca `google_fonts` en ejecución.
3. **Nombre visible «Knock». Resuelto: sí, en esta tarea**, con captura del lanzador en el PR (`android:label`, `CFBundleDisplayName`, `CFBundleName` y `onGenerateTitle` desde el ARB).
4. **Menú de prueba. Resuelto:** en Mi cuenta, debajo de «Modo técnico (prueba)», con la misma condición `!kReleaseMode` (`interruptorDePruebaProvider`) y con la prueba del caso release.
5. **Persistencia. Resuelto: solo en memoria**; el guardado es de HU-052.
6. **Claves ARB. Resuelto: camelCase con prefijo** (`tabInicio`, `tabExplorar`, `tabActividad`, `tabTrabajo`, `tabCuenta`, `prueba…`, `appTitle`).
7. **Carpeta. Resuelto: `lib/core/tema/`**, y se borra su `.gitkeep`.
8. **`gen-l10n`. Resuelto:** se acepta la configuración propuesta (`arb-dir: lib/l10n`, `template-arb-file: app_es.arb`, `output-dir: lib/l10n/generado`, `output-class: AppLocalizations`, `nullable-getter: false`). Los `.dart` generados **se versionan** y no se editan a mano. V2 se garantiza con `textos_desde_arb_test.dart` más la revisión del PR; sin `custom_lint` por ahora. La comprobación de «generados al día» en el CI la agrega el revisor (`.github/`).
9. **Rama. Resuelto:** `chore/KNOCK-25-theme-and-languages`, con PR a `sprint-01` (rebase hecho el 2026-10-20).
10. **TC-01. Resuelto:** la prueba de widget corre en cada PR y las capturas en emulador (claro, oscuro, español, inglés) son la evidencia de la ficha §10.

## Aprobación
- [ ] Revisor 1 — nombre: ________ fecha: ________
- [ ] Sin conflicto con la constitución
- **Estados:** Borrador (agente) → Aprobada (persona; habilita el código) → Firmada (tras el merge)
