# TT-PRU-02 — Ejercicio fuera de rol (Guillermo): pantalla Flutter que lista los oficios

> **Jira:** KNOCK-30 · **Épica:** EP-13 · **Módulo:** App móvil — Prueba de roles · **Responsable:** José Guillermo Rangel Hernández · **Sprint:** la ficha dice «semana de prueba de roles»; el líder la ubicó en el Sprint 1 con cierre el 2026-10-26 a las 12:00 y, si no alcanza, pasa al Sprint 2 (decisión del 2026-10-24) · **Puntos:** 1 · **Depende de:** TT-MOB-01 (fusionada), TT-PRU-01 (spec Aprobada por el líder el 2026-10-22, PR #31 de knock-backend, aún sin fusionar) · **Capas:** Mobile
> **Repositorio:** knock-frontend · **Otra parte en:** knock-backend (TT-PRU-01 entrega `GET /api/v1/oficios`)
> **Rama:** `feature/KNOCK-30-oficios-screen` → PR a `sprint-01` (la ficha cita `feature/KNOCK-30-pantalla-oficios` → `sprint-00`; la rama real es la de este encabezado)
> **Fuentes:** ficha `TT-PRU-02` (`docs/backlog/TT-PRU-02.md` de knock-backend, generada del backlog) · spec firmada de TT-PRU-01 (`specs/TT-PRU-01-endpoint-get-api-v1-oficios/spec.md` en el PR #31 de knock-backend, §4 y §8 D2, D8 y D9) · spec de TT-MOB-01 (estructura `core/` y `features/`, router y pestañas) · `.specify/memory/constitution.md` · `AGENTS.md` §§0, 1, 4 y 5 · skills `flutter-clean-architecture`, `testing-strategy-frontend`, `api-client-contract` y `security-core`
> **Skills:** spec-first-writing, story-workflow, flutter-clean-architecture, testing-strategy-frontend, api-client-contract, security-core, reuse-before-create, traceability
> **Estado:** Borrador

**Cómo leer esta spec.** Es un ejercicio de 1 punto para ver qué tan cómodo se siente Guillermo en el frontend. Por decisión del líder (2026-10-24) la pantalla se construye **contra el contrato firmado de TT-PRU-01 y con datos de prueba**: no hay llamada HTTP real todavía, porque en este repositorio no existen `contracts/openapi.v1.json` ni el cliente generado y `dio` no está evaluado. Va en la misma línea del flujo nuevo del equipo (la app avanza contra el contrato publicado, con una API simulada, sin esperar al backend). Lo que no está decidido queda como duda numerada con recomendación (§8).

## 1. Objetivo
Una pantalla Flutter que **lista los oficios** del catálogo (`clave`, `nombre`, `modalidad`) con su **ícono por modalidad** (taller o domicilio) y los **cuatro estados** de la app: cargando, datos, vacío y error con botón **Reintentar**. La feature `oficios` sigue las tres capas de la constitución (`data/`, `domain/`, `presentation/`) y la pantalla pide los datos a un **repositorio** (interfaz en `domain/`); en esta tarea la implementación es un **repositorio con datos de prueba** que devuelve exactamente lo que dice el contrato de TT-PRU-01. Cuando exista el contrato vendorizado y el cliente generado (TT-MOB-03; la API simulada es una tarea aparte), solo se cambia esa implementación: la pantalla, el controlador y las pruebas no cambian.

**Terminada cuando** (ficha, V1 y V2, adaptadas por la decisión del líder): la pantalla muestra los 3 oficios del contrato con su ícono, maneja carga, error con Reintentar y vacío, y la prueba de widget con un repositorio falso pasa en el CI. La comprobación «los 3 oficios desde la API local» (V1 de la ficha) **se difiere** a TT-MOB-03 (duda 1).

**Qué ya existe** (leído en `app/` y con `python scripts/codemap.py --query "oficios"`, sin coincidencias): `core/router/` (`AppRouter` con `StatefulShellRoute` de 5 ramas, `Rutas`, `AppShell`), `core/widgets/PantallaTitulada` (barra superior con título y cuerpo, hecha para que cada historia reemplace el cuerpo con sus 4 estados), `features/explorar/presentation/explorar_screen.dart` (vacía) y `flutter_riverpod` 3 y `go_router`. **No existen:** `core/red`, `core/errores` (solo `.gitkeep`), cliente generado, ARB ni tema propio (TT-MOB-02 está en otra rama).

## 2. Historia y casos de prueba
**TT-PRU-02** — Como persona que prueba otro rol, quiero hacer una pantalla pequeña en Flutter que liste los oficios desde el contrato de la API, para ver qué tan cómodo me siento en el frontend y dejar el patrón de una pantalla con sus cuatro estados.

**Datos de prueba.** Solo los tres oficios ficticios del contrato de TT-PRU-01: `ele` / «Electricidad» / `domicilio`, `mec` / «Mecánica» / `taller` y `plo` / «Plomería» / `domicilio`, **en ese orden** (por nombre, como los entrega la API). Ningún dato real, token ni secreto. Las pruebas de widget usan un repositorio falso propio de la prueba y un `ProviderScope` con `overrideWith`; los nombres son `testWidgets('TC-TT-PRU-02-01 …')`.

| Caso | Criterio (Dado / Cuando / Entonces) | Verificación |
|---|---|---|
| TC-TT-PRU-02-01 | Dado un repositorio que devuelve los 3 oficios del contrato, cuando se abre la pantalla de oficios, entonces muestra una fila por oficio con su **nombre** («Electricidad», «Mecánica», «Plomería») **en el orden recibido** (la pantalla no reordena ni filtra) y no muestra indicador de carga, error ni mensaje de vacío. | `app/test/features/oficios/presentation/oficios_screen_test.dart` — `testWidgets('TC-TT-PRU-02-01 muestra los oficios en el orden del contrato')` |
| TC-TT-PRU-02-02 | Dados los oficios `domicilio` y `taller`, cuando se muestran, entonces cada fila lleva el **ícono de su modalidad** (uno distinto para domicilio y para taller) y el texto de la modalidad («A domicilio», «En taller»), y el ícono tiene una etiqueta semántica para lectores de pantalla (el estado no depende solo del ícono). | `…/oficios_screen_test.dart` — `testWidgets('TC-TT-PRU-02-02 muestra el ícono y el texto de cada modalidad')` |
| TC-TT-PRU-02-03 | Dado un repositorio que aún no responde, cuando se abre la pantalla, entonces se ve un indicador de carga con etiqueta semántica («Cargando oficios») y ninguna lista; al responder, el indicador desaparece y aparece la lista. | `…/oficios_screen_test.dart` — `testWidgets('TC-TT-PRU-02-03 muestra la carga y luego la lista')` (con un `Completer`) |
| TC-TT-PRU-02-04 | Dado un repositorio que falla en la primera petición y acierta en la segunda, cuando se abre la pantalla, entonces se ve un **mensaje de error genérico** (sin detalle técnico, URL, excepción ni traza) y un botón **Reintentar**; al tocarlo se **vuelve a pedir** (el repositorio recibe una segunda llamada), se ve la carga y después la lista; y el área táctil del botón mide **al menos 48 dp**. | `…/oficios_screen_test.dart` — `testWidgets('TC-TT-PRU-02-04 el error ofrece Reintentar y vuelve a pedir')` |
| TC-TT-PRU-02-05 | Dado un repositorio que devuelve una lista vacía (el contrato responde `[]` si no hay oficios activos), cuando se abre la pantalla, entonces se ve un mensaje de **lista vacía** («Todavía no hay oficios disponibles») distinto del de error, sin botón Reintentar y sin lista. | `…/oficios_screen_test.dart` — `testWidgets('TC-TT-PRU-02-05 muestra el estado vacío sin tratarlo como error')` |
| TC-TT-PRU-02-06 | Dado un oficio con una `modalidad` que el contrato no lista hoy (p. ej. `remoto`; el contrato la declara como cadena con valores conocidos, no como enum cerrado), cuando se muestra, entonces la fila aparece con un **ícono genérico** y el texto de la modalidad recibida, sin excepción ni pantalla de error. | `app/test/features/oficios/domain/modalidad_test.dart` y `…/oficios_screen_test.dart` — `testWidgets('TC-TT-PRU-02-06 tolera una modalidad desconocida')` |
| TC-TT-PRU-02-07 | Dado el contrato `[{clave, nombre, modalidad}]`, cuando el mapeador de `data/` convierte el JSON de ejemplo de la spec de TT-PRU-01 en entidades `Oficio`, entonces produce los 3 oficios con sus valores y en el mismo orden; un elemento sin `clave`, `nombre` o `modalidad`, o con alguno vacío o de otro tipo, se **rechaza** con un `Failure` tipado (no un `null` ni una excepción cruda); y el repositorio con datos de prueba entrega los oficios **solo a través de ese mapeador**. | `app/test/features/oficios/data/oficio_mapper_test.dart` — `test('TC-TT-PRU-02-07 …')` |
| TC-TT-PRU-02-08 | Dada la feature `oficios`, cuando corren las pruebas de capas, entonces `domain/` **no importa** `flutter`, `dio`, `flutter_riverpod` ni `knock_api`; `presentation/` **no importa** `dio`, `knock_api` ni `data/`; y ninguna otra feature importa `domain/` ni `data/` de `oficios`. | `app/test/features/oficios/arquitectura_test.dart` — `test('TC-TT-PRU-02-08 …')` (lee los `import` de `lib/features/**`) |
| TC-TT-PRU-02-09 | Dado el texto escalado al **200 %** y una pantalla angosta, cuando se muestran los estados de datos, error y vacío, entonces no hay desbordes (`RenderFlex overflowed`) ni texto cortado sin poder leerse, y las filas conservan áreas táctiles de **al menos 48 dp**. | `…/oficios_screen_test.dart` — `testWidgets('TC-TT-PRU-02-09 soporta texto al 200 % sin desbordes')` |
| TC-TT-PRU-02-10 | Dada la app completa, cuando se navega a la ruta de oficios (`/explorar/oficios`, duda 2), entonces se ve la pantalla «Oficios» dentro de la barra inferior con **Explorar** seleccionada, se puede regresar a Explorar, y las pruebas existentes del router y de la barra (TT-MOB-01) siguen en verde sin cambios. | `app/test/core/router/rutas_oficios_test.dart` — `testWidgets('TC-TT-PRU-02-10 la ruta de oficios cuelga de Explorar')` |
| TC-TT-PRU-02-11 | Dado el trabajo terminado, entonces `app/pubspec.yaml` y `app/pubspec.lock` **no cambian** (ninguna dependencia nueva: no hay `dio`, ni cliente HTTP, ni paquete de pruebas nuevo); no hay URLs, claves ni datos reales en `lib/features/oficios/`; y el repositorio con datos de prueba no hace ninguna llamada de red. | (comando) `git diff --stat origin/sprint-01 -- app/pubspec.yaml app/pubspec.lock` vacío y `grep -rEn "http|dio|Dio|Uri\.parse|api\." app/lib/features/oficios` sin coincidencias; salida en el PR |
| TC-TT-PRU-02-12 | Dado el trabajo terminado, entonces formato, análisis y pruebas de la app pasan sin warnings ni cambios. | (comando) `cd app && dart format --set-exit-if-changed lib test && flutter analyze --fatal-infos && flutter test --coverage`; el resultado real sale del CI (en el equipo local de la persona hay Flutter 3.29.0 y el proyecto pide 3.47.7, §8) |

## 3. Alcance / No-alcance
- **In (este repositorio, `app/`):**
  - Feature `app/lib/features/oficios/` con sus tres capas: `domain/` (entidad `Oficio` y modalidad en Dart puro, interfaz `OficiosRepository`), `data/` (mapeador del contrato y `OficiosRepositoryDePrueba` con los 3 oficios del contrato) y `presentation/` (`OficiosScreen` y su controlador Riverpod con estado inmutable).
  - Cuatro estados: cargando, datos, vacío y error con Reintentar; íconos y textos por modalidad con semántica.
  - Un `Failure` tipado mínimo en `core/errores/` (la skill pide errores tipados; hoy esa carpeta está vacía), para que el controlador distinga la causa sin exponer detalles.
  - La ruta hija `/explorar/oficios` en el router y un acceso mínimo desde la pestaña Explorar (duda 2).
  - Pruebas de widget, unitarias y de capas de §2.
- **Out:**
  - **Llamada HTTP real** y todo lo que la necesita: `dio`, `contracts/openapi.v1.json`, `app/packages/knock_api`, interceptor de sesión y manejo de ProblemDetails (TT-MOB-03 y la tarea que publique el contrato). Por eso el V1 de la ficha («3 oficios desde la API local») queda diferido (duda 1). La **API simulada** del flujo nuevo del equipo es una tarea aparte (TT-MOB-08, que abre el líder).
  - **Diseño final**, tema propio y textos en ARB es/en (TT-MOB-02; las pestañas de TT-MOB-01 tampoco los tienen aún: textos literales en español hasta entonces).
  - Caché, paginación, búsqueda, selección de un oficio o navegación a otra pantalla; filtros por modalidad.
  - Sesión, tokens, Firebase y cualquier dato personal (el endpoint es público).
  - Cambios en `contracts/`, `app/packages/knock_api/`, `.github/`, `scripts/`, la constitución o el backend.

## 4. Contratos API y eventos
**Consume (contrato de TT-PRU-01, spec Aprobada por el líder el 2026-10-22; PR #31 de knock-backend):** `GET /api/v1/oficios`.

| Elemento | Detalle |
|---|---|
| Acceso | Pública (sin `Authorization`). |
| `200` | `application/json`, arreglo **no paginado** de `{ clave, nombre, modalidad }` **ordenado por nombre**; `[]` si no hay oficios activos. |
| Campos | `clave` (cadena corta, p. ej. `ele`), `nombre` (≤ 100, en español) y `modalidad` (cadena; hoy `domicilio` o `taller`; el contrato **no** la declara como enum cerrado, para no romperse si se agrega otra, p. ej. remoto en fase 2). |
| Errores | `500` `application/problem+json`. |
| Excepciones documentadas | Sin paginación (catálogo acotado) y sin `Idempotency-Key` (es lectura); el líder indicó `cache: 86400` para la colección de oficios (respuesta del líder en #31). |

Ejemplo del contrato (los datos de prueba de esta tarea):
```json
[
  { "clave": "ele", "nombre": "Electricidad", "modalidad": "domicilio" },
  { "clave": "mec", "nombre": "Mecánica", "modalidad": "taller" },
  { "clave": "plo", "nombre": "Plomería", "modalidad": "domicilio" }
]
```
**Eventos:** ninguno. **Contrato vendorizado y cliente generado:** no existen en este repositorio todavía (`contracts/openapi.v1.json` y `app/packages/knock_api`); no se inventa un contrato provisional ni se escribe un cliente a mano (reglas de `AGENTS.md` §4). El mapeador de `data/` fija la forma del contrato y es el único punto que cambia cuando llegue el cliente generado.

## 5. Modelo de datos
— (sin persistencia local ni en servidor). La entidad `Oficio { clave, nombre, modalidad }` vive en memoria durante la vida del controlador; `modalidad` es un tipo de dominio con `domicilio`, `taller` y un valor para «otra» que conserva el texto recibido (TC-TT-PRU-02-06). Nada se guarda en disco ni en almacenamiento seguro.

## 6. Seguridad, privacidad y amenazas
| Amenaza | Control | Caso que lo prueba |
|---|---|---|
| **Fuga (I):** detalles técnicos, URLs o excepciones en pantalla o en logs al fallar | El error se traduce a un `Failure` tipado y la pantalla muestra un texto genérico; no se registra nada con `print` ni se muestra `toString()` de la excepción; sin datos personales en logs | TC-TT-PRU-02-04 |
| **Alteración (T):** una modalidad o un campo inesperado rompe la pantalla (denegación local) | El mapeador valida `clave`, `nombre` y `modalidad` y rechaza lo mal formado con `Failure`; una modalidad nueva se muestra con ícono genérico | TC-TT-PRU-02-06 · TC-TT-PRU-02-07 |
| **Alteración (T):** texto del servidor interpretado como marcado o ejecutado | Se muestra solo como `Text` plano; no hay `WebView`, HTML ni navegación por URL con datos del servidor | TC-TT-PRU-02-01 |
| **Elevación / acoplamiento (E):** la capa de presentación o el dominio dependen de HTTP o del cliente generado | Reglas de capas comprobadas por prueba | TC-TT-PRU-02-08 |
| **Cadena de suministro:** paquetes nuevos sin evaluar (`dio`, cliente HTTP) | Ninguna dependencia nueva en esta tarea; `pubspec.yaml` y `pubspec.lock` sin cambios | TC-TT-PRU-02-11 |
| **Datos reales:** datos o secretos reales en repositorio o pruebas | Solo los tres oficios ficticios del contrato; ninguna llamada de red | TC-TT-PRU-02-11 |
| **Accesibilidad (usuarios con lector de pantalla o texto grande):** el estado solo por ícono, áreas táctiles pequeñas, desbordes | Texto además del ícono, etiquetas semánticas, áreas ≥ 48 dp, texto al 200 % | TC-TT-PRU-02-02 · TC-TT-PRU-02-09 |

No aplican: autenticación y tokens (endpoint público), datos personales, biométricos, archivos, IA.

## 7. Pantallas
**Oficios** (`OficiosScreen`, ruta hija `/explorar/oficios`; textos literales en español hasta TT-MOB-02):
- Barra superior con el título «Oficios» (base `PantallaTitulada`).
- **Cargando:** indicador de progreso centrado, con etiqueta semántica «Cargando oficios».
- **Datos:** lista vertical; cada fila lleva el ícono de la modalidad (domicilio o taller; genérico si es desconocida), el nombre del oficio y la modalidad en texto («A domicilio», «En taller»).
- **Vacío:** mensaje «Todavía no hay oficios disponibles».
- **Error:** mensaje genérico («No pudimos cargar los oficios») y botón **Reintentar** (área táctil ≥ 48 dp) que vuelve a pedir los datos.
- Accesibilidad: etiquetas semánticas en íconos, contraste según el tema actual, texto escalable hasta 200 %.
- Diseño final: fuera de alcance; se usa el tema por defecto del proyecto.

## 8. Pruebas, gates y límites
**Plan de pruebas** (Sí/No con motivo; meta de mutación):

| Tipo | ¿Aplica? | Motivo / herramienta |
|---|---|---|
| Unitarias (UM) | Sí | Mapeador del contrato, modalidad, controlador con repositorio falso. `app/test/features/oficios/`. |
| Widget (W) | Sí | Casos 01 a 06 y 09 con un repositorio falso y `ProviderScope`; es el criterio V2 de la ficha. |
| Arquitectura | Sí | Caso 08 (capas de la feature). |
| Aceptación (ACC) | Sí | Cada criterio de §2 es un caso con prueba; el V1 real contra la API local se difiere (duda 1). |
| Integración / E2E | No | Una pantalla sin red ni sesión; el recorrido real llega con TT-MOB-03. |
| Contrato (CON) | No (diferido) | No hay `contracts/openapi.v1.json` ni cliente generado; el mapeador fija la forma del contrato de TT-PRU-01 y la prueba de contrato llega con el cliente. |
| Mutación (MUT) | No | Presentación y mapeo sin reglas de negocio; no se baja ningún umbral. |
| Accesibilidad (A11Y) | Sí | Semántica, 48 dp y texto al 200 % (casos 02, 04 y 09); axe no aplica a Flutter. |
| Rendimiento, usabilidad formal | No | Ejercicio de 1 punto. |

Cobertura mínima de la app: 50 % (AGENTS.md §5); no se bajan umbrales.

**Gates:** `AGENTS.md` §5 en lo que aplica a la app: `dart format` sin cambios, `flutter analyze --fatal-infos` limpio, `flutter test` verde y cobertura ≥ 50 %, `sdd_lint.py` y `sdd_lint.py --trace TT-PRU-02`, `codemap.py --check`, `check_exceptions.py` y `sync_agents.py --check` en OK, `security-reviewer` LIBERA, `traceability-clerk` sin drift, `Memoria.md` al día e informe de `story-workflow` en el PR con «Uso de IA» (2 o 3 frases de qué hace y cómo se validó, como pidió el equipo). Esta spec es un borrador: no se ha escrito ni ejecutado ninguna prueba ni línea de código.

**Decisiones de redacción (de quien escribe la spec; el líder las puede cambiar):**
- **Repositorio con datos de prueba** en `data/` que pasa por el mapeador del contrato, en vez de datos escritos dentro de la pantalla: así el cambio al cliente generado o a la API simulada no toca presentación ni pruebas. Seguimiento esperado: reemplazarlo en TT-MOB-03.
- **`Failure` mínimo en `core/errores/`** (la skill `flutter-clean-architecture` pide errores tipados; la carpeta está vacía). TT-MOB-03 lo amplía con ProblemDetails.
- **Modalidad como tipo de dominio** con valor «otra» que conserva el texto, por lo que dice el contrato (cadena abierta).
- **Textos literales en español**, igual que las pestañas de TT-MOB-01; TT-MOB-02 los migra a ARB.

**Límites conocidos:**
- **No se puede ejecutar `flutter test` en el equipo local de la persona:** el proyecto pide Flutter 3.47.7 / Dart 3.13.5 (`pubspec.yaml`, TT-MOB-01 §8 decisión 4) y allí hay Flutter 3.29.0. El resultado real de las pruebas y del análisis lo da el CI; hasta que corra, el PR no puede decir que pasaron. Instalar la versión correcta con `flutter upgrade` o con FVM queda a criterio de la persona.
- **V1 de la ficha** («la pantalla muestra los 3 oficios desde la API local») no es verificable sin cliente HTTP, y el contrato (PR #31 de knock-backend) aún no está fusionado.
- El contrato anuncia `cache: 86400` para oficios; esta pantalla no cachea (no hay capa de red).

**Dudas abiertas para el líder** (con recomendación; no están decididas):
1. **V1 de la ficha.** ¿Se acepta cerrar TT-PRU-02 con datos de prueba y diferir «los 3 oficios desde la API local» a TT-MOB-03? *Recomendación:* sí; el PR lo dice y la evidencia es la prueba de widget con los 3 oficios del contrato y la captura de la pantalla en el emulador. Cuando haya contrato vendorizado y cliente generado (o API simulada), solo cambia el repositorio y se agrega la comprobación contra la API.
2. **Ruta y acceso a la pantalla.** La ficha no dice dónde vive. *Recomendación:* ruta hija `/explorar/oficios` de la rama Explorar (queda dentro de la barra inferior, sin cambiar las 5 pestañas de TT-MOB-01) y un acceso mínimo, un `ListTile` «Oficios» en `ExplorarScreen`, marcado como temporal para que la historia de Explorar lo reemplace. Alternativa: sin acceso en pantalla (solo la ruta) y la captura se toma con una ruta inicial de depuración; evita tocar `ExplorarScreen`, pero la pantalla queda inalcanzable para el usuario.
3. **`Failure` y estructura de `core/`.** ¿Se acepta crear `core/errores/failure.dart` mínimo aquí, o se deja el error como excepción de la feature hasta TT-MOB-03? *Recomendación:* `Failure` mínimo en `core/errores/` (lo pide la skill y evita rehacerlo).
4. **Versión de Flutter local.** El equipo local tiene 3.29.0 y el proyecto pide 3.47.7. *Recomendación:* actualizar el SDK local antes de la implementación para correr `flutter test` y `flutter analyze` antes del PR; mientras tanto, la prueba real es el CI. Si no se actualiza, esta tarea se entrega con el aviso en el PR.
5. **Texto de los mensajes** («No pudimos cargar los oficios», «Todavía no hay oficios disponibles», «A domicilio», «En taller»): son propuesta de redacción; los confirma quien tenga la maqueta, porque el diseño final está fuera de alcance.

## Aprobación
- [ ] Revisor 1 — nombre: ________ fecha: ________
- [ ] Sin conflicto con la constitución
- **Estados:** Borrador (agente) → Aprobada (persona; habilita el código) → Firmada (tras el merge)
