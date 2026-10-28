# HU-052 — Elegir idioma y tema en Configuración

> **Jira:** KNOCK-49 · **Épica:** EP-10 Mi cuenta y avisos · **Módulo:** Identity (app) · **Responsable:** Erick Trejo Reséndiz · **Sprint:** S2 (la ficha dice Sprint 1; se movió al Sprint 2) · **Puntos:** 1 · **Capas:** Mobile
> **Repositorio:** knock-frontend · **Otra parte en:** — (sin API ni base de datos: la ficha marca Back y BD como «No aplica»)
> **Rama:** `feature/KNOCK-49-language-and-theme-settings` → PR a `sprint-02` (la ficha cita `feature/KNOCK-49-idioma-y-tema` → `sprint-01`; la rama real es la de este encabezado)
> **Depende de:** TT-MOB-02 (KNOCK-25, spec Aprobada el 2026-10-22, **PR #16 aún sin fusionar en `sprint-02`**). **La implementación empieza cuando el PR #16 esté fusionado** y esta rama se haya rebasado sobre `sprint-02`; hasta entonces solo se trabaja la spec.
> **Fuentes:** ficha `docs/backlog/HU-052.md` · spec de TT-MOB-02 (`specs/TT-MOB-02-tema-claro-oscuro-y-traducciones-arb/spec.md` en `origin/chore/KNOCK-25-theme-and-languages`, §3, §5 y §8 decisiones 1, 4, 5, 6 y 8) y su código (`app/lib/core/preferencias/preferencias_provider.dart`, `app/lib/features/cuenta/presentation/widgets/menu_de_prueba.dart`, `app/lib/core/tema/`, `app/lib/l10n/*.arb`, `app/l10n.yaml`) · DECISIONES.md #14 y §7 («Un idioma guardado que ya no exista vuelve al español») · FUNCIONES_Y_FLUJOS.md (Mi cuenta → Configuración: «Idioma (Español/English), apariencia (claro/oscuro/automático)») · `.specify/memory/constitution.md` 2.2.1 (tokens solo en almacenamiento seguro; dependencias evaluadas; accesibilidad 48 dp) · `AGENTS.md` §§0, 4, 5 y 7
> **Skills:** spec-first-writing, story-workflow, flutter-clean-architecture, testing-strategy-frontend, security-core, reuse-before-create, traceability
> **Estado:** Borrador

**Cómo leer esta spec.** HU-052 es la segunda mitad de TT-MOB-02: allí quedaron el tema claro y oscuro, los ARB es/en, el proveedor de preferencias **solo en memoria** (§8 decisión 5: «el guardado es de HU-052») y un menú de prueba en Mi cuenta (solo fuera de release, decisión 4). Esta historia **no rehace nada de eso**: agrega la pantalla real de **Configuración**, le da al proveedor existente **carga y guardado** en el dispositivo con `shared_preferences` y retira del menú de prueba los selectores de tema e idioma. Lo que no está decidido queda como duda numerada con recomendación (§8).

## 1. Objetivo
Que la persona usuaria elija en **Mi cuenta → Configuración** el idioma (Español, English) y el tema (Automático, Claro, Oscuro), vea el cambio al momento en toda la app sin reiniciarla, y que la elección **se conserve** al cerrar y abrir la app. El idioma por defecto es español y el tema por defecto, Automático (sigue al teléfono). Todo texto sale de los ARB; si a un texto le falta la traducción al inglés, se muestra en español.

**Terminada cuando:** los casos TC-HU-052-01 a 05 (criterios CA1–CA5 de la ficha) y los casos de seguridad, robustez y accesibilidad 06 a 10 tienen su prueba en verde en el CI, y los casos 11 y 12 tienen su salida de comando en el PR.

**Qué ya existe** (leído en `origin/chore/KNOCK-25-theme-and-languages`; en `sprint-02` todavía no está; `python scripts/codemap.py --query "preferencias configuracion"` en esta rama: sin coincidencias, porque TT-MOB-02 no está fusionada):
- `core/preferencias/preferencias_provider.dart`: `Preferencias` inmutable (`modoTema`, `idioma`), `Preferencias.inicial` (sistema + español), `PreferenciasNotifier` con `cambiarTema` y `cambiarIdioma` (rechaza idiomas fuera de `idiomasSoportados = [es, en]`) y `preferenciasProvider`. **Se reutiliza y se extiende; no se crea otro proveedor.**
- `app.dart` (`KnockApp`): ya lee `themeMode` y `locale` del proveedor; con `theme`/`darkTheme` de `core/tema/tema.dart`.
- `features/cuenta/presentation/cuenta_screen.dart` y `widgets/menu_de_prueba.dart`: interruptor «Modo técnico (prueba)» y selectores de tema e idioma de prueba con `RadioGroup` + `RadioListTile`, mostrados solo si `interruptorDePruebaProvider` (`!kReleaseMode`).
- `l10n.yaml` con `template-arb-file: app_es.arb` (español es el idioma fuente) y `nullable-getter: false`; claves camelCase con prefijo; `.dart` generados versionados y comprobados en el CI (TT-CI-04).
- Pruebas de TT-MOB-02 que tocan lo mismo: `test/core/preferencias/preferencias_test.dart`, `test/features/cuenta/menu_de_prueba_test.dart`, `test/l10n/textos_desde_arb_test.dart` y el arnés `test/soporte/montar_app.dart`.

## 2. Historia y casos de prueba
**HU-052** — Como usuario, quiero elegir el idioma y el tema de la app, para usarla como me resulte más cómoda.

**Datos de prueba.** Ninguno personal: solo valores de preferencia (`es`/`en`, `automatico`/`claro`/`oscuro`). El almacenamiento se simula con `SharedPreferences.setMockInitialValues` (sin disco ni red) y el tema del teléfono con `tester.platformDispatcher.platformBrightnessTestValue`. Las pruebas se nombran con el caso: `testWidgets('TC-HU-052-01 …')` / `test('TC-HU-052-06 …')`.

| Caso | Criterio (Dado / Cuando / Entonces) | Verificación |
|---|---|---|
| TC-HU-052-01 | (CA1) Dado que estoy en Configuración con la app en español, cuando elijo **English**, entonces el título, las opciones y las pestañas de la barra pasan al texto de `app_en.arb` en el mismo árbol (el elemento de `KnockApp` y el estado del `Router` son los mismos: **sin reiniciar**), sigo en `/cuenta/configuracion` con Mi cuenta seleccionada, y al elegir **Español** vuelve al español. | `app/test/features/cuenta/configuracion_screen_test.dart` → `testWidgets('TC-HU-052-01 al elegir English la app cambia de idioma sin reiniciar', …)` |
| TC-HU-052-02 | (CA2) Dado un texto que no tiene traducción al inglés, cuando la app está en inglés, entonces ese texto se muestra **en español** (respaldo) y no vacío ni con la clave. Se prueba en dos niveles: (a) con un par de ARB de prueba (`es` con 2 claves, `en` con 1) que se generan con la misma configuración de `l10n.yaml`, la clase inglesa devuelve el texto español de la clave que falta; (b) un idioma guardado o pedido que la app no soporta (`fr`, `pt`) se resuelve a español. Los ARB reales siguen con las mismas claves (TC-TT-MOB-02-02 no cambia). | `app/test/l10n/respaldo_espanol_test.dart` → `test('TC-HU-052-02 una clave sin traducción al inglés se muestra en español', …)` y `test('TC-HU-052-02 un idioma no soportado se resuelve a español', …)` (§8 duda 3) |
| TC-HU-052-03 | (CA3) Dado que elijo **Oscuro** en Configuración, cuando vuelvo a Mi cuenta y recorro las 5 pestañas (como técnico) y regreso a Configuración, entonces en cada pantalla `Theme.of(context).brightness` es `dark` y el fondo es `ColoresOscuro.bg` (tema oscuro de la maqueta, TT-MOB-02 §8 decisión 1), aunque el teléfono esté en claro. | `…/configuracion_screen_test.dart` → `testWidgets('TC-HU-052-03 con Oscuro todas las pantallas usan el tema oscuro de la maqueta', …)` |
| TC-HU-052-04 | (CA4) Dado que elijo **Automático** (`ThemeMode.system`) y el teléfono está en claro, cuando el teléfono cambia a oscuro y luego otra vez a claro, entonces la app cambia de tema sola, sin tocar nada; y como control negativo, con **Claro** elegido el cambio del teléfono a oscuro **no** cambia la app. | `…/configuracion_screen_test.dart` → `testWidgets('TC-HU-052-04 con Automático la app sigue el tema del teléfono', …)` y `testWidgets('TC-HU-052-04 con Claro la app ignora el tema del teléfono', …)` |
| TC-HU-052-05 | (CA5) Dado que elegí English y Oscuro, cuando la app se cierra y se vuelve a abrir (contenedor nuevo y `KnockApp` montada desde cero con los valores que quedaron guardados), entonces **desde el primer cuadro** (primer `pump`, sin `pumpAndSettle`) se ve en inglés y en oscuro, sin pasar por español ni claro (sin parpadeo); y sin nada guardado arranca en español y Automático. | `app/test/core/preferencias/arranque_test.dart` → `testWidgets('TC-HU-052-05 se conservan idioma y tema al reiniciar desde el primer cuadro', …)` y `test('TC-HU-052-05 sin preferencias guardadas arranca en español y Automático', …)` · `app/integration_test/configuracion_test.dart` → `testWidgets('TC-HU-052-05 guarda idioma y tema en el dispositivo', …)` (emulador, plugin real) · Manual: video o capturas en el emulador cerrando la app (deslizar) y abriéndola, en el PR |
| TC-HU-052-06 | (Seguridad, privacidad) Dado cualquier cambio de idioma y tema, entonces lo guardado en `shared_preferences` son **exactamente dos claves**, `knock.preferencias.tema` y `knock.preferencias.idioma`, con valores de los conjuntos `{automatico, claro, oscuro}` y `{es, en}` (`getKeys()` no tiene nada más: ni tokens, ni teléfono, ni nombre, ni rol de técnico); y en `app/lib/` **solo** `core/preferencias/` importa `package:shared_preferences`. | `app/test/core/preferencias/almacen_preferencias_test.dart` → `test('TC-HU-052-06 solo se guardan tema e idioma con valores permitidos', …)` · `app/test/core/preferencias/arquitectura_preferencias_test.dart` → `test('TC-HU-052-06 solo core/preferencias importa shared_preferences', …)` |
| TC-HU-052-07 | (Negativa, ficha NEG) Dado un valor guardado inválido o corrupto —idioma que ya no existe (`fr`), vacío, con mayúsculas o región (`EN`, `en_US`), tema desconocido (`sepia`), o un tipo distinto (entero, booleano, lista)—, cuando la app arranca, entonces usa el valor por defecto de **esa** preferencia (español o Automático) y conserva la otra si es válida, sin excepción ni pantalla de error, y la lectura no reescribe lo guardado. | `…/almacen_preferencias_test.dart` → `test('TC-HU-052-07 un valor guardado inválido vuelve al valor por defecto', …)` (tabla de valores) |
| TC-HU-052-08 | (Robustez) Dado que el almacenamiento falla —al leer en el arranque (`getInstance` lanza) o al guardar (`setString` lanza o devuelve `false`)—, entonces la app abre con los valores por defecto o cambia de tema e idioma en pantalla igual (el cambio en memoria no depende del guardado), sin excepción no atrapada, sin mensaje técnico y sin registrar nada en logs. | `…/almacen_preferencias_test.dart` → `test('TC-HU-052-08 si falla guardar el cambio se aplica igual en pantalla', …)` · `…/arranque_test.dart` → `test('TC-HU-052-08 si falla leer al arrancar se usan los valores por defecto', …)` |
| TC-HU-052-09 | (Acceso y menú de prueba) Dada la app **en release** (`interruptorDePruebaProvider` = falso), cuando abro Mi cuenta, entonces veo la entrada **Configuración** y al tocarla llego a `/cuenta/configuracion` dentro de la barra inferior con Mi cuenta seleccionada y puedo regresar con el botón Atrás; no veo «Modo técnico (prueba)». Fuera de release, Mi cuenta muestra además «Modo técnico (prueba)», y **ya no** hay selectores de tema ni idioma en el menú de prueba (solo existen en Configuración). | `app/test/features/cuenta/cuenta_screen_test.dart` → `testWidgets('TC-HU-052-09 en release Mi cuenta muestra Configuración y no el modo técnico', …)` y `testWidgets('TC-HU-052-09 fuera de release el menú de prueba solo tiene el modo técnico', …)` · `app/test/core/router/rutas_configuracion_test.dart` → `testWidgets('TC-HU-052-09 la ruta de Configuración cuelga de Mi cuenta', …)` |
| TC-HU-052-10 | (Accesibilidad) Dada Configuración en claro y en oscuro, entonces cada opción es un radio con semántica de grupo excluyente y estado marcado (`isInMutuallyExclusiveGroup`, `isChecked`) y su texto como etiqueta, los títulos «Idioma» y «Tema» son encabezados, cumple `androidTapTargetGuideline`, `labeledTapTargetGuideline` y `textContrastGuideline` (≥ 4.5:1) en ambos temas, y con el texto al **200 %** en una pantalla angosta no hay desbordes ni excepciones. | `…/configuracion_screen_test.dart` → `testWidgets('TC-HU-052-10 los selectores tienen semántica de radio y cumplen las guías', …)` y `testWidgets('TC-HU-052-10 soporta texto al 200 % sin desbordes', …)` |
| TC-HU-052-11 | (Cadena de suministro) Dado el trabajo terminado, entonces `app/pubspec.yaml` solo agrega `shared_preferences` (restricción `^`, versión exacta en `pubspec.lock`), su evaluación (necesidad, licencia, editor, mantenimiento y avisos en OSV) está en `Memoria.md` y en el PR, y el job de SCA (OSV-Scanner) del CI pasa sin hallazgos altos. | (comando) `git diff origin/sprint-02 -- app/pubspec.yaml` · `cd app && flutter pub deps --style=compact \| grep shared_preferences` · resultado de OSV-Scanner del CI; salida en el PR |
| TC-HU-052-12 | Dado el trabajo terminado, entonces formato, análisis, generados de `gen-l10n` al día y pruebas de la app pasan sin cambios ni avisos, con cobertura ≥ 50 %, y las pruebas de TT-MOB-01, TT-MOB-02 y TT-PRU-02 siguen en verde. | (comando) `cd app && dart format --set-exit-if-changed lib test && flutter analyze --fatal-infos && flutter gen-l10n && git status --porcelain lib/l10n/generado && flutter test --coverage`; salida en el PR |

**Por qué hay casos más allá de CA1–CA5.** La ficha pide prueba negativa («idioma guardado que ya no existe → español», TC-07) y accesibilidad (TC-10). TC-06 sale de la constitución (los tokens y los datos personales nunca van a `SharedPreferences`): lo que se guarda tiene que poder comprobarse. TC-08 cubre el único efecto nuevo con riesgo de cierre inesperado (el disco). TC-09 fija qué pasa con el menú de prueba de TT-MOB-02.

## 3. Alcance / No-alcance
- **In (este repositorio, `app/`):**
  - **Guardado y carga** de las dos preferencias en `core/preferencias/`, extendiendo el proveedor de TT-MOB-02 (no se crea otro): una interfaz `AlmacenPreferencias` (leer tema, leer idioma, guardar tema, guardar idioma) con dos implementaciones, la de `shared_preferences` y una en memoria (respaldo si el almacenamiento no está disponible al arrancar, §8 duda 5); `PreferenciasNotifier.build()` lee lo guardado **de forma síncrona** y `cambiarTema` / `cambiarIdioma` actualizan el estado y luego guardan.
  - Conversión estricta entre lo guardado y el dominio: `automatico|claro|oscuro` ↔ `ThemeMode.system|light|dark` y `es|en` ↔ `Locale('es'|'en')`; cualquier otro valor o tipo → valor por defecto de esa preferencia (TC-07).
  - **Arranque** en `main.dart`: `WidgetsFlutterBinding.ensureInitialized()`, `SharedPreferences.getInstance()` antes de `runApp` (detrás de la pantalla de arranque nativa) y `ProviderScope` con el almacén ya listo; si falla, se arranca con el almacén en memoria (§8 duda 4). La lógica va en una función pequeña y probable (p. ej. `crearAlmacenDeArranque()` en `core/preferencias/`), para que `main()` solo la llame.
  - **Pantalla Configuración** `features/cuenta/presentation/configuracion_screen.dart` (Mi cuenta → Configuración), con dos grupos de radio: Idioma (Español · English) y Tema (Automático · Claro · Oscuro). Reutiliza `PantallaTitulada` y el patrón `RadioGroup` + `RadioListTile` del menú de prueba (se mueve, no se copia).
  - **Ruta** `Rutas.configuracion = '/cuenta/configuracion'`, subruta de la rama Mi cuenta (igual que `/explorar/oficios`), y una entrada «Configuración» en Mi cuenta visible en todas las compilaciones.
  - **Menú de prueba:** se le quitan los selectores de tema e idioma; queda solo «Modo técnico (prueba)», con la misma condición `interruptorDePruebaProvider` (`!kReleaseMode`) hasta que la sesión real dé el rol (TT-MOB-01 §8 decisión 1).
  - **ARB es/en:** claves nuevas `configuracion…` (§7) y se retiran `pruebaTema`, `pruebaTemaSistema`, `pruebaTemaClaro`, `pruebaTemaOscuro`, `pruebaIdioma`, `pruebaIdiomaEspanol` y `pruebaIdiomaIngles`; se regeneran los `.dart` con `flutter gen-l10n` (no se editan a mano).
  - **Ajuste declarado de pruebas de TT-MOB-02** que usan el menú de prueba (§8 duda 2): llegar a los selectores por Configuración en lugar de Mi cuenta y cambiar las claves `prueba…` por `configuracion…`, **sin cambiar lo que afirman** ni sus IDs.
  - Dependencia nueva `shared_preferences` con su evaluación (§8 duda 1).
  - Pruebas de §2, `Memoria.md` y `docs/architecture/` regenerado con `scripts/codemap.py`.
- **Out:**
  - **Traducción completa al inglés** (HU-053, KNOCK-125, Media): aquí solo se traducen los textos nuevos de Configuración.
  - **Seguir el idioma del teléfono** («automático» para el idioma) y elegir el idioma inicial según el dispositivo: la ficha fija español por defecto (DECISIONES §7 lo menciona como idea «para el producto real»; §8 duda 6).
  - **Sincronizar la preferencia con la cuenta en el servidor** o entre dispositivos: la ficha dice «en el dispositivo»; no hay endpoint.
  - **«Qué avisos recibir»** (también está en Configuración según FUNCIONES_Y_FLUJOS): historia de avisos.
  - El resto de Mi cuenta (Mis datos, Privacidad, Ayuda, Legal…), sesión, tokens, Firebase y la API.
  - Cambiar la paleta, los contrastes reportados en TT-MOB-02 §8 decisión 1 (tarea aparte del Sprint 3 o 4), la tipografía o la configuración de `gen-l10n`.
  - Panel Angular.
  - Retirar el interruptor «Modo técnico (prueba)» (llega con la sesión real).

## 4. Contratos API y eventos
— Sin endpoints ni eventos: la preferencia vive solo en el dispositivo. No consume `contracts/openapi.v1.json` ni toca `app/packages/knock_api/`.

## 5. Modelo de datos
- **Estado (en memoria, ya existe):** `Preferencias { modoTema: ThemeMode, idioma: Locale }`, inmutable, en `preferenciasProvider`. Valor por defecto `Preferencias.inicial` = `ThemeMode.system` + `Locale('es')` (no cambia).
- **Guardado en el dispositivo (nuevo):** `shared_preferences` (en Android, `SharedPreferences` XML privado de la app; en iOS, `NSUserDefaults`), **sin cifrar** porque no es un dato sensible.

  | Clave | Tipo | Valores permitidos | Por defecto (ausente o inválido) |
  |---|---|---|---|
  | `knock.preferencias.tema` | `String` | `automatico`, `claro`, `oscuro` | `automatico` (`ThemeMode.system`) |
  | `knock.preferencias.idioma` | `String` | `es`, `en` (código de idioma, sin región) | `es` |

  - Prefijo `knock.preferencias.` para no chocar con claves de otros paquetes (el plugin agrega además su propio prefijo interno `flutter.` en el API clásico).
  - Los valores guardados son **nombres propios de Knock**, no `ThemeMode.name` ni `Locale.toString()`, para que un cambio de Flutter no invalide lo guardado.
  - Nada más se guarda ahí: ni tokens (van en `flutter_secure_storage`, constitución y `security-core` check 10), ni datos de la cuenta, ni el indicador de técnico (sigue en memoria).
  - Sin migración: es la primera versión que guarda; si una versión futura cambia el formato, lee el valor y, si no lo reconoce, usa el por defecto (TC-07).
- **Lectura:** una sola vez al construir el proveedor, de la caché en memoria que `SharedPreferences.getInstance()` ya cargó en el arranque (síncrona). **Escritura:** después de cambiar el estado, sin esperar ni bloquear la interfaz; un error al guardar se ignora sin registrar nada (§8 duda 5).

## 6. Seguridad, privacidad y amenazas
Riesgo bajo: preferencia de interfaz, sin red, sin sesión ni datos personales. Lo nuevo es escribir en el disco del teléfono y una dependencia.

| Amenaza | Control | Caso que lo prueba |
|---|---|---|
| **Fuga (I):** que alguien use el mismo almacenamiento para guardar un token, el teléfono o un dato de la cuenta (`SharedPreferences` no está cifrado y entra en respaldos del sistema) | Solo `core/preferencias/` importa `shared_preferences`; solo se escriben dos claves fijas con valores de un conjunto cerrado; los tokens siguen la regla de la constitución (almacenamiento seguro) | TC-HU-052-06 |
| **Alteración (T) / denegación local (D):** un valor guardado manipulado (dispositivo con root, respaldo restaurado de otra versión) o corrupto hace que la app falle al abrir | Lectura con comprobación de tipo y lista permitida; ante cualquier otro valor se usa el por defecto; la lectura no lanza ni reescribe | TC-HU-052-07 |
| **Denegación local (D):** el almacenamiento no está disponible (falla el plugin al arrancar o al escribir) y la app no abre o se cierra | Respaldo en memoria al arrancar; el guardado no bloquea ni propaga errores; el cambio en pantalla no depende del guardado | TC-HU-052-08 |
| **Elevación (solo de interfaz, E):** el interruptor «Modo técnico (prueba)» llega a la compilación de tienda al rehacer Mi cuenta | Misma condición `interruptorDePruebaProvider` (`!kReleaseMode`); prueba del caso release | TC-HU-052-09 |
| **Fuga (I):** detalles técnicos o valores en logs al fallar el almacenamiento | Sin `print`/`debugPrint` ni Sentry con la excepción; sin mensaje al usuario (no hay nada que pueda hacer) | TC-HU-052-08 |
| **Cadena de suministro:** `shared_preferences` y sus implementaciones por plataforma (`shared_preferences_android`, `_foundation`, `_web`, `_linux`, `_windows`, `_platform_interface`) sin evaluar o con avisos | Evaluación registrada (licencia, editor `flutter.dev`, mantenimiento, OSV); restricción `^` y versión exacta en `pubspec.lock`; OSV-Scanner en el CI | TC-HU-052-11 |
| **Accesibilidad como riesgo de producto:** selectores que el lector de pantalla no anuncia como opciones, áreas pequeñas o contraste insuficiente en algún tema | Radios con semántica de grupo, encabezados, 48 dp, `textContrastGuideline` en claro y oscuro, texto al 200 % | TC-HU-052-10 |

No aplican: autenticación, autorización por recurso, datos sensibles o biométricos, archivos, límites de API, IA (check 16: la historia no usa IA).

## 7. Pantallas
**Mi cuenta** (`CuentaScreen`, `/cuenta`):
- Cuerpo en lista: `ListTile` «Configuración» (ícono de ajustes con `Semantics` excluido porque el texto ya lo nombra, flecha al final) → `/cuenta/configuracion`. Visible siempre.
- Solo fuera de release, debajo: el `SwitchListTile` «Modo técnico (prueba)» (lo que queda de `MenuDePrueba`).

**Configuración** (`ConfiguracionScreen`, `/cuenta/configuracion`, subruta de Mi cuenta; conserva la barra inferior y muestra el botón Atrás de `AppBar`):
- Título «Configuración».
- Encabezado «Idioma» (`Semantics(header: true)`) y `RadioGroup<Locale>` con **Español** y **English** (cada nombre en su propio idioma, en los dos ARB).
- Encabezado «Tema» y `RadioGroup<ThemeMode>` con **Automático** (con subtítulo «Igual que el teléfono»), **Claro** y **Oscuro**.
- Al elegir, el cambio se aplica al momento; no hay botón Guardar ni confirmación.
- **Estados:** no aplica el patrón de 4 estados (no hay carga remota): la pantalla siempre tiene datos (los valores actuales del proveedor, ya cargados antes del primer cuadro). No hay vacío ni error visible (TC-08).
- **Accesibilidad:** semántica de radio y encabezados, 48 dp, contraste ≥ 4.5:1 en claro y oscuro (con los roles de color de TT-MOB-02; el radio marcado usa `amber-ink` en claro), texto al 200 % sin desbordes, sin `textScaler` fijo.

**Textos (ARB, claves nuevas camelCase con prefijo `configuracion`; propuesta es → en, a confirmar con la maqueta, §8 duda 7):**

| Clave | es | en |
|---|---|---|
| `configuracionTitulo` | Configuración | Settings |
| `configuracionIdioma` | Idioma | Language |
| `configuracionIdiomaEspanol` | Español | Español |
| `configuracionIdiomaIngles` | English | English |
| `configuracionTema` | Tema | Theme |
| `configuracionTemaAutomatico` | Automático | Automatic |
| `configuracionTemaAutomaticoDetalle` | Igual que el teléfono | Same as your phone |
| `configuracionTemaClaro` | Claro | Light |
| `configuracionTemaOscuro` | Oscuro | Dark |

`configuracionTitulo` sirve para la entrada de Mi cuenta y para el título de la pantalla. Cada clave de `app_es.arb` lleva `@clave.description`. Se borran las 7 claves `pruebaTema…`/`pruebaIdioma…`; `pruebaModoTecnico` se queda.

## 8. Pruebas, gates y límites
**Plan de pruebas** (Sí/No con motivo; meta de mutación):

| Tipo | ¿Aplica? | Motivo / herramienta |
|---|---|---|
| Unitarias (UM) | Sí | Almacén (lectura, escritura, valores inválidos, fallos), `PreferenciasNotifier` con almacén falso y arranque (TC-05 a 08) en `app/test/core/preferencias/`; con `SharedPreferences.setMockInitialValues`, sin disco ni red. |
| Widget (W) | Sí | Configuración y Mi cuenta: cambio en vivo de idioma y tema, Automático con `platformBrightnessTestValue`, primer cuadro tras reinicio, release y no release (TC-01, 03, 04, 05, 09, 10), con `UncontrolledProviderScope` y el arnés `montar_app.dart` de TT-MOB-02. |
| Aceptación (ACC) | Sí | CA1–CA5 = TC-01 a 05, cada uno con su ID en el nombre de la prueba. |
| Seguridad negativa (NEG) | Sí | Idioma guardado que ya no existe → español, valores y tipos corruptos (TC-07); solo dos claves (TC-06). |
| Arquitectura | Sí | Solo `core/preferencias/` importa `shared_preferences` (TC-06), con el mismo método que `features/oficios/arquitectura_test.dart`. |
| E2E | Sí (mínimo) | La ficha lo pide: `app/integration_test/configuracion_test.dart` en el emulador con el plugin real, cambia idioma y tema desde Configuración y comprueba lo guardado (TC-05). El reinicio real del proceso no se puede automatizar con `integration_test`: va como evidencia manual (video o capturas). |
| Accesibilidad (A11Y) | Sí | `meetsGuideline` de tamaño táctil, etiquetas y contraste en claro y oscuro, semántica de radio y texto al 200 % (TC-10). |
| Contrato (CON) | No | Sin API. |
| Mutación (MUT) | No | Sin `domain/`; la conversión de valores está protegida por la tabla de TC-07 (cada valor válido e inválido). No se baja ningún umbral. |
| Regresión visual (doradas) | No | Aún no hay doradas en la app (TT-MOB-02); las capturas del PR son la evidencia. |
| Rendimiento | No | Lectura de dos claves de una caché ya cargada; el `await getInstance()` antes de `runApp` se mide a ojo en el emulador (sin parpadeo visible). |
| Usabilidad (USA) | No | La ficha dice No; pantalla de dos selectores. |

**Cobertura:** app ≥ 50 % líneas; no se bajan umbrales.

**Gates:** `AGENTS.md §5` (App): `dart format --set-exit-if-changed lib test` sin cambios, `flutter analyze --fatal-infos` limpio, generados de `gen-l10n` al día, `flutter test` verde (incluidas las pruebas de TT-MOB-01, TT-MOB-02 y TT-PRU-02) y cobertura ≥ 50 %; `sdd_lint.py`, `sdd_lint.py --trace HU-052`, `codemap.py --check`, `check_exceptions.py` y `sync_agents.py --check` en OK; `security-reviewer` LIBERA; `traceability-clerk` sin drift; `Memoria.md` al día; informe de `story-workflow` en el PR con «Uso de IA». Esta spec es un borrador: no se ha escrito ni ejecutado ninguna prueba ni línea de código.

**Límites conocidos:**
- **Dependencia de otro PR:** todo lo de §3 se apoya en el código de TT-MOB-02 (PR #16), que aún no está en `sprint-02`. Si el PR #16 cambia antes de fusionarse (nombres de `Preferencias`, del menú de prueba o de las claves ARB), esta spec se ajusta antes de aprobarse o se anota la diferencia en el PR.
- **Reinicio real del proceso:** las pruebas simulan el reinicio con un contenedor nuevo y los valores guardados; el cierre y la apertura reales solo se ven a mano en el emulador.
- **iOS:** sin macOS en el equipo no se compila ni se prueba en iOS; `shared_preferences` usa `NSUserDefaults` y no requiere cambios en `Info.plist`.
- **CA2 en la app real:** mientras TC-TT-MOB-02-02 exija las mismas claves en `app_es.arb` y `app_en.arb`, nunca habrá un texto sin traducir en la compilación; el respaldo es una red de seguridad (gen-l10n) que se prueba con ARB de prueba (duda 3). Relajar esa regla es decisión de HU-053.
- **Tamaño:** 1 punto según la ficha; además de la pantalla, incluye una dependencia nueva y el ajuste de dos pruebas de TT-MOB-02. Si no alcanza, el E2E mínimo es lo primero que se puede pasar a otra tarea (con el aviso en el PR).

**Dudas abiertas para el revisor** (con propuesta; no están decididas):
1. **Evaluación de `shared_preferences` (pendiente; la registra quien implemente en `Memoria.md` y en el PR).** Necesidad: guardar dos valores simples en el dispositivo (la ficha lo nombra). Datos a confirmar al implementar: licencia BSD-3-Clause, editor verificado `flutter.dev` (repositorio `flutter/packages`), versión estable vigente compatible con Flutter 3.47.7 / Dart 3.13.5, sin avisos en OSV para el paquete ni para sus implementaciones por plataforma, y qué transitivas nuevas entran al `pubspec.lock`. *Propuesta:* agregarla con `flutter pub add shared_preferences` (restricción `^`), usar el **API clásico `SharedPreferences`** (permite `setMockInitialValues` y lectura síncrona tras `getInstance()`); alternativa: `SharedPreferencesWithCache` con `allowList` de las dos claves (refuerza TC-06 desde el propio API, pero las pruebas necesitan `shared_preferences_platform_interface` como dependencia de desarrollo). No se usan `hive`, `isar` ni `flutter_secure_storage` para esto (no es un dato sensible y serían dependencias de más).
2. **Menú de prueba de TT-MOB-02 y sus pruebas.** *Propuesta:* los selectores de tema e idioma del menú de prueba se **reemplazan** por la pantalla real (no conviven dos formas de cambiar lo mismo) y se mueven sus widgets `_Encabezado`/`_Opcion` a Configuración; el menú se queda solo con «Modo técnico (prueba)» y su condición `!kReleaseMode`. En consecuencia, `menu_de_prueba_test.dart` (TC-TT-MOB-02-01) cambia solo el camino (entrar a Configuración antes de tocar «Claro», «Oscuro», «English», «Español») y `textos_desde_arb_test.dart` (TC-TT-MOB-02-02) visita también Configuración y espera las claves `configuracion…` en lugar de `prueba…` (TT-MOB-02 §2: «cada historia nueva hereda la prueba agregando su pantalla al recorrido»). Las aserciones y los IDs no cambian; se declara en el PR. Alternativa: dejar el menú de prueba como está y agregar Configuración aparte (duplica controles y textos; no recomendada).
3. **Cómo se prueba CA2 sin romper V2.** gen-l10n usa el ARB plantilla (`app_es.arb`) para cualquier clave que falte en otro idioma: la clase `AppLocalizationsEn` generada devuelve el texto en español (y avisa de «mensajes sin traducir»). *Propuesta:* (a) ARB de prueba en `app/test/l10n/respaldo/` (`app_es.arb` con 2 claves, `app_en.arb` con 1) que la prueba genera en una carpeta temporal con un `l10n.yaml` mínimo copiado de las opciones de `app/l10n.yaml` (`flutter gen-l10n` con `Process.run`), y se afirma que el `.dart` inglés contiene el texto español de la clave que falta; (b) prueba unitaria de la resolución de idioma (no soportado → español, por `idiomasSoportados.first` y la lectura del almacén). Los ARB reales siguen con las mismas claves. Riesgo: (a) necesita `flutter` en el `PATH` del CI (lo está) y tarda unos segundos; si el revisor lo prefiere, (a) pasa a «(comando)» con la salida en el PR. Alternativa descartada: quitar a propósito una traducción de `app_en.arb` (rompería TC-TT-MOB-02-02).
4. **Arranque sin parpadeo (CA5).** *Propuesta:* cargar antes del primer cuadro: `main()` asíncrono que espera `SharedPreferences.getInstance()` antes de `runApp` y entrega el almacén al `ProviderScope`; `PreferenciasNotifier.build()` sigue **síncrono**, así el primer cuadro ya tiene el idioma y el tema guardados (TC-05 lo comprueba en el primer `pump`). El costo es una lectura de disco de milisegundos mientras se ve la pantalla de arranque nativa. Alternativa descartada: `AsyncNotifier` con estado de carga, que obliga a pintar un primer cuadro con valores por defecto (parpadeo de claro a oscuro o de español a inglés) o a una pantalla de carga propia.
5. **Proveedor del almacén y fallos.** *Propuesta:* `almacenPreferenciasProvider` en `core/preferencias/` con valor por defecto **en memoria** (sin persistencia), que `main()` reemplaza con el de `shared_preferences`; así las pruebas existentes que montan `KnockApp` con un `ProviderContainer()` sin overrides (p. ej. `rutas_oficios_test.dart` de TT-PRU-02) no cambian, y el mismo almacén en memoria es el respaldo si `getInstance()` falla (TC-08). El riesgo (olvidar el reemplazo en `main()`) lo cubre TC-05 probando la función de arranque que llama `main()`. Al guardar: primero cambia el estado, después se guarda sin `await` en la interfaz; un error se atrapa y se ignora sin log. Alternativa: proveedor que lanza si no se reemplaza (falla visible), a costa de tocar el arnés de varias pruebas de otras specs.
6. **Idioma por defecto.** La ficha dice español; DECISIONES §7 («Para el producto real») propone el idioma del dispositivo con cambio manual. *Propuesta:* español, como la ficha y TT-MOB-02; seguir al dispositivo queda fuera (Out) y, si se quiere, se agrega como opción «Automático» de idioma en otra historia.
7. **Textos y orden de la pantalla.** Los de §7 son propuesta (en especial «Settings», «Automatic» y el subtítulo «Igual que el teléfono»); el orden Idioma → Tema sigue a FUNCIONES_Y_FLUJOS. Los confirma quien tenga la maqueta (Mi cuenta → Configuración).
8. **Ubicación de la pantalla.** *Propuesta:* en la feature `cuenta` (`features/cuenta/presentation/configuracion_screen.dart`), porque es una sección de Mi cuenta y no tiene `domain/` ni `data/` propios (el estado es de `core/`). Alternativa: feature `configuracion` aparte, que tendría sentido cuando lleguen «qué avisos recibir» y más secciones.
9. **Sprint y rama.** La ficha dice Sprint 1, `feature/KNOCK-49-idioma-y-tema` y PR a `sprint-01`; esta spec usa Sprint 2, `feature/KNOCK-49-language-and-theme-settings` y `sprint-02` (convención de ramas en inglés de `CONTRIBUTING.md`). Confirmar en Jira.

## Aprobación
- [ ] Revisor 1 — nombre: ________ fecha: ________
- [ ] Sin conflicto con la constitución
- **Estados:** Borrador (agente) → Aprobada (persona; habilita el código) → Firmada (tras el merge)
