# TT-MOB-08 — API simulada desde el contrato para la app

> **Jira:** KNOCK-191 · **Épica:** EP-13 (KNOCK-13, Plataforma y calidad) · **Área:** MOB · App móvil base · **Responsable:** Erick Trejo Reséndiz · **Sprint:** S2 (vence el 2026-10-30) · **Puntos:** 2 · **Capas:** Mobile
> **Repositorio:** knock-frontend · **Otra parte en:** — (el backend no cambia: esta tarea solo lee la §4 de sus specs)
> **Rama:** `chore/KNOCK-191-mock-api-from-contract` → PR a `sprint-02`
> **Depende de:** TT-MOB-01 (fusionada) y TT-PRU-02 (KNOCK-30, en `sprint-02`: feature `oficios` con el proveedor `oficiosRepositoryProvider`). **No depende de** TT-CI-02 (el contrato vivo solo automatizará más adelante la generación de los mocks) **ni de** TT-MOB-03 (KNOCK-38, cliente Dart generado e interceptor de sesión, Sprint 2), que reemplaza el cliente HTTP de transición de esta tarea (§8 D2 y D8).
> **Ficha:** no hay ficha `.docx` ni `docs/backlog/TT-MOB-08.md`; la fuente es la descripción de Jira KNOCK-191 (citada en §1).
> **Fuentes:** Jira KNOCK-191 · contratos de la §4 de las specs del backend (detalle y commit en §4) · spec TT-PRU-02 (§1, §3 Out y §8 decisiones; `Memoria.md` 2026-10-25/26) · ficha TT-MOB-03 (`docs/backlog/TT-MOB-03.md`, §5 y §8: «La URL y llaves por entorno no se escriben en el código (dart-define)») · constitución 2.2.1 (principios 3, 4, 8 y 9; §3; §4 knock-frontend; §6; §12) · `AGENTS.md` §§0, 4 y 5 · skills `api-client-contract`, `flutter-clean-architecture`, `testing-strategy-frontend`, `security-core`
> **Skills:** spec-first-writing, story-workflow, api-client-contract, flutter-clean-architecture, testing-strategy-frontend, security-core, reuse-before-create, traceability
> **Estado:** Borrador

**Cómo leer esta spec.** Lo que dice Jira está en §1 tal cual. Todo lo que Jira no decide (cómo se sirve la simulación, dónde vive, cómo se configura la URL, cómo se escriben los mocks y cómo se comparan con el contrato) está como **propuesta de quien redacta**, numerada en §8 (D1 a D12) para que el líder la confirme o la cambie. La duda que más pesa es **D2**: el cliente HTTP de transición choca con el principio 4 de la constitución («nadie escribe llamadas HTTP a mano») y necesita una decisión explícita.

## 1. Objetivo
Descripción de Jira (literal): «Para que la app avance sin esperar al backend: cada spec de backend publica su contrato en la §4 y la app consume una API simulada (mocks) con esa forma de respuesta; cuando sale el endpoint real, solo cambia la URL. Se parte de los contratos que ya están en la §4 de las specs (por ejemplo /auth/firebase, /oficios y colonia por punto). No depende de TT-CI-02: ese contrato vivo solo automatiza la generación de los mocks más adelante. Sin datos reales.»

**Terminada cuando** (Jira): (a) la app corre una pantalla de la maqueta contra la API simulada; (b) cambiar a la API real es solo cambiar la URL de configuración; (c) hay una prueba que compara los mocks con el contrato de la §4.

Qué entrega este repositorio (propuesta, §8):
- Una **capa de red mínima** en `app/lib/core/red/`: una interfaz `ClienteApi` (petición → respuesta con estado, encabezados y cuerpo), una **configuración** leída de `--dart-define` y un **proveedor** único (`clienteApiProvider`) que es el punto de inyección que TT-MOB-03 cambiará.
- Una **API simulada en memoria** (`ClienteApiSimulado`) con respuestas JSON ficticias para tres contratos de la §4: `GET /api/v1/oficios`, `POST /api/v1/auth/firebase` y `GET /api/v1/colonias/en-punto`, incluidos sus errores 4xx y 5xx por **escenario**.
- Un **cliente HTTP de transición** (`ClienteApiHttp`, sobre `dart:io`, sin dependencias nuevas) para que «cambiar a la API real» sea de verdad solo cambiar la URL (sujeto a D2).
- La **pantalla de oficios** de TT-PRU-02 conectada a la API: un `OficiosRepositoryApi` en `features/oficios/data/` y el cambio de una línea en `oficios_providers.dart` (lo que la spec de TT-PRU-02 dejó previsto).
- Una **tabla de contrato versionada** derivada a mano de la §4 de cada spec (`app/test/contrato/contrato_s4.json`) y la prueba que compara cada mock con ella.

**Qué ya existe** (leído en `app/` de esta rama; `python scripts/codemap.py --query "red cliente api http"` sin coincidencias): `core/errores/failure.dart` (`Failure` sellado con `DatosInvalidosFailure` y `ServicioNoDisponibleFailure`), `core/red/` vacía (solo `.gitkeep`), la feature `oficios` completa con `OficioMapper.listaDesdeContrato`, `OficiosRepositoryDePrueba` y `oficiosRepositoryProvider` (raíz de composición), y `flutter_riverpod` 3 y `go_router` como únicas dependencias. **No existen** en este repositorio `contracts/openapi.v1.json`, `app/packages/knock_api/`, `scripts/sync_contract.py` ni `scripts/gen_clients.sh` (los cita `AGENTS.md` §2, pero aún no están), ni `dio`.

## 2. Historia y casos de prueba
**TT-MOB-08** — Como persona del equipo que construye la app, quiero que la app consuma una API simulada con la forma exacta de la §4 de las specs del backend, para avanzar las pantallas sin esperar a que el endpoint real esté publicado y cambiar a la API real solo con la URL.

**Datos de prueba.** Solo datos ficticios: los tres oficios del ejemplo de la §4 de TT-PRU-01 (`ele`, `mec`, `plo`), una colonia inventada («Colonia Simulada Centro», CP `00000`, municipio «Municipio de Prueba», `id` `000000000000000000000001`), coordenadas de ejemplo sin relación con una persona y tokens con la forma `simulado-access-…`/`simulado-refresh-…` (no son JWT, no se firman y no se guardan). Ningún celular, CURP, correo, token real ni URL real. Las pruebas no hacen llamadas fuera de `127.0.0.1` (las de `ClienteApiHttp` levantan un `HttpServer` local en un puerto libre). Nombres `test('TC-TT-MOB-08-KK …')` o `testWidgets('TC-TT-MOB-08-KK …')`.

| Caso | Criterio (Dado / Cuando / Entonces) | Verificación |
|---|---|---|
| TC-TT-MOB-08-01 | Dada la configuración de la app, cuando se lee `KNOCK_API_URL` (`--dart-define`), entonces: sin valor (o vacío) en una compilación que no es release → **modo simulado**; `https://<host>[:puerto]` → **modo real** con esa base; `http://` solo se acepta hacia `127.0.0.1`, `localhost` o `10.0.2.2` y nunca en release; cualquier otro valor (`http://` a otro host, otro esquema, URL con usuario y clave, con ruta distinta de `/`, consulta o fragmento, o mal formada) es un **error de configuración** explícito al arrancar, **sin** caer en silencio al modo simulado. `KNOCK_API_ESCENARIO` solo se acepta en modo simulado y con un valor de la lista de §5. | `app/test/core/red/configuracion_api_test.dart` — `test('TC-TT-MOB-08-01 lee la URL base y el modo desde dart-define')` |
| TC-TT-MOB-08-02 | Dada una compilación **release**, cuando `KNOCK_API_URL` falta, está vacía o pide la simulación, entonces la configuración falla con un error explícito y el modo simulado **nunca** se selecciona (una app publicada no puede mostrar datos simulados como si fueran reales). | `…/configuracion_api_test.dart` — `test('TC-TT-MOB-08-02 release nunca usa la API simulada')` (la función recibe `esRelease` como parámetro) |
| TC-TT-MOB-08-03 | Dada la API simulada en el escenario `normal`, cuando se pide `GET /api/v1/oficios`, entonces responde `200`, `Content-Type: application/json` y un cuerpo **igual** al ejemplo de la §4 de TT-PRU-01 (los 3 oficios en ese orden); una ruta o un método que no está simulado responde `404` `application/problem+json` (nunca un `200` vacío). | `app/test/core/red/simulada/cliente_api_simulado_test.dart` — `test('TC-TT-MOB-08-03 simula GET oficios con el ejemplo del contrato')` |
| TC-TT-MOB-08-04 | Dada la API simulada, cuando se elige cada escenario de error o de borde, entonces: `vacio` → `200` con `[]`; `error_servidor` → `500` `application/problem+json` con `type`, `title` y `status: 500` y **sin** `detail` técnico, traza ni excepción; `sin_conexion` → la petición falla con el error de red de `core/red` (el mismo que produce `ClienteApiHttp` sin conexión); `lento` → la respuesta llega después de una demora fija (para ver el estado de carga). | `…/cliente_api_simulado_test.dart` — `test('TC-TT-MOB-08-04 simula vacío, 5xx, sin conexión y lentitud')` |
| TC-TT-MOB-08-05 | Dada la API simulada, cuando se pide `POST /api/v1/auth/firebase`, entonces: con `{ "firebaseIdToken": "<texto no vacío ≤ 4096>" }` → `200` `{ accessToken, refreshToken }` con valores ficticios `simulado-…` (no JWT); sin cuerpo, sin `firebaseIdToken`, vacío o de más de 4096 caracteres → `400`; cuerpo de más de 8 KiB → `413`; escenario `no_autorizado` → `401`. Todos los errores son `application/problem+json`; la respuesta nunca repite el token recibido. | `…/cliente_api_simulado_test.dart` — `test('TC-TT-MOB-08-05 simula el canje de Firebase con sus errores')` |
| TC-TT-MOB-08-06 | Dada la API simulada, cuando se pide `GET /api/v1/colonias/en-punto`, entonces: con `lat` y `lon` válidos según la §4 de TT-API-07 (un valor cada uno, expresión `^-?\d{1,3}(\.\d{1,10})?$`, máx. 16 caracteres, rangos `[-90, 90]` y `[-180, 180]`) y `Authorization: Bearer …` → `200` `{ enCobertura: true, colonia: { id, nombre, cp, municipio } }`; escenario `fuera_de_cobertura` → `200` `{ enCobertura: false, colonia: null }`; sin `Authorization` → `401`; `lat` o `lon` ausente, repetido, con coma, exponente, `+`, espacios o fuera de rango → `422` con `errors.lat` o `errors.lon`; escenario `limite` → `429` con `Retry-After`. Toda respuesta lleva `Cache-Control: no-store` y **nunca** incluye las coordenadas recibidas. | `…/cliente_api_simulado_test.dart` — `test('TC-TT-MOB-08-06 simula la colonia por punto con 401, 422 y 429')` |
| TC-TT-MOB-08-07 | Dada la tabla de contrato versionada `app/test/contrato/contrato_s4.json` (derivada de la §4 de cada spec, con la ruta y el commit de origen por endpoint), cuando corre la prueba de contrato, entonces **cada respuesta simulada** (endpoint × estado × escenario) cumple su fila: campos obligatorios presentes, tipos, `null` solo donde la §4 lo permite, **sin campos de más**, longitudes y patrones (`clave` ≤ 16, `nombre` ≤ 100, `cp` de 5 dígitos, `id` de 24 hexadecimales) y `Content-Type`; además, **no hay mock sin fila ni fila sin mock**; y la prueba **falla** con copias alteradas de un mock (campo renombrado, tipo cambiado, campo extra, campo obligatorio quitado), para demostrar que el comparador no acepta todo. | `app/test/contrato/mocks_vs_contrato_test.dart` — `test('TC-TT-MOB-08-07 los mocks cumplen el contrato de la §4')` |
| TC-TT-MOB-08-08 | Dado `ClienteApiHttp` (D2) apuntando a un `HttpServer` local en `127.0.0.1` que sirve las mismas respuestas que la simulación, cuando se piden las rutas de §4, entonces devuelve el mismo estado, `Content-Type` y cuerpo que la simulación; un servidor que no responde dentro del tiempo límite, que cierra la conexión o que no existe produce el **error de red** de `core/red`; una respuesta de más de 1 MiB se corta con error; **no sigue redirecciones**; y no envía `Authorization` ni cookies propias (la sesión es de TT-MOB-03). | `app/test/core/red/cliente_api_http_test.dart` — `test('TC-TT-MOB-08-08 el cliente HTTP de transición se comporta como la simulación')` |
| TC-TT-MOB-08-09 | Dado `OficiosRepositoryApi` con un `ClienteApi` simulado, cuando se lista, entonces devuelve los 3 oficios **a través de `OficioMapper`** (mismo orden); `500` o error de red → `ServicioNoDisponibleFailure`; cualquier `4xx` → `SolicitudRechazadaFailure` (D7); `200` con un cuerpo que no cumple el contrato (no es arreglo, falta `clave`, JSON inválido o `Content-Type` distinto) → `DatosInvalidosFailure`; nunca sale una excepción cruda ni un `null`. | `app/test/features/oficios/data/oficios_repository_api_test.dart` — `test('TC-TT-MOB-08-09 el repositorio de oficios traduce la API a entidades y Failure')` |
| TC-TT-MOB-08-10 | Dado el mismo grafo de proveedores de la app (`clienteApiProvider` → `oficiosRepositoryProvider` → controlador), cuando solo cambia la configuración de modo simulado a modo real con la URL de un `HttpServer` local que sirve las respuestas del contrato, entonces el controlador de oficios obtiene **los mismos 3 oficios** sin cambiar ninguna otra pieza; y con una URL a un puerto cerrado termina en `ServicioNoDisponibleFailure` (demuestra que de verdad se usó la URL configurada). | `app/test/features/oficios/oficios_cambio_de_url_test.dart` — `test('TC-TT-MOB-08-10 cambiar a la API real es solo cambiar la URL')` |
| TC-TT-MOB-08-11 | Dada la app completa (`KnockApp`) **sin** sobreescribir el repositorio de oficios (proveedores por defecto, modo simulado), cuando se navega a `/explorar/oficios`, entonces se ven los 3 oficios que entrega la API simulada; con el escenario `error_servidor` se ve el error genérico con **Reintentar**, y al cambiar el escenario a `normal` y tocar Reintentar aparece la lista; con `vacio` se ve el estado vacío. Las pruebas existentes de TT-PRU-02 y TT-MOB-01 siguen en verde **sin cambios**. | `app/test/features/oficios/presentation/oficios_api_simulada_test.dart` — `testWidgets('TC-TT-MOB-08-11 la pantalla de oficios corre contra la API simulada')` |
| TC-TT-MOB-08-12 | Dado el código de `lib/`, cuando corren las pruebas de capas, entonces: `core/red/` **no importa** nada de `features/`; ningún `presentation/` ni `domain/` importa `core/red/` ni `dart:io`; solo los `data/` de las features usan `ClienteApi`; y `core/red/simulada/` solo lo importa el archivo del proveedor (`cliente_api_provider.dart`). | `app/test/core/red/arquitectura_red_test.dart` — `test('TC-TT-MOB-08-12 la red respeta las capas')` |
| TC-TT-MOB-08-13 | Dados los archivos de `lib/core/red/`, de `lib/features/oficios/data/` y la tabla `app/test/contrato/`, cuando se revisan, entonces no hay `print`, `debugPrint` ni `log(` que registren URL, consulta, encabezados o cuerpo; el `toString()` de los errores de red y de los `Failure` no incluye URL, coordenadas, tokens ni cuerpo; y los mocks no contienen datos con forma de dato real (celular de 10 dígitos, CURP, correo, texto que empiece con `eyJ` como un JWT, URL `https://` fuera de ejemplos `*.invalid`). | `app/test/core/red/privacidad_red_test.dart` — `test('TC-TT-MOB-08-13 la red no registra ni expone datos y los mocks son ficticios')` |
| TC-TT-MOB-08-14 | Dado el trabajo terminado, entonces `app/pubspec.yaml` y `app/pubspec.lock` **no cambian** (sin `dio`, `http`, `mocktail` ni assets nuevos), no hay URL real del backend en el repositorio y no se crearon `contracts/` ni `app/packages/knock_api/` a mano. | (comando) `git diff --stat origin/sprint-02 -- app/pubspec.yaml app/pubspec.lock contracts app/packages` vacío y `grep -rEn "https?://" app/lib` solo con ejemplos `*.invalid` o ninguno; salida en el PR |
| TC-TT-MOB-08-15 | Dado el trabajo terminado, entonces formato, análisis, pruebas y build de la app pasan sin warnings ni cambios, con cobertura ≥ 50 %. | (comando) `cd app && dart format --set-exit-if-changed lib test && flutter analyze --fatal-infos --fatal-warnings && flutter test --coverage && flutter build apk --debug`; resultado real del CI en el PR |

## 3. Alcance / No-alcance
- **In (este repositorio, `app/`):**
  - `core/red/`: `ClienteApi` (interfaz), `PeticionApi`/`RespuestaApi` (valores inmutables), `ErrorDeRedApi` (error de transporte sin datos), `ConfiguracionApi` (lee `KNOCK_API_URL` y `KNOCK_API_ESCENARIO`), `cliente_api_provider.dart` (punto de inyección) y `ClienteApiHttp` de transición (D2).
  - `core/red/simulada/`: `ClienteApiSimulado` y las respuestas ficticias de los tres contratos con sus escenarios.
  - `core/errores/failure.dart`: un subtipo nuevo `SolicitudRechazadaFailure` (D7).
  - `features/oficios/data/oficios_repository_api.dart` y el cambio de `oficios_providers.dart` para usarlo.
  - `app/test/contrato/contrato_s4.json` (tabla de contrato versionada) y su prueba.
  - Pruebas de §2.
- **Out:**
  - **Cliente Dart generado, `dio`, interceptor de sesión, renovación de token y ProblemDetails con el catálogo de mensajes** (TT-MOB-03, KNOCK-38). Esta tarea solo deja el punto de inyección (`clienteApiProvider`).
  - **Contrato vendorizado** (`contracts/openapi.v1.json`), `scripts/sync_contract.py`, `scripts/gen_clients.sh` y la **generación automática de mocks** desde el OpenAPI (TT-CI-02 y la publicación del contrato).
  - **Pantallas nuevas.** Las respuestas de `/auth/firebase` y de colonia por punto se simulan y se comparan con el contrato, pero **no** se conectan a ninguna pantalla (inicio de sesión: HU-001/TT-MOB-03; «¿Dónde buscas expertos?»: HU-009).
  - Guardar tokens (ni siquiera los simulados), sesión, Firebase y almacenamiento seguro.
  - Caché local con `ETag` (constitución §12; llega con la capa de red definitiva).
  - Servidor de simulación como proceso aparte (`app/tool/…`), uso desde el panel Angular y cambios en `app/android/` (texto claro hacia un backend local, D11).
  - Flavors de Android/iOS (D3: solo `--dart-define`).
  - Cambios en `contracts/`, `.github/`, `scripts/`, la constitución, el backend y las pruebas existentes de TT-PRU-02 y TT-MOB-01.

## 4. Contratos API y eventos
**Versión del contrato que consume:** la **§4 de las specs del backend** en los commits citados abajo. No hay `contracts/openapi.v1.json` en este repositorio. Cada fila de `app/test/contrato/contrato_s4.json` guarda su fuente (repositorio, rama, commit y ruta de la spec) para que se sepa contra qué versión se escribió el mock.

| Endpoint | Fuente (knock-backend, solo lectura) | Estado de la fuente | Respuestas que se simulan |
|---|---|---|---|
| `GET /api/v1/oficios` | `specs/TT-PRU-01-endpoint-get-api-v1-oficios/spec.md` §4, rama `origin/feature/KNOCK-29-trades-endpoint`, commit `028ff21` (PR #31, abierto hacia `sprint-02`) | Spec **Aprobada**; código sin fusionar | `200` arreglo `[{ clave (string ≤ 16), nombre (string ≤ 100), modalidad (string con valores conocidos `domicilio`/`taller`, no enum cerrado) }]` ordenado por nombre, ejemplo de 3 oficios · `200` `[]` · `500` `application/problem+json`. Pública (sin `Authorization`). |
| `POST /api/v1/auth/firebase` | `specs/TT-API-02-spike-token-firebase-sesion-jwt/spec.md` §4, rama `origin/sprint-02`, commit `c1170f2` (último cambio del archivo: `d73a8b9`) | Spec **Aprobada**; código fusionado (KNOCK-21) | Petición `{ firebaseIdToken }` (≤ 4096 caracteres; cuerpo ≤ 8 KiB) · `200` `{ accessToken, refreshToken }` · `400` · `401` (el mismo para cualquier causa) · `413`; errores `application/problem+json`. Pública. |
| `GET /api/v1/colonias/en-punto?lat=&lon=` | `specs/TT-API-07-endpoint-colonia-por-punto/spec.md` §4, rama `origin/sprint-02`, commit `c1170f2` (igual en `origin/feature/KNOCK-141-colonia-by-point`, commit `f58808f`, PR #82 abierto) | Spec **Aprobada**; implementación en PR #82 sin fusionar | `200` `{ enCobertura: true, colonia: { id, nombre, cp, municipio } }` · `200` `{ enCobertura: false, colonia: null }` · `401` · `422` con `errors.lat`/`errors.lon` · `429` con `Retry-After` · `500`; `Cache-Control: no-store`, sin `ETag`; la respuesta nunca trae las coordenadas. Requiere `Authorization: Bearer <JWT>`. |

Ejemplo de la §4 de TT-PRU-01 (es el mock `normal` de oficios):
```json
[
  { "clave": "ele", "nombre": "Electricidad", "modalidad": "domicilio" },
  { "clave": "mec", "nombre": "Mecánica", "modalidad": "taller" },
  { "clave": "plo", "nombre": "Plomería", "modalidad": "domicilio" }
]
```

**Fuente futura (no se usa en esta tarea):** el backend ya tiene `scripts/export_openapi.py` en `origin/sprint-02` (llegó con KNOCK-43, commit `25d1f08`); `docs/openapi.v1.json` **no** está versionado en `sprint-02` ni en la rama de TT-BD-06 (`origin/feature/KNOCK-156-shared-mongo-client`, PR #73); sí aparece en la rama del PR #82 (`f58808f`) con `auth/firebase`, `me`, `archivos/*` y `colonias/en-punto`, pero **sin** `oficios` (el PR #31 no está fusionado). Diferencias que se vieron al leerlo y que TT-CI-02 o TT-MOB-03 deberán resolver (no se corrigen aquí): las rutas salen como `/api/v{version}/…`, el `200` declara también `text/plain` y `text/json`, y `colonias/en-punto` no lista el `500` que sí está en la §4. Cuando exista el contrato vendorizado, la tabla `contrato_s4.json` se reemplaza por una comparación contra `contracts/openapi.v1.json` (D5).

**Eventos:** ninguno.

## 5. Modelo de datos
Sin persistencia (ni local ni en servidor). Valores en memoria:
- `ConfiguracionApi { modo: simulado | real, baseUrl: Uri? (solo origen), escenario }`. Claves de `--dart-define`: `KNOCK_API_URL` (origen sin ruta, p. ej. `https://api.ejemplo.invalid`; vacío = simulado fuera de release) y `KNOCK_API_ESCENARIO` (solo simulado): `normal` (por defecto), `vacio`, `error_servidor`, `sin_conexion`, `lento`, `no_autorizado`, `fuera_de_cobertura`, `limite`. Un escenario que no aplica a un endpoint deja ese endpoint en `normal`.
- `PeticionApi { metodo, ruta, consulta (lista de pares, para detectar parámetros repetidos), encabezados, cuerpo? }` y `RespuestaApi { estado, encabezados, cuerpo (texto) }`. El cuerpo viaja como texto JSON para que el repositorio lo decodifique igual que una respuesta real.
- `ErrorDeRedApi` (sin conexión, tiempo agotado, respuesta demasiado grande o cortada): no guarda URL, consulta ni cuerpo.
- `Failure` (existente) + `SolicitudRechazadaFailure { estado }` (D7).
- Tabla `contrato_s4.json` (solo pruebas): por endpoint y estado, `contentType`, esquema reducido (`type`, `required`, `properties`, `additionalProperties: false`, `nullable`, `maxLength`, `pattern`, `items`) y `fuente { repo, rama, commit, spec }`.

## 6. Seguridad, privacidad y amenazas
| Amenaza | Control | Caso que lo prueba |
|---|---|---|
| **Suplantación / engaño (S):** una app release muestra datos simulados como reales | En release el modo simulado no se puede seleccionar; sin URL válida la app falla al arrancar con un error explícito | TC-TT-MOB-08-02 |
| **Fuga (I):** tráfico en texto claro hacia un host que no es local, o URL con credenciales | Solo `https`, salvo `http` hacia `127.0.0.1`/`localhost`/`10.0.2.2` fuera de release; URL con usuario/clave, consulta o fragmento rechazada | TC-TT-MOB-08-01 |
| **Fuga (I):** URL real o secretos en el repositorio | La URL llega solo por `--dart-define`; ningún valor real en código ni pruebas (ficha TT-MOB-03 §8) | TC-TT-MOB-08-14 |
| **Fuga (I):** tokens: un token real en los mocks o uno simulado tratado como sesión | Tokens simulados `simulado-…` (no JWT), no se guardan ni se envían; `ClienteApiHttp` no agrega `Authorization`; la respuesta simulada no repite el token recibido | TC-TT-MOB-08-05 · TC-TT-MOB-08-08 · TC-TT-MOB-08-13 |
| **Fuga (I):** ubicación (lat/lon) en registros, errores o caché (constitución §6) | Sin registros en `core/red`; errores sin URL ni consulta; la simulación de colonia nunca devuelve las coordenadas y responde `Cache-Control: no-store` | TC-TT-MOB-08-06 · TC-TT-MOB-08-13 |
| **Fuga (I):** detalles técnicos en pantalla al fallar | Los errores se traducen a `Failure`; la pantalla de TT-PRU-02 ya muestra un texto genérico; los `500` simulados no traen `detail` técnico | TC-TT-MOB-08-04 · TC-TT-MOB-08-09 · TC-TT-MOB-08-11 |
| **Alteración (T):** los mocks se apartan del contrato y la app se construye sobre una forma falsa | Tabla de contrato versionada con su fuente y comparación en las dos direcciones; prueba con mocks alterados | TC-TT-MOB-08-07 |
| **Alteración (T):** una respuesta mal formada rompe la app | El repositorio pasa todo por `OficioMapper` y responde `DatosInvalidosFailure` | TC-TT-MOB-08-09 |
| **Alteración / SSRF del lado del cliente (T):** una redirección lleva la petición (y más adelante el token) a otro host | `ClienteApiHttp` no sigue redirecciones | TC-TT-MOB-08-08 |
| **Denegación (D):** un servidor lento o una respuesta enorme cuelga la pantalla | Tiempo límite de conexión y de respuesta, y tope de 1 MiB por cuerpo | TC-TT-MOB-08-08 |
| **Elevación / acoplamiento (E):** HTTP en presentación o dominio, o la simulación usada fuera del proveedor | Pruebas de capas | TC-TT-MOB-08-12 |
| **Cadena de suministro:** paquetes nuevos sin evaluar | Ninguna dependencia nueva; `pubspec` sin cambios | TC-TT-MOB-08-14 |
| **Datos reales** en mocks o pruebas | Solo datos ficticios; prueba que busca formas de dato real | TC-TT-MOB-08-13 |

No aplican: repudio (no hay acciones de usuario que auditar), autorización por recurso (la hace el servidor real; la simulación solo reproduce el `401`), biométricos, archivos e IA.

## 7. Pantallas
Ninguna pantalla nueva. La pantalla **Oficios** de TT-PRU-02 (`/explorar/oficios`) no cambia: con esta tarea sus datos llegan por `OficiosRepositoryApi` desde la API simulada (o la real, según la URL). Sus cuatro estados se pueden ver en el emulador sin tocar código:
- `flutter run` → datos (3 oficios).
- `flutter run --dart-define=KNOCK_API_ESCENARIO=lento` → carga.
- `flutter run --dart-define=KNOCK_API_ESCENARIO=vacio` → vacío.
- `flutter run --dart-define=KNOCK_API_ESCENARIO=error_servidor` (o `sin_conexion`) → error con Reintentar.
- `flutter run --dart-define=KNOCK_API_URL=https://<host del backend>` → API real (cuando exista el endpoint).

Accesibilidad y textos: los de TT-PRU-02, sin cambios.

## 8. Pruebas, gates y límites
**Plan de pruebas** (Sí/No con motivo; meta de mutación):

| Tipo | ¿Aplica? | Motivo / herramienta |
|---|---|---|
| Unitarias (UM) | Sí | Configuración, simulación, cliente HTTP de transición contra `HttpServer` local en `127.0.0.1`, repositorio de oficios (casos 01 a 06, 08 a 10). `flutter_test`, sin `mocktail` (no está en `pubspec`; se usan dobles escritos a mano). |
| Widget (W) | Sí | Caso 11: la app completa con los proveedores por defecto contra la API simulada. |
| Contrato (CON) | Sí | Caso 07: mocks contra la tabla de la §4. Es el criterio (c) de Jira. La comparación contra el OpenAPI vendorizado llega con TT-CI-02/TT-MOB-03. |
| Arquitectura | Sí | Caso 12 (capas de `core/red`). |
| Seguridad negativa | Sí | Casos 01, 02, 08 y 13 (URL no permitida, release, redirecciones, tamaño, registros, datos reales). |
| Aceptación (ACC) | Sí | Cada criterio de Jira tiene caso: (a) → 11, (b) → 10, (c) → 07. |
| Integración / E2E | No | No hay backend publicado al que apuntar en el CI; el caso 10 cubre el cambio de URL con un servidor local. La captura de la pantalla en el emulador va como evidencia en el PR. |
| Mutación (MUT) | No (meta informativa) | No es `domain/` crítico; `mutation_test` aún no está activo (constitución §3). Se comprueba a mano que el caso 07 falla con un mock alterado (lo exige el propio caso). |
| Accesibilidad (A11Y) | No | No hay pantalla nueva; la de oficios ya tiene sus pruebas en TT-PRU-02 y no cambia. |
| Rendimiento, usabilidad | No | Tarea de infraestructura de 2 puntos. |

Cobertura mínima de la app: 50 % (AGENTS.md §5); no se bajan umbrales.

**Gates:** `AGENTS.md` §5 en lo que aplica a la app (`dart format`, `flutter analyze --fatal-infos`, `flutter test` verde, cobertura ≥ 50 %), `sdd_lint.py` y `sdd_lint.py --trace TT-MOB-08`, `codemap.py --check` (regenerar `docs/architecture` al agregar archivos), `check_exceptions.py`, `sync_agents.py --check`, `security-reviewer` LIBERA, `traceability-clerk` sin drift, `Memoria.md` al día e informe de `story-workflow` en el PR con «Uso de IA». Esta spec es un borrador: no se escribió ni ejecutó ninguna prueba ni línea de código.

**Decisiones propuestas** (de quien redacta; el líder las confirma o cambia):
- **D1 — Cómo se sirve la API simulada.** *Propuesta:* **en memoria, dentro de la app**, como una implementación de `ClienteApi` en `app/lib/core/red/simulada/`. Porqué: no agrega dependencias, no necesita levantar un proceso aparte ni configurar Android para texto claro, funciona igual en `flutter test`, en el CI y en el emulador, y los escenarios de error se eligen con `--dart-define`. Alternativas: (a) **servidor local** en Dart puro (`dart:io` `HttpServer`) en `app/tool/api_simulada/`: es HTTP de verdad y lo podría usar también el panel, pero hay que arrancarlo, usar `10.0.2.2` o `adb reverse` y permitir texto claro en el `debug` de Android; (b) **adaptador de `dio` en memoria** (`HttpClientAdapter`): encaja directo con el cliente generado de TT-MOB-03, pero exige agregar `dio` ahora, antes de que TT-MOB-03 lo evalúe. Si TT-MOB-03 se fusiona primero, (b) es la mejor opción y esta tarea la usaría.
- **D2 — Cliente HTTP de transición (conflicto con el principio 4).** Para que el criterio (b) «cambiar a la API real es solo cambiar la URL» se cumpla ya, hace falta algo que haga la petición real. *Propuesta:* `ClienteApiHttp` mínimo sobre `dart:io` `HttpClient` (GET y POST con JSON, tiempos límite, tope de 1 MiB, sin redirecciones, sin sesión), marcado como **de transición**, que TT-MOB-03 sustituye por `dio` y el cliente generado dentro del mismo `clienteApiProvider`. **Choca con el principio 4 de la constitución** («nadie escribe llamadas HTTP a mano») y con `AGENTS.md` §4; necesita que el líder lo acepte de forma explícita en la aprobación (y quede en `Memoria.md` con su fecha de retiro). Además, `oficios` todavía no está en el OpenAPI exportado (PR #31 sin fusionar), así que el cliente generado aún no podría llamarlo. Alternativa sin excepción: no escribir `ClienteApiHttp`; el caso 08 se elimina, el caso 10 se difiere a TT-MOB-03 y el criterio (b) queda cumplido solo en diseño (el proveedor ya distingue simulado y real) hasta que llegue el cliente generado.
- **D3 — Configuración de la URL.** *Propuesta:* solo `--dart-define` (`KNOCK_API_URL`, `KNOCK_API_ESCENARIO`), sin flavors de Android/iOS por ahora y **sin ninguna URL real en el repositorio** (no existe una todavía; el único entorno de Azure sale de `main`, constitución §9). Sin valor → simulado (fuera de release). La ficha de TT-MOB-03 habla de flavors dev/staging/prod; Staging ya no existe (constitución 2.2.0), así que si se quieren flavors los define TT-MOB-03. `KNOCK_API_URL` es el **origen** (esquema, host y puerto); las rutas `/api/v1/…` las pone cada repositorio, como en la §4.
- **D4 — Cómo se escriben los mocks.** *Propuesta:* como **texto JSON literal dentro de constantes de Dart** en `core/red/simulada/respuestas_simuladas.dart` (no como assets: no cambia `pubspec.yaml` y no se empaquetan archivos sueltos), con datos ficticios. El texto se decodifica con `jsonDecode` igual que una respuesta real. La selección del modo simulado va detrás de `kReleaseMode` constante, para que el compilador pueda quitar la simulación de la build release (no se verifica en esta tarea; ver límites).
- **D5 — Prueba que compara mocks con el contrato.** *Propuesta:* una **tabla versionada** `app/test/contrato/contrato_s4.json` escrita a mano desde la §4 (un subconjunto de JSON Schema: `type`, `required`, `properties`, `additionalProperties`, `nullable`, `maxLength`, `pattern`, `items`) con la fuente y el commit por endpoint, y un validador pequeño en la propia prueba (sin dependencias). No se pone en `contracts/` (es del contrato vendorizado y no se edita a mano). Cuando exista `contracts/openapi.v1.json`, la prueba pasa a leer los esquemas de ahí y la tabla se borra.
- **D6 — Pantalla de la maqueta.** *Propuesta:* la de **oficios** de TT-PRU-02, porque ya existe con sus cuatro estados y su spec dejó previsto el cambio en un solo proveedor. `OficiosRepositoryDePrueba` **se conserva** sin cambios porque lo usa la prueba `TC-TT-PRU-02-07` (spec Aprobada); solo deja de estar en el proveedor. Borrarlo queda para cuando se cierre TT-PRU-02 o llegue TT-MOB-03.
- **D7 — Errores 4xx y 5xx.** *Propuesta:* traducción mínima por estado en `data/`: red, tiempo agotado y `5xx` → `ServicioNoDisponibleFailure`; `4xx` → `SolicitudRechazadaFailure { estado }` (subtipo nuevo del `Failure` sellado; la pantalla de oficios ya trata cualquier error igual); cuerpo fuera de contrato → `DatosInvalidosFailure`. La lectura de ProblemDetails y el catálogo de mensajes son de TT-MOB-03.
- **D8 — Relación con TT-MOB-03 (no duplicar).** `clienteApiProvider` es el único punto de inyección. TT-MOB-03 decide si la simulación pasa a ser un adaptador de `dio` que reutiliza las mismas respuestas y la misma prueba de contrato, y si los repositorios pasan de `ClienteApi` a los métodos del cliente generado (ese cambio sí toca `OficiosRepositoryApi`; el criterio «solo cambia la URL» se refiere a simulado ↔ real, no a la migración al cliente generado).
- **D9 — Endpoints simulados.** Los tres que cita Jira. `GET /api/v1/me` (también en la §4 de TT-API-02) y `archivos/*` quedan fuera hasta que una pantalla los necesite.
- **D10 — Ruta con versión.** Se usa `/api/v1/…` como dice la §4; el `v{version}` del OpenAPI exportado es un detalle de la generación que resolverá TT-CI-02/TT-MOB-03.
- **D11 — Backend local por HTTP en el emulador.** Android bloquea el texto claro por defecto; apuntar a `http://10.0.2.2:<puerto>` necesitaría un `network_security_config` solo para `debug`. *Propuesta:* fuera de esta tarea (no hace falta para la simulación); si alguien lo necesita, va en una tarea propia o en TT-MOB-03.
- **D12 — Escenario por `--dart-define` y en pruebas.** En la app el escenario es global (uno por ejecución); en pruebas, `ClienteApiSimulado` acepta el escenario por constructor o por un proveedor sobreescribible, para poder cambiarlo entre la primera petición y Reintentar (caso 11).

**Límites conocidos:**
- La prueba de contrato compara contra una tabla escrita a mano desde la §4: si una spec del backend cambia su §4 y nadie actualiza la tabla, la prueba no lo detecta. El commit de origen en cada fila hace visible la desactualización, y la automatización es TT-CI-02.
- Dos de los tres contratos (TT-PRU-01 y TT-API-07) son de PR sin fusionar; si cambian antes de fusionarse, se ajustan la tabla y los mocks.
- No se verifica que la simulación quede fuera de la build release (habría que inspeccionar el APK release; el CI solo compila `debug`).
- `ClienteApiHttp` usa `dart:io`: no sirve para web (la app es solo móvil).

**Dudas abiertas para el líder** (con propuesta; no están decididas):
1. **D2:** ¿se acepta el cliente HTTP de transición como excepción temporal al principio 4, con retiro en TT-MOB-03? *Propuesta:* sí, anotado en la aprobación y en `Memoria.md`; si no, se aplica la alternativa de D2 y se ajustan los casos 08 y 10.
2. **D1:** ¿en memoria (propuesta), servidor local o adaptador de `dio`? ¿Y el orden con TT-MOB-03 (misma persona, mismo sprint)? *Propuesta:* esta tarea primero, en memoria; TT-MOB-03 la adapta.
3. **D3:** ¿solo `--dart-define` o flavors desde ahora? ¿Sin URL → simulado en debug (propuesta) o exigir siempre `KNOCK_API_URL=simulada` explícito?
4. **D6:** ¿se conserva `OficiosRepositoryDePrueba` (propuesta) o se borra y se adapta la prueba `TC-TT-PRU-02-07`?
5. **D7:** ¿se agrega `SolicitudRechazadaFailure` ahora o se espera a TT-MOB-03?
6. **Revisor:** la spec no tiene revisor asignado; debe aprobarla una persona distinta del autor.

## Aprobación
- [ ] Revisor 1 — nombre: ________ fecha: ________
- [ ] Sin conflicto con la constitución (pendiente de D2: excepción al principio 4)
- **Estados:** Borrador (agente) → Aprobada (persona; habilita el código) → Firmada (tras el merge)
