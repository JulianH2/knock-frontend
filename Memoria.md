# Memoria — knock-frontend

> Registro del proyecto: estado, decisiones con su fecha y su porqué, y errores a evitar. Los agentes la leen al empezar y agregan una entrada al terminar cada cambio. Sin datos sensibles.

## Estado actual
- Constitución `1.0.0` en borrador, `AGENTS.md`, subagentes y skills creados.
- 12 specs de la base (arquitectura, estructura del repositorio, infraestructura, rendimiento, observabilidad, versionamiento y seguridad) redactadas en **Borrador**; sus tareas **no se han ejecutado**.
- Sin código de producto todavía.

## 2026-10-27 — Aclaración de «Uso de IA»
- **Decisión:** la sección «Uso de IA» es del **pull request** (plantilla de PR), no de cada spec.
- **Porqué:** `@constitution-reviewer` marcó FAIL a la spec 001 por leer «todo cambio» de forma literal; la redacción era ambigua.
- **A evitar:** copiar «Uso de IA» dentro de las specs para que pase una revisión.

## 2026-10-27 — Definición de la base
- **Decisión:** el repositorio se construye con SDD; la primera etapa solo define la base y no incluye funcionalidad.
- **Porqué:** así la arquitectura y la infraestructura quedan decididas y revisadas antes de escribir la primera línea de negocio.
- **A evitar:** empezar a codificar funciones antes de que la base esté aprobada.

## 2026-10-27 — Arquitectura
- **Decisión:** **Un repositorio con tres partes independientes:** `app/` (Flutter), `panel/` (Angular) y `landing/` (sitio estático), más `contracts/` con el OpenAPI del backend.
- **Porqué:** ver `specs/001-*/spec.md` (sección Decisiones) y `docs/descripcion-del-proyecto.md`.

## 2026-10-27 — Infraestructura y escalabilidad
- **Decisión:** **La infraestructura de la nube vive en `knock-backend`;** este repositorio consume la API por su contrato OpenAPI y no crea recursos de Azure.
- **Porqué:** ver las specs de infraestructura y escalabilidad y `docs/descripcion-del-proyecto.md`.

## 2026-11-03 — Alcance de ML e IA en la app
- **Decisión:** el aprendizaje automático (ML) no es prioridad. La IA generativa será una sola función sencilla en la app, solo si Azure ya da acceso al servicio; no se invierte más en ella. No hay base de grafos: MongoDB y Redis cumplen el requisito de NoSQL.
- **Porqué:** costo cero, tiempo hasta diciembre y la cuota de Azure OpenAI de la suscripción.
- **A evitar:** escribir que el ML «se quita»: es no prioritario, no eliminado.

## 2026-11-03 — Rulesets básicos
- **Decisión:** se definieron rulesets básicos de GitHub en `.github/rulesets/` (ramas `main` y `develop` y etiquetas de versión). El profesor dijo que compartiría los suyos en una imagen; no llegó.
- **Porqué:** que ambos repositorios queden protegidos igual desde el primer día. Las comprobaciones obligatorias del CI se agregan con el spec de CI/CD.
- **A evitar:** afirmar que se aplican: en una organización gratuita no se hacen cumplir en repositorios privados.

## 2026-11-03 — Ruleset de `main` alineado con las capturas del profesor
- **Decisión:** `main.json` copia las reglas de su ruleset «Main Proteccion»: no borrar, sin force push, pull request con 1 aprobación, métodos Merge/Squash/Rebase, regla de comprobaciones obligatorias (lista vacía hasta que exista el spec de CI/CD) y revisión automática de Copilot. Se conservan dos reglas más estrictas (aprobaciones descartadas con commits nuevos e hilos resueltos) y el rol de administrador como excepción, que en el ruleset del profesor no existe.
- **Porqué:** el profesor pidió cumplir a la letra; la imagen ya llegó y reemplaza los básicos provisionales de la entrada anterior.
- **Pendiente:** «Additional approval for unattributed Copilot pull requests» no está en el JSON (parámetro sin confirmar); `copilot_code_review` y la lista vacía de comprobaciones se escribieron sin validar la importación en GitHub.
- **A evitar:** afirmar que se aplican: en una organización gratuita no se hacen cumplir en repositorios privados.

## 2026-11-04 — Spec 013: MCP del proyecto
- **Decisión:** se escribe, en Borrador, la spec de MCP que pidió el profesor al final de la secuencia (RP-72 y RP-16). Jira con el MCP oficial de Atlassian (OAuth por persona, sin tokens en el repositorio), GitHub con la CLI `gh`, y solo lectura por defecto.
- **Porqué:** hoy el repositorio no tiene MCP configurado y el uso en el equipo es personal; sin spec no hay reglas de permisos ni de secretos.
- **Pendiente:** confirmar la dirección oficial y las herramientas del servidor de Atlassian al implementar; decidir si se usa MongoDB o el MCP de Dart; Figma queda descartado porque el equipo no lo usa.
- **A evitar:** guardar tokens en la configuración o permitir escritura en Jira desde un agente sin aprobación.

## 2026-11-04 — Revisión de todas las specs antes de la firma
- **Decisión:** se revisaron las specs de arquitectura y de endpoints con comprobaciones automáticas (cada requisito y criterio tiene tarea; valores como 15 minutos, 30 días, 10 sesiones y 5 minutos coinciden entre specs) y se corrigieron las diferencias: la región West US ahora está en la spec 005, el frontend define `deviceId` y la aceptación del aviso (spec 009), y las specs de MCP cubren todos sus requisitos con tareas.
- **Porqué:** el frontend y el backend se contradecían en el contrato de inicio de sesión, y una spec afirmaba una región que la otra no fijaba.
- **Pendiente (decide una persona):** `Idempotency-Key` (el frontend lo consume y el backend no lo define), el comportamiento ante 429 y `Retry-After`, y cancelar por `jti` o `sid`. Las specs siguen en Borrador: las firma una persona.
- **A evitar:** darlas por aprobadas sin leer las dudas abiertas de la sección 9.

## 2026-11-04 — Dudas de las specs resueltas
- **Decisión:** se resolvieron las dudas abiertas para poder aprobar: cancelar sesiones por `sid` (no `jti`), una sola colección `sesiones` (no `refresh_tokens`), 429 con `Retry-After`, `Idempotency-Key` fuera de esta etapa, colonia validada siempre contra Mercado (503 si no responde), 409 en eliminación programada, 404 para sesión ajena, y MCP de MongoDB y de Dart sin activar.
- **Porqué:** las dudas bloqueaban la aprobación de las specs de sesión y de seguridad; cada decisión quedó en la sección 9 de su spec con el motivo.
- **Pendiente:** actualizar la hoja de endpoints del Excel (sesión ajena: 404) y la constitución al fusionarlas (`sid` en lugar de `jti`); avisar a Guillermo del cambio de HU-001.
- **A evitar:** dar estas decisiones por firmadas: las aprueba una persona al aprobar cada spec.

## 2026-11-04 — Una revisión de pares obligatoria
- **Decisión:** cada PR necesita una revisión de otra persona y la segunda es opcional; el Tech Lead puede aprobar sus propios PR, y su revisión es opcional si es urgente o no hay nadie disponible (anota el motivo). Los rulesets dejan de descartar aprobaciones por commits nuevos y de exigir hilos resueltos.
- **Porqué:** dos revisiones frenaban el flujo con cuatro personas; el profesor tampoco las exige en su ruleset.
- **A evitar:** que un agente apruebe o fusione: sigue prohibido.

## 2026-11-04 — El guardián y el linter reconocen las specs numeradas (KNOCK-219)
- **Decisión:** `knock-guard` y `sdd_lint` aceptan las carpetas de spec numeradas (`001-tema`) además de las `HU-`, `TT-` y `BUG-`; `sdd_lint --trace NNN` busca los criterios `CA-NN` de la spec en las pruebas por nombre (`CA_006_01`, `'CA-006-01'` o `CA_01`).
- **Porqué:** el guardián no encontraba ninguna de las 13 specs y bloqueaba todo cambio en `app/` y `panel/`; el mismo arreglo ya se hizo en el backend (PR #7).
- **Pendiente:** la cabecera `> **Jira:** KNOCK-N` en las specs (hasta entonces, `KNOCK_SPEC=<número>`), y que `ci-pr.yml` y `branch_rules.py` acepten también las specs numeradas.
- **A evitar:** pasar `KNOCK_SPEC` con un prefijo corto (`00`): resuelve en silencio la primera spec que coincida.

## 2026-11-04 — Spec 005: validador de ramas y commits al día, pruebas y flujo documentado (KNOCK-219)
- **Decisión:** `scripts/ci/branch_rules.py` acepta los ámbitos que el equipo ya usa (landing, deploy y scripts, además de app, panel, ci, docs…; fuente única `.agents/knock.json`) y un título de PR con ID opcional (`KNOCK-N · <título>`, o con HU-, TT-, BUG-, B-NNN o F-NNN); los hooks de `.githooks/` quedan ejecutables; se agrega `scripts/ci/test_branch_rules.py` (CA-01, CA-04); el README explica cómo compilar y probar; CONTRIBUTING, la plantilla de PR y `.github/rulesets/README.md` documentan la revisión de par, la aprobación del líder y el motivo (CA-06).
- **Porqué:** con `ENFORCE_BRANCH_RULES=true` los títulos de PR sin ID de spec o con B-/F-NNN y los ámbitos reales habrían fallado; los hooks sin permiso de ejecución no corrían en Linux/macOS. Mismo arreglo que el backend (PR #9).
- **Pendiente:** CA-02 (sin revisión no se fusiona) no se puede hacer cumplir mientras la organización sea gratuita y los repositorios privados; la spec 005 (R-02) dice que las ramas salen de `develop`, pero el flujo real sale de `sprint-XX` (la edita José); activar `ENFORCE_BRANCH_RULES=true` solo cuando los commits abiertos cumplan el encabezado de 100 caracteres; las pruebas del validador aún no corren en el CI.
- **A evitar:** relajar la clave KNOCK-N o la prohibición de atribución a IA; activar `ENFORCE_BRANCH_RULES` antes de revisar las ramas abiertas.

## 2026-11-04 — MCP del proyecto implementado (spec 013, KNOCK-227)
- **Decisión:** se configura un solo servidor MCP, el oficial de Atlassian (`https://mcp.atlassian.com/v1/mcp/authv2`, remoto, OAuth por persona), para leer Jira. Los archivos de Claude Code (`.mcp.json`), OpenCode (`opencode.json`), Codex (`.codex/config.toml`), Gemini (`.gemini/settings.json`) y VS Code (`.vscode/mcp.json`) se generan con `scripts/sync_agents.py`; las herramientas de escritura (Jira, Confluence, Compass) quedan denegadas y solo las de lectura de Jira permitidas. La lista aprobada está en `docs/mcp.md`. Sin Figma, sin MCP de GitHub (se usa `gh`), sin MCP de bases de datos ni de Dart.
- **Porqué:** RP-72 y RP-16; una escritura equivocada en Jira es difícil de revertir y los tokens no deben llegar al repositorio.
- **Pendiente:** T-04 (probar la consulta a Jira con y sin sesión) la hace una persona con OAuth; hasta entonces CA-02 y CA-05 son parciales. VS Code no filtra herramientas por archivo: se desmarcan a mano. La dirección y las herramientas se confirman con la documentación oficial de Atlassian. Búsqueda de secretos: `gitleaks` no estaba instalado; se usó el patrón de `.gitleaks.toml` con grep y no hubo hallazgos (el CI corre gitleaks).
- **A evitar:** editar a mano los archivos generados, guardar tokens en la configuración o permitir herramientas de escritura sin aprobación de una persona.

## 2026-11-04 — Landing: estructura, enlaces en el CI y textos legales en borrador (spec 004, KNOCK-218)
- **Decisión:** `landing/` ya existía de TT-WEB-01 (nginx sin root, cabeceras, `railway.json`, versión `landing-v1.0.0`); se completó con la ruta reservada `/eliminar-cuenta/`, un borrador de `/privacidad/` (versión 0.1, `noindex`, aviso visible de «Borrador por revisar») que solo afirma lo que dicen las specs aprobadas, `landing/tests/check_links.py` y el job `landing` del CI (pruebas, enlaces rotos y Gitleaks sobre `landing/`). Todo dato que ninguna spec fija quedó como `[POR COMPLETAR POR JOSÉ: ...]`. José autorizó `.github/**` solo para esta tarea.
- **Porqué:** la spec 004 pide rutas reservadas y que el proceso revise enlaces y claves; el texto legal queda fuera de su alcance, pero Google Play necesita una URL de política de privacidad.
- **Pendiente:** publicar en Railway (pasos de José en `landing/README.md`) y verificar CA-01 y CA-02; completar los marcadores y pasar a «vigente» antes de dar la URL a Google Play; decidir si el job `landing` entra en `needs` de `gate` (no se tocó para no chocar con KNOCK-225); la spec dice rama principal y el README sigue en `develop` por la excepción de la constitución §9; la spec 004 no menciona `/privacidad/simplificado/` ni los términos.
- **A evitar:** dar el borrador como política vigente, inventar correo, razón social o plazos, y declarar `add_header` dentro de un `location` de nginx.

## 2026-11-04 — Versionamiento por puntos: cálculo, etiqueta y tabla (KNOCK-225)
- **Decisión:** `scripts/ci/version.py` calcula la versión `X.Y.Z` y el `versionCode` (`X × 1 000 000 + Y × 10 000 + Z × 100 + n`) de `app`, `panel` y `landing`, con pruebas `CA_011_NN` en `scripts/ci/test_version.py`; el job `pr-points` de `ci-pr.yml` exige una etiqueta `puntos-<componente>-N` (exentas `release-please--*` y `dependabot/*`) y entra en las dependencias del `gate`; la tabla de puntos está en `CONTRIBUTING.md` §9 y el registro, en `docs/VERSIONES_PUBLICADAS.md` (a mano).
- **Porqué:** la spec 011 manda un cálculo reproducible y que un PR sin puntos no pase; es la misma lógica del backend (KNOCK-207), con otros componentes y con `versionCode`. El acarreo es a 10 (como en el backend) porque la spec no da otro umbral.
- **Pendiente:** T-03 (integrar versión, `versionCode` y etiqueta de Git en la publicación; depende de KNOCK-221), así que CA-04 solo queda probado en el script. Reconciliar `docs/VERSIONAMIENTO.md` (primera versión `0.1.0`, `versionCode` = número de ejecución) con la spec 011 (`1.0.0`, `versionCode` derivado). Las etiquetas `puntos-*` no existen en el repositorio y las crea una persona con permiso. `sdd_lint.py --trace 011` marca FALTA hasta que `test_globs` de `.agents/knock.json` incluya `scripts/ci/test_*.py`.
- **A evitar:** llevar el `versionCode` a mano o repetirlo (Google Play rechaza la subida); declarar puntos de menos para no subir de versión.

## 2026-11-05 — Contrato vendorizado y cliente Dart generado (spec 006, KNOCK-220)
- **Decisión:** se vendoriza en `contracts/openapi.v1.json` el contrato de **Identity** (`docs/openapi.identity.v1.json` de knock-backend, rama `sprint-03`, commit de la rama `d39bc18`, último commit del archivo `b6ddcf5`, SHA-256 `5767eb9d…`), no `docs/openapi.v1.json` del backend: ese archivo **no es la unión** de los servicios, es solo `Knock.Market.Api` (colonias y oficios). La app necesita hoy `POST /api/v1/auth/firebase`. Cuando el backend publique la unión (o el gateway), se reemplaza por ella.
- **Decisión:** el cliente Dart se genera con **openapi-generator-cli 7.27.0, generador `dart`** (serialización nativa y `package:http`, sin build_runner) en `app/packages/knock_api/`, con `python app/tool/generar_cliente_api.py` (`--check` para comprobar). El jar se descarga de Maven Central a `~/.cache/knock/` (o `KNOCK_TOOL_CACHE`) y se ejecuta solo si su SHA-256 coincide con el fijado en el script.
- **Porqué:** el generador no acepta OpenAPI 3.2 («attribute openapi is unexpected»); el script normaliza en memoria a 3.1.0 con dos reglas mecánicas (versión y uniones `[null, integer, string]` de ASP.NET → `[null, integer]` sin `pattern`; cualquier otra unión detiene la generación). Sin esa regla `ProblemDetailsStatus` salía vacío y no compilaba. `dart` se prefirió a `dart-dio` porque no exige build_runner ni código `.g.dart` y deja un resultado determinista. El script también quita los `// ignore:` que escribe el generador, porque `scripts/ci/check_exceptions.py` solo exime `app/lib/l10n/generado/` (el paquete está excluido del analizador).
- **R-04 sin tocar `.github/`:** el script escribe `app/packages/knock_api/.knock-manifest.json` (SHA-256 del contrato y de cada archivo); `app/test/api/cliente_generado_test.dart` lo compara en cada `flutter test`, que el CI ya corre. Para la regeneración completa, el líder debe agregar al workflow `python app/tool/generar_cliente_api.py --check` (necesita Java 11+) y `python -m unittest app/tool/test_generar_cliente_api.py`.
- **Red de la app:** `lib/core/red/` (`clienteApiProvider`, `authApiProvider`, `transporteHttpProvider`, `urlApiProvider`, `llamarApi`/`mapearErrorApi`). URL base por `--dart-define=KNOCK_API_URL=...` (solo `https`, o `http` a `localhost`/`127.0.0.1`/`10.0.2.2`). Errores → `Failure` tipados en `core/errores/failure.dart` (401, 403 `account_suspended`, 409, 400/413/422, 429, red y 5xx).
- **Dependencias evaluadas (versión fija):**
  - `http 1.6.0` (dart.dev, BSD-3-Clause; mantenido por el equipo de Dart; sin avisos en OSV): transporte del cliente generado.
  - `crypto 3.0.8` (dev; dart.dev, BSD-3-Clause; sin avisos en OSV): SHA-256 del manifiesto en la prueba.
  - `openapi-generator-cli 7.27.0` (herramienta, no entra a la app; Apache-2.0; OpenAPITools, publicaciones mensuales; jar de Maven Central verificado por SHA-256/SHA-1). El código generado depende de `collection`, `intl` y `meta` (dart.dev, BSD-3), ya presentes por Flutter.
- **Pendiente:** cliente TypeScript del panel (T-03); cablear el `--check` en el CI (lo hace el líder); los nombres de operación salen feos (`apiVversionAuthFirebasePost`) porque el contrato no trae `operationId`: pedirlo al backend.
- **A evitar:** editar `contracts/` o `app/packages/knock_api/` a mano; vendorizar `docs/openapi.v1.json` creyendo que es la unión; subir el generador sin cambiar su SHA-256 fijado.

## 2026-11-05 — Registro e inicio de sesión conectados (KNOCK-228)
- **Decisión:** se reutiliza el diseño aprobado en persona de la rama de KNOCK-43 (pantallas «Escribe tu celular» y «Escribe el código», validación de 10 y 6 dígitos, cuenta regresiva y redirect a `/entrar`) y se conecta: Firebase Phone Auth envía y verifica el SMS, el ID token se canjea con el cliente generado en `POST /api/v1/auth/firebase` y los tokens van a `flutter_secure_storage`. La lógica vive en `lib/core/sesion/` (sesión compartida por toda la app) y la feature `entrada` solo tiene validación, controlador y pantallas, así `arquitectura_entrada_test.dart` (sin `knock_api` ni almacenamiento en la feature) sigue igual.
- **Porqué:** el líder pidió que la app consuma la API desplegada el 2026-11-05; el canje es el contrato de la spec 015 del backend.
- **Spec:** KNOCK-228 no tiene spec propia en este repositorio; se trabajó con `KNOCK_SPEC=006` por autorización del líder. Se relaciona con las specs 001 y 006 y con B-015/B-016 del backend. **El líder debe decidir la spec de la tarjeta.**
- **Firebase sin configuración:** `google-services.json` no existe todavía (lo entrega el líder; está en `.gitignore`). Gradle aplica `com.google.gms.google-services` 4.5.0 solo si el archivo existe; `iniciarFirebase()` devuelve `false` si falla y la entrada muestra un mensaje claro. Fuera de un teléfono (escritorio, `flutter test`) no se inicia Firebase ni se lee el almacenamiento seguro. Se declara `INTERNET` en el manifiesto principal (release).
- **Privacidad:** `dispositivo` es solo «Android» o «iOS» (el nombre del teléfono puede llevar el nombre de la persona); `deviceId` es un UUID v4 en almacenamiento seguro; `SesionEmitida.toString()` y `SolicitudCodigo.toString()` no muestran tokens ni celular; nada se registra.
- **Dependencias evaluadas (versión fija; OSV sin avisos el 2026-11-05):**
  - `firebase_core 5.1.0` y `firebase_auth 7.0.1` (FlutterFire, Google; BSD-3-Clause; publicaciones frecuentes): SMS y verificación del celular. Traen `_flutterfire_internals` y los paquetes de plataforma de FlutterFire (BSD-3).
  - `flutter_secure_storage 11.2.0` (BSD-3-Clause; mantenido, millones de descargas): tokens en Keystore/Keychain. Trae `path_provider`, `jni_flutter` y `objective_c` (dart.dev/flutter.dev, BSD-3).
  - `uuid 4.5.3` (MIT; ya estaba en el lockfile como transitiva): `deviceId`.
  - Plugin de Gradle `com.google.gms.google-services 4.5.0` (Google, Apache-2.0): solo se aplica con el archivo de configuración.
- **Pendiente:** el archivo de Firebase y el SHA-1 en la consola; renovar el token y cerrar sesión (spec 016, B-016) e interceptor de 401; completar el perfil cuando `perfilCompleto = false` (spec 017); probar el recorrido real en el emulador con un número de prueba de Firebase; compilar el APK de depuración (no se compiló aquí por espacio en disco); los E2E de `integration_test/` usan una entrada ficticia.
- **A evitar:** guardar tokens en `shared_preferences` o en registros; mandar el nombre del teléfono en `dispositivo`; crear un `google-services.json` inventado; pedir el SMS sin el aviso aceptado.
