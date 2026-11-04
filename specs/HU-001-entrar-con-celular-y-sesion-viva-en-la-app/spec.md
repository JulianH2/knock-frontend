# HU-001 (app) — Entrar con mi celular y mantener la sesión viva: login y registro, perfil, renovación y cierre de sesión

> **Jira:** KNOCK-43 (HU-001, parte [Mobile]) · **Épica:** EP-01 · **Módulo:** Identity (app) · **Responsable:** por confirmar (la ficha de HU-001 es de Guillermo; la parte móvil de HU-002 y HU-004 es de Erick, hoy sin tokens) · **Sprint:** S3 (02/11 a 06/11/2026) · **Puntos:** 5 (los de la ficha de HU-001, que cubren todas sus capas; esta spec no suma puntos propios, ver §8, decisión 1) · **Capas:** Mobile
> **Repositorio:** knock-frontend · **Otra parte en:** knock-backend (spec `HU-001-entrar-con-celular-y-codigo-sms`, PR #75 cerrado sin fusionar, rama `feature/KNOCK-43-phone-login-code` conservada)
> **Rama:** `docs/KNOCK-43-app-login-session-spec` → PR a `sprint-02` (solo la spec; el código irá en otra rama cuando esta spec esté Aprobada)
> **Depende de:** TT-MOB-03 (KNOCK-38, cliente de Dart generado desde OpenAPI; **aún sin spec**), TT-MOB-08 (KNOCK-191, `ConfiguracionApi`; rama `chore/KNOCK-191-mock-api-from-contract` conservada), TT-MOB-01 (KNOCK-24, arquitectura), TT-FB-01 (KNOCK-28, Firebase con números de prueba, Listo) y, **en el backend**, HU-001 (fusionar y desplegar #75), HU-003 (`POST /auth/refresh`), HU-004 (`POST /auth/logout`) y HU-002 (`PUT /me/perfil`). Las tres últimas **no existen** en el contrato de `sprint-02` (§4 y §8).
> **Fuentes:** `specs/HU-001-entrar-con-celular-y-codigo-sms/spec.md` del repositorio knock-backend (rama de #75, §4) y su `docs/openapi.v1.json` · `docs/backlog/TT-MOB-03.md`, `HU-001.md` a `HU-004.md` · `app/lib/core/router/`, `app/lib/core/preferencias/`, `app/lib/features/cuenta/`, `app/lib/features/oficios/` · rama de TT-MOB-08 (`core/red/configuracion_api.dart`) · `Entregables/Checklist_Google_Play_demo.md` · documentación de Firebase Authentication (citada en §6)
> **Skills:** spec-first-writing, story-workflow, flutter-clean-architecture, testing-strategy-frontend, security-core, reuse-before-create, traceability
> **Estado:** Borrador

**Cómo leer esta spec.** Es la spec de **la demo**: una app que de verdad llama a la API desplegada. Reúne en un solo recorrido la parte móvil de cuatro historias (HU-001 entrar, HU-002 completar perfil, HU-003 renovar, HU-004 cerrar sesión) en su versión mínima. Lo que no existe todavía en el backend se declara como dependencia en §4 y §8; **esta spec no inventa contratos**. Todo lo marcado «propuesta» lo decide la persona que la aprueba.

## 1. Objetivo
Que una persona abra la app, **entre con su celular** (registro e inicio de sesión son el mismo flujo), complete su nombre la primera vez, vea que la sesión está viva (sus datos y la lista de oficios vienen de la API real), siga dentro al cerrar y abrir la app, y pueda **cerrar sesión**. La app usa la URL de la API de `--dart-define KNOCK_API_URL`; una compilación de release **nunca** usa datos simulados. El teléfono se verifica con Firebase Authentication usando **números de prueba** (sin SMS real) mientras Firebase siga en el plan gratuito.

**Terminada cuando:** en un teléfono con la compilación de release, con la API desplegada, un número de prueba entra, completa el perfil, ve «Mi sesión» con datos de la API, cierra la app y vuelve a entrar sin pedir el código, y al cerrar sesión regresa a la pantalla de entrada con el almacenamiento seguro vacío; y todos los casos de §2 pasan.

## 2. Historia y casos de prueba
**HU-001 (app)** — Como persona que usa Knock, quiero entrar con mi celular y que mi sesión siga viva, para no repetir el código cada vez y poder salir cuando yo quiera.

**Datos de prueba.** Números ficticios de prueba de Firebase (por ejemplo `+52 55 5555 0101`, con un código fijo que se configura en la consola; nunca un número real) y un `FirebasePhoneGateway` falso en las pruebas de widget. La API se simula en pruebas con un `ClienteAuth` falso que devuelve los códigos del contrato; la prueba de integración contra la API real se hace a mano en el teléfono (caso 14). Las pruebas se nombran con el caso: `testWidgets('TC-HU-001-01 …')`.

| Caso | Criterio (Dado / Cuando / Entonces) | Verificación |
|---|---|---|
| TC-HU-001-01 | (CA1, cuenta nueva) Dado un número de prueba sin cuenta, cuando pido el código, lo escribo y Firebase devuelve la sesión, entonces la app canjea el `idToken` con `POST /api/v1/auth/firebase` enviando `{ firebaseIdToken, deviceId, aceptaAviso: true }`, recibe `201` con `esNuevo: true` y `perfilCompleto: false` y me lleva a **Completar perfil**. | `test/features/identidad/entrar_test.dart` — `testWidgets('TC-HU-001-01 número nuevo entra y completa perfil')` |
| TC-HU-001-02 | (CA2, cuenta existente) Dada una cuenta existente, cuando entro con su número, entonces el canje responde `200` con `esNuevo: false` y voy directo a **Inicio** si `perfilCompleto` es `true`, o a Completar perfil si es `false`. | `…/entrar_test.dart` — `testWidgets('TC-HU-001-02 cuenta existente va a Inicio')` |
| TC-HU-001-03 | (Aviso de privacidad) Dada la pantalla de entrada, entonces el botón **Continuar** está desactivado mientras no marque la casilla del aviso; la casilla enlaza a `<KNOCK_LANDING_URL>/privacidad/` (se abre en el navegador, nunca dentro de la app); y el canje solo se hace con `aceptaAviso: true`. Nunca se envía `false`. | `…/entrar_test.dart` — `testWidgets('TC-HU-001-03 sin aceptar el aviso no se continúa')` |
| TC-HU-001-04 | (deviceId) Dada la primera ejecución, entonces se genera un UUID v4 de 36 caracteres, se guarda en el almacenamiento seguro y se reutiliza en cada canje y renovación; no se regenera al cerrar sesión. El `deviceId` solo viaja en el cuerpo del canje (no en la URL, encabezados ni registros). | `test/core/sesion/dispositivo_test.dart` — `test('TC-HU-001-04 el deviceId se genera una vez y se reutiliza')` |
| TC-HU-001-05 | (Errores del canje) Dados los errores del contrato, entonces la app muestra un mensaje del catálogo ARB y **nunca** el `detail`, la traza ni el token: `401` «el código no es válido o venció»; `403` con `code: account_suspended` «tu cuenta está suspendida»; `409` con `code: account_conflict` «este celular ya está asociado a otra cuenta»; `422` el error junto al campo; `429` «espera un momento» (usando `Retry-After`); y sin red «sin conexión, reintenta». | `…/entrar_test.dart` — `testWidgets('TC-HU-001-05 errores del canje con mensajes seguros')` (Theory) |
| TC-HU-001-06 | (Almacenamiento seguro) Dada una sesión iniciada, entonces el `refreshToken` y el `deviceId` están solo en el almacenamiento seguro (`flutter_secure_storage`, Keystore); el `accessToken` vive solo en memoria; `shared_preferences` conserva **exactamente** las dos claves de HU-052 y ningún token, número ni nombre; y ninguna cadena con forma de token sale a los registros. | `test/core/sesion/almacen_sesion_test.dart` — `test('TC-HU-001-06 los tokens solo están en el almacén seguro')` |
| TC-HU-001-07 | (Sesión viva) Dado un `refreshToken` guardado, cuando cierro y abro la app, entonces entra directo a Inicio sin pedir el código (la app renueva en silencio al arrancar); y sin `refreshToken` abre en la pantalla de entrada. | `test/features/identidad/arranque_test.dart` — `testWidgets('TC-HU-001-07 la sesión sigue viva al reabrir')` |
| TC-HU-001-08 | (HU-003, renovación) Dado un `accessToken` vencido, cuando una llamada responde `401`, entonces el interceptor llama **una sola vez** a `POST /api/v1/auth/refresh` aunque haya varias llamadas en paralelo (las demás esperan), reintenta la llamada original con el token nuevo y guarda el `refreshToken` nuevo; si la renovación falla (`401` o `403`), limpia la sesión y manda a la pantalla de entrada. | `test/core/red/interceptor_sesion_test.dart` — `test('TC-HU-001-08 renueva una sola vez y reintenta')` |
| TC-HU-001-09 | (HU-004, cerrar sesión) Dada una sesión iniciada, cuando elijo **Cerrar sesión** en Mi cuenta y confirmo en el diálogo, entonces la app llama a `POST /api/v1/auth/logout` con el `refreshToken`, borra el almacenamiento seguro y la caché y regresa a la entrada, **también si la llamada falla o no hay red** (la limpieza local no depende del servidor); si cancelo el diálogo no pasa nada. | `…/cerrar_sesion_test.dart` — `testWidgets('TC-HU-001-09 cierra sesión aunque falle la red')` |
| TC-HU-001-10 | (HU-002, completar perfil) Dado que `perfilCompleto` es `false`, cuando escribo mi nombre (1 a 60 caracteres sin espacios sobrantes) y toco Listo, entonces la app llama a `PUT /api/v1/me/perfil`, y al `200` voy a Inicio; un nombre vacío o de más de 60 no se envía; y no puedo salir de esta pantalla a otras sin completar (solo Cerrar sesión). | `…/completar_perfil_test.dart` — `testWidgets('TC-HU-001-10 completar el perfil es obligatorio')` |
| TC-HU-001-11 | (Mi sesión, demo) Dada una sesión iniciada, cuando abro **Mi cuenta → Mi sesión**, entonces veo mi identificador acortado (primeros 8 caracteres) obtenido de `GET /api/v1/me` y la lista de oficios de `GET /api/v1/oficios` (reutiliza `features/oficios`, con el repositorio real en vez del de prueba); un `401` dispara la renovación del caso 08. | `…/mi_sesion_test.dart` — `testWidgets('TC-HU-001-11 Mi sesión muestra datos de la API')` |
| TC-HU-001-12 | (Configuración de red) Dada una compilación **release**, cuando `KNOCK_API_URL` falta, está vacía o no es `https`, entonces la app no arranca la entrada y muestra «app mal configurada» (nunca simulación); y el `AndroidManifest.xml` de `main` declara `android.permission.INTERNET`. Reutiliza `ConfiguracionApi` de TT-MOB-08. | `test/core/red/configuracion_api_test.dart` — `test('TC-HU-001-12 release exige URL https')` y `test/android/manifiesto_test.dart` |
| TC-HU-001-13 | (Seguridad de la verificación) Dado el flujo de código, entonces el número y el código de Firebase nunca se escriben en registros ni en `SharedPreferences`; los errores de Firebase (`invalid-verification-code`, `too-many-requests`, `network-request-failed`) se convierten en mensajes del catálogo; y tras 3 códigos incorrectos seguidos la app pide esperar 30 s antes de otro intento. | `…/codigo_test.dart` — `testWidgets('TC-HU-001-13 errores de Firebase sin fugas')` |
| TC-HU-001-14 | (Integración real, a mano) Dado el teléfono, la compilación de release y la API desplegada, cuando un número de prueba entra, completa el perfil, cierra la app, la abre y cierra sesión, entonces cada paso funciona contra la API real y el servidor registra el canje, la renovación y el cierre. | (comando) captura o video del recorrido y la salida de `curl -s -o /dev/null -w "%{http_code}" <URL>/health`; lo hace una persona con el teléfono |
| TC-HU-001-15 | (Cadena de suministro) Dado el trabajo terminado, entonces `app/pubspec.yaml` solo agrega `firebase_core`, `firebase_auth`, `flutter_secure_storage`, `dio` y `uuid` más lo que genere el cliente de TT-MOB-03; cada uno con restricción `^` y versión exacta en `pubspec.lock`; su evaluación (licencia, editor, mantenimiento, OSV, transitivas) está en `Memoria.md` y en el PR; y el SCA pasa (si pide sumar licencias a `allow-dependencies-licenses`, es cambio protegido que autoriza el líder). | (comando) `cd app && flutter pub get && flutter pub deps --no-dev` y el CI del PR |
| TC-HU-001-16 | (Accesibilidad y textos) Dadas las pantallas de entrada, código, perfil, Mi sesión y el diálogo, entonces todo texto sale de `app_es.arb` y `app_en.arb` con prefijo `entrar…`, `perfil…`, `sesion…`; los campos tienen etiqueta y error asociado; los botones cumplen `androidTapTargetGuideline`; y el texto al 200 % no desborda. | `…/accesibilidad_identidad_test.dart` — `testWidgets('TC-HU-001-16 accesibilidad de identidad')` |
| TC-HU-001-17 | Dado el trabajo terminado, entonces formato, análisis, generados de `gen-l10n` al día y pruebas pasan sin avisos, con cobertura ≥ 50 %, y las pruebas de TT-MOB-01, TT-MOB-02, HU-052 y TT-PRU-02 siguen en verde. | (comando) `cd app && dart format --set-exit-if-changed lib test && flutter analyze && flutter test --coverage` |

## 3. Alcance / No-alcance
- **In (este repositorio, `app/`):**
  - Pantallas: Entrar (teléfono +52 y casilla del aviso), Código, Completar perfil, Mi sesión (dentro de Mi cuenta) y el diálogo de cerrar sesión.
  - `features/identidad/` (data, domain, presentation) y `core/sesion/` (almacén seguro, `deviceId`, estado de sesión), `core/red/` (reutiliza `ConfiguracionApi`; cliente de TT-MOB-03 con interceptor de sesión).
  - Redirección del router: sin sesión → Entrar; con sesión y perfil incompleto → Completar perfil.
  - Permiso `INTERNET` en el manifiesto principal; textos ARB es/en.
  - Reutiliza `features/oficios` cambiando el repositorio de prueba por el real.
- **Out:**
  - SMS real y Firebase con costo (en espera por decisión del líder); App Check y regiones de SMS (KNOCK-146).
  - El backend: HU-001, HU-002, HU-003 y HU-004 ([Back]); esta spec solo los consume.
  - Foto de perfil, explorar sin cuenta (HU-005), mapa y cualquier pantalla de Mercado.
  - La firma de la app, el AAB y la ficha de Google Play (checklist aparte).
  - Cambio de número, varias sesiones por dispositivo (spec 018 de la otra base) y revocación `jti` frente a `sid` (decisión de migración del líder).

## 4. Contratos API y eventos
La app consume el contrato del backend; **no lo define**. Fuente de cada fila:

| Endpoint | Estado hoy | Contrato que usa la app |
|---|---|---|
| `POST /api/v1/auth/firebase` | Spec en la rama `feature/KNOCK-43-phone-login-code` (PR #75, **cerrado sin fusionar**); en `sprint-02` solo existe la forma del spike | Cuerpo `{ firebaseIdToken (1 a 4096), deviceId (UUID de 36), aceptaAviso: true }`; `201` cuenta nueva y `200` existente con `{ accessToken, refreshToken, esNuevo, perfilCompleto }`; `401`; `403 account_suspended`; `409 account_conflict`; `413`/`400`; `422` por campo; `429` con `Retry-After`; `Cache-Control: no-store` |
| `GET /api/v1/me` | En `sprint-02` | `{ id }` (solo eso hoy) |
| `GET /api/v1/oficios` | En `sprint-02` | lista de `{ clave, nombre, modalidad }` |
| `POST /api/v1/auth/refresh` | **No existe** (ficha de HU-003) | **Por confirmar**: cuerpo con el `refreshToken` y el `deviceId`; respuesta como `SessionResponse`; `401`/`403` si está revocado o reutilizado |
| `POST /api/v1/auth/logout` | **No existe** (ficha de HU-004: «revoca la familia del dispositivo») | **Por confirmar**: cuerpo con el `refreshToken`; `204` |
| `PUT /api/v1/me/perfil` | **No existe** (ficha de HU-002) | **Por confirmar**: cuerpo `{ nombre }`; `200` |

Errores en `application/problem+json`. **Regla de esta spec:** las tres filas «por confirmar» no se programan hasta que la spec de backend correspondiente esté Aprobada y publique su contrato; mientras tanto la app solo puede llevar el recorrido hasta el canje (casos 01 a 07 y 11). Eventos: ninguno.

## 5. Modelo de datos
Sin base de datos. Datos locales (§6):
- **Almacenamiento seguro (`flutter_secure_storage`):** `knock.sesion.refresh` (texto) y `knock.dispositivo.id` (UUID v4). Nada más.
- **Memoria:** `accessToken` (solo vive en el proceso), estado de sesión (`sinSesion`, `perfilIncompleto`, `activa`) y `perfilCompleto`.
- **`shared_preferences`:** no se toca (HU-052 guarda solo tema e idioma).
- **Firebase:** el usuario de Firebase vive en el SDK; la app solo lee de él el `idToken` para el canje y no lo guarda.

## 6. Seguridad, privacidad y amenazas
| Amenaza | Control | Caso que lo prueba |
|---|---|---|
| Robo o fuga de tokens (registros, preferencias, copias de seguridad) | `refreshToken` solo en Keystore; `accessToken` solo en memoria; ningún token en `shared_preferences` ni en registros; `android:allowBackup` sin datos de sesión | TC-HU-001-06 |
| Mostrar detalles internos al usuario | Mensajes del catálogo; nunca `detail`, traza ni token | TC-HU-001-05, 13 |
| Aceptar el aviso por omisión | Casilla obligatoria y `aceptaAviso: true` solo con ella marcada | TC-HU-001-03 |
| Usar el `deviceId` como control de seguridad | Solo identifica la instalación (la API tampoco lo autentica); viaja solo en el cuerpo | TC-HU-001-04 |
| Carreras de renovación y sesión que no se cierra | Una renovación a la vez con cola; la limpieza local no depende del servidor | TC-HU-001-08, 09 |
| Datos simulados presentados como reales | Release exige `https` y URL real; nunca simulación | TC-HU-001-12 |
| Tráfico en claro | Solo `https` en release; sin `http` ni certificados propios | TC-HU-001-12 |
| Repetición de códigos y abuso del SMS | Tras 3 errores, espera de 30 s; límite del servidor (`429`) | TC-HU-001-13, 05 |
| Paquetes con licencia o vulnerabilidad | Evaluación por paquete, SCA y OSV | TC-HU-001-15 |

**Firebase (citas, consultadas el 2026-11-03).** La documentación de Firebase Authentication (`firebase.google.com/docs/auth/flutter/phone-auth` y `…/web/phone-auth`) indica que en la consola, proveedor «Phone», sección «Phone numbers for testing», se agregan números ficticios con su código (ejemplo `+44 7444 555666` / `123456`); que «puedes agregar hasta 10 números para desarrollo»; que con ellos «no se envía ningún SMS», no se consume la cuota y no hay límite por repetición; que en Android hay que registrar la huella SHA-1 de la app; y que para los proyectos nuevos la política de regiones de SMS por defecto no permite ninguna región. **La documentación consultada no dice** si los números de prueba funcionan en el plan gratuito (Spark) ni menciona el plan Blaze para ellos; hay que comprobarlo en la consola antes de la demo (§8, duda 3). Los dos últimos hechos son de la documentación, no de esta spec.

## 7. Pantallas
- **Entrar:** logotipo, campo de teléfono (+52, 10 dígitos), casilla «Acepto el aviso de privacidad» con enlace, botón Continuar.
- **Código:** seis dígitos, reenviar tras 30 s, errores del catálogo.
- **Completar perfil:** nombre y Listo; sin salida salvo Cerrar sesión.
- **Mi cuenta → Mi sesión:** identificador acortado y lista de oficios; además la entrada **Cerrar sesión** con diálogo de confirmación.
- Estados vacío, cargando y error en cada pantalla; claro y oscuro (TT-MOB-02); es/en (HU-052).

## 8. Pruebas, gates y límites
**Plan de pruebas:** pruebas de widget y de unidad con dobles de Firebase y de la API (casos 01 a 13, 16); prueba de contrato del cliente generado (la que exija TT-MOB-03); recorrido manual en el teléfono contra la API real (caso 14); comandos (15 y 17). **No hay** prueba que llame a Firebase real en el CI.
**Gates:** `AGENTS.md §5`: `sdd_lint.py --trace HU-001`, `sync_agents.py --check`, `codemap.py --check`, `check_exceptions.py`, formato, análisis, pruebas con cobertura ≥ 50 %, `gitleaks` limpio (sin `google-services.json` ni claves), `Memoria.md` al día y «Uso de IA» completo en el PR.

**Dependencias que bloquean la demo** (no son dudas: son hechos a resolver fuera de esta spec):
1. **HU-001 del backend no está fusionada** (PR #75 cerrado): sin ella la API desplegada solo tiene la forma vieja del canje. Hay que reabrirlo, unirlo con `sprint-02` (hay un choque con `docs/MIDDLEWARES.md` por `AuthNoStoreMiddleware`), obtener su revisión de par y fusionarlo.
2. **No existen** `POST /auth/refresh`, `POST /auth/logout` ni `PUT /me/perfil`. Sin ellos la app llega hasta entrar y ver «Mi sesión» (casos 01 a 07 y 11); los casos 08, 09 y 10 esperan a su spec de backend.
3. **TT-MOB-03 no tiene spec:** el cliente generado del contrato es requisito de la ficha («sin código HTTP escrito a mano») y el líder ya rechazó un cliente de transición en TT-MOB-08.
4. **La API tiene que estar desplegada** con URL pública `https` (Azure; Terraform en otra tarea).

**Decisiones propuestas** (las confirma la persona que aprueba; recomendación entre paréntesis):
1. **Una spec o cuatro.** (Recomendación: esta sola spec para la demo, con clave KNOCK-43; HU-002, HU-003 y HU-004 conservan sus claves KNOCK-44, 45 y 46 y sus specs completas en el Sprint 3. Lo más fiel a SDD sería una por historia, pero tardaría más.)
2. **Cliente HTTP.** (Recomendación: el cliente generado de TT-MOB-03 con `openapi-generator` (dart-dio) ejecutado en Docker sobre el `docs/openapi.v1.json` de HU-001, y su spec escrita antes del código; no un cliente `dio` a mano.)
3. **Firebase.** (Recomendación: números de prueba, hasta 10, sin SMS; confirmar en la consola que funcionan sin pasar a Blaze y apuntar la SHA-1 de depuración y la de la firma de Play. SMS real queda fuera mientras no se decida pagar.)
4. **`google-services.json` fuera del repositorio.** (Recomendación: ya está en `.gitignore`; cada persona lo descarga de su consola y el CI no compila Android con Firebase; la demo se compila en el equipo del responsable.)
5. **Dónde se guardan los tokens.** (Recomendación: `flutter_secure_storage` (BSD-3, repositorio `mogol/flutter_secure_storage`) solo para el `refreshToken` y el `deviceId`; el `accessToken` en memoria.)
6. **Paquetes nuevos y SCA.** (Cinco paquetes (`firebase_core` y `firebase_auth` BSD-3, `flutter_secure_storage` BSD-3, `dio` y `uuid` MIT; licencias de pub.dev del 2026-11-03). Es probable que el SCA vuelva a no reconocer `bsd-3-clause` como SPDX y haya que sumarlos a `allow-dependencies-licenses` como en #52: cambio protegido del líder.)
7. **Aviso de privacidad.** (Recomendación: enlace a `KNOCK_LANDING_URL/privacidad/`; hoy esa ruta dice «en preparación», y la regla R1 exige el aviso `vigente` antes de subir a Google Play.)
8. **Quién lo hace.** (Erick es el responsable móvil pero está sin tokens; la persona que lo implemente sigue las mismas reglas, con revisión de par.)
9. **Código de la historia en la rama.** (Recomendación: rama `feature/KNOCK-43-app-login-session` desde `sprint-02` cuando esta spec esté Aprobada; el PR #45 cerrado de TT-MOB-08 se reutiliza solo por `ConfiguracionApi`.)
**Límites conocidos:** el código fijo de los números de prueba es conocido por el equipo: no sirve para cuentas reales; el cierre de sesión local no invalida el `accessToken` vigente (hasta 15 minutos) y la revocación permanente es la del servidor; el interceptor no resuelve el choque `jti`/`sid` (decisión de backend).

## Aprobación
- [ ] Revisor 1 — nombre: ________ fecha: ________
- [ ] Sin conflicto con la constitución
- **Estados:** Borrador (agente) → Aprobada (persona; habilita el código) → Firmada (tras el merge)
