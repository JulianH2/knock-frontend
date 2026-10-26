# TT-WEB-02 — Páginas de aviso de privacidad y manejo de datos de usuario

> **Jira:** KNOCK-159 (vence 2026-10-30) · **Épica:** por confirmar en Jira (plan de adaptación, bloque «Móvil, landing y Play») · **Área:** WEB · Landing · **Responsable:** Erick Trejo Reséndiz (contenido legal: José Julián, líder; `docs/PLAN_ADAPTACION.md` «TT-WEB-02 … · J (contenido)») · **Sprint:** S2 (26/10–30/10/2026) · **Puntos:** 2 · **Capas:** Landing (sitio estático)
> **Repositorio:** knock-frontend · **Otra parte en:** — · **Depende de:** TT-WEB-01 (KNOCK-148, landing en Railway) · **Relacionadas:** TT-MOB-06 (aviso y permisos en la app, S3), TT-TIE-01 (KNOCK-52) y TT-TIE-03 (KNOCK-101, ficha y «Seguridad de los datos» de Google Play), HU-006 (KNOCK-104, eliminar cuenta), HU-001 (KNOCK-43, consentimiento al registrarse), HU-021 (KNOCK-79, consentimiento biométrico), HU-055 (KNOCK-127, derechos de acceso y corrección)
> **Ficha:** no hay ficha `.docx`; la fuente es el issue de Jira KNOCK-159 («Terminada cuando: páginas publicadas y enlazadas desde la landing y desde la app»; comentario «Reasignada por carga del Sprint 2 (ADR-005)»).
> **Fuentes:** constitución 2.2.0 §1, §4 (Landing), §6, §13, §14 y principios 5, 13 y 14 · `docs/PLAN_ADAPTACION.md` A10, C13, líneas TT-WEB-02 y TT-MOB-06, Ola 1 · `docs/decisiones/ADR-004`, `ADR-005`, `ADR-006` · `docs/referencia/DECISIONES.md` #4, #11, #22, §6 y §10 · `docs/referencia/FUNCIONES_Y_FLUJOS.md` §3.2–3.11, §4.2, §4.4, §6, §7.2, §7.4 · `docs/CUMPLIMIENTO_LINEAMIENTOS.md` filas 16d y 17 · `docs/VERSIONAMIENTO.md` (Landing) · fichas `docs/backlog/HU-001`, `HU-006`, `HU-021`, `HU-022`, `HU-055`, `TT-TIE-03`, `TT-OBS-01`
> **Skills:** spec-first-writing, story-workflow, security-core, testing-strategy-frontend, reuse-before-create, traceability
> **Estado:** Borrador

## 1. Objetivo
Publicar en la landing (Railway, HTTPS) las páginas legales que exigen la ley mexicana de datos personales y Google Play, con una **estructura fija y verificable**, para que:
- Google Play tenga la **URL pública de la política de privacidad** y la **URL web para pedir la eliminación de la cuenta** antes de pedir producción (PLAN_ADAPTACION C13; DECISIONES §6: «Google Play: la app debe ofrecer eliminar la cuenta… y además un enlace web»).
- La landing (TT-WEB-01) y la app (TT-MOB-06) enlacen siempre a las mismas URLs estables (constitución §14: «Aviso de privacidad y eliminar cuenta dentro de la app, enlazados a la landing»).
- El texto describa lo que la app **realmente** trata, según los documentos del repositorio (inventario de §5, con su fuente).

Este repositorio aporta **la estructura, las secciones obligatorias, el inventario de datos, las pruebas y la publicación**. **El texto legal lo redacta o aprueba José Julián** (líder); esta spec no lo inventa. Mientras el texto no esté aprobado, la página se publica marcada como **provisional** (§6, TC-07), nunca como aviso vigente.

Terminada cuando (Jira): las páginas están publicadas y enlazadas desde la landing y desde la app (el enlace desde la app se propone en TT-MOB-06; ver §8, decisión 2).

## 2. Historia y casos de prueba
**TT-WEB-02** — Tarea técnica (no es historia de usuario). Las pruebas automáticas revisan los archivos HTML del repositorio; lo publicado se verifica con comandos contra la URL real (salida en el PR).

| Caso | Criterio (Dado / Cuando / Entonces) | Verificación |
|---|---|---|
| TC-TT-WEB-02-01 | Dado el sitio desplegado en Railway, cuando se piden por HTTPS `/privacidad/`, `/privacidad/simplificado/` y `/eliminar-cuenta/`, entonces cada una responde 200 con `Content-Type: text/html`; y pedirlas por `http://` redirige (301 o 308) a `https://`. | (comando) `curl -sS -o /dev/null -w "%{http_code} %{content_type} %{url_effective}\n" https://<dominio>/<ruta>` por cada ruta y `curl -sSI http://<dominio>/privacidad/` (código y `Location`); salida pegada en el PR |
| TC-TT-WEB-02-02 | Dada la landing, cuando se revisa su HTML, entonces el pie de página de **todas** las páginas del sitio enlaza con rutas relativas al mismo origen a `/privacidad/` y a `/eliminar-cuenta/`, con texto de enlace descriptivo («Aviso de privacidad», «Eliminar mi cuenta y mis datos»); y en el sitio desplegado esos enlaces existen. | `landing/tests/test_paginas_legales.py` → `test_TC_TT_WEB_02_02_la_landing_enlaza_las_paginas_legales` · (comando) `curl -sS https://<dominio>/ \| grep -oE 'href="/(privacidad\|eliminar-cuenta)/"'` en el PR |
| TC-TT-WEB-02-03 | Dado el aviso integral (`/privacidad/`), cuando se analiza su HTML, entonces tiene **un** `h1` y todas las secciones obligatorias de §7 como `h2` con su `id` estable y en ese orden (responsable, datos tratados, datos sensibles, finalidades necesarias, finalidades voluntarias, cómo negarse, transferencias y encargados, alojamiento fuera de México, derechos ARCO, revocar consentimiento, limitar uso o divulgación, conservación y eliminación, cookies y analítica del sitio, menores de edad, cambios al aviso, contacto), y un índice con enlaces a cada `id`. | `landing/tests/test_paginas_legales.py` → `test_TC_TT_WEB_02_03_aviso_integral_tiene_las_secciones_obligatorias` |
| TC-TT-WEB-02-04 | Dada la página `/eliminar-cuenta/`, cuando se analiza su HTML, entonces menciona el nombre de la app tal como aparece en Google Play, tiene las secciones `id` «como-solicitar-en-la-app», «como-solicitar-sin-la-app», «que-se-borra», «que-se-conserva-y-por-cuanto-tiempo», «plazo-de-gracia» y «contacto», y **no** contiene ningún `<form>`, `<input>` ni `<script>` (no recoge datos). | `landing/tests/test_paginas_legales.py` → `test_TC_TT_WEB_02_04_eliminar_cuenta_cumple_lo_que_pide_google_play` |
| TC-TT-WEB-02-05 | Dado el aviso simplificado (`/privacidad/simplificado/`), cuando se analiza su HTML, entonces tiene las secciones `id` «responsable», «finalidades», «como-negarse» y un enlace a `/privacidad/` (aviso integral). | `landing/tests/test_paginas_legales.py` → `test_TC_TT_WEB_02_05_aviso_simplificado_remite_al_integral` |
| TC-TT-WEB-02-06 | Dada cada página legal, cuando se analiza su HTML, entonces muestra de forma visible, antes del primer `h2`, la **versión** del texto (`Versión N.N`) y la **fecha de última actualización** en un `<time datetime="AAAA-MM-DD">` válido y no posterior a la fecha de la prueba; y la versión de las tres páginas está declarada en `data-version` del `<html>` con el mismo valor que el texto visible. | `landing/tests/test_paginas_legales.py` → `test_TC_TT_WEB_02_06_version_y_fecha_visibles` |
| TC-TT-WEB-02-07 | Dada una página legal con `data-estado="borrador"` en el `<html>`, entonces muestra un aviso visible («Texto provisional: aún no es el aviso de privacidad vigente de Knock») como primer contenido de `<main>` y lleva `<meta name="robots" content="noindex">`; dada una página con `data-estado="vigente"`, entonces no contiene ningún marcador `[PENDIENTE` ni el aviso de provisional. Ningún otro valor de `data-estado` es válido. | `landing/tests/test_paginas_legales.py` → `test_TC_TT_WEB_02_07_texto_provisional_nunca_se_presenta_como_vigente` · (comando) en el PR, `curl -sS https://<dominio>/privacidad/ \| grep -o 'data-estado="[a-z]*"'` |
| TC-TT-WEB-02-08 | Dada cada página legal, cuando se analiza su HTML, entonces no carga recursos de terceros: ningún `<script>` (ni externo ni en línea), y todo `src`, `<link href>`, `srcset`, `@import` y `url()` del CSS apunta al mismo origen (rutas relativas); no hay `<iframe>`, fuentes de CDN ni etiquetas de analítica. Los enlaces `<a>` a sitios externos sí se permiten. | `landing/tests/test_paginas_legales.py` → `test_TC_TT_WEB_02_08_sin_recursos_de_terceros` |
| TC-TT-WEB-02-09 | Dada cada página legal, cuando se revisa su accesibilidad, entonces cumple WCAG 2.1 AA: `lang="es-MX"`, `<title>` propio, regiones `header`/`main`/`footer`, enlace «Saltar al contenido», encabezados sin saltos de nivel, enlaces con texto descriptivo; y la herramienta automática no reporta violaciones de las reglas `wcag2a`/`wcag2aa` (contraste ≥ 4.5:1 incluido) ni desplazamiento horizontal a 320 px de ancho. | `landing/tests/test_paginas_legales.py` → `test_TC_TT_WEB_02_09_estructura_accesible` · (comando) auditoría automática sobre las URLs publicadas (herramienta según §8, decisión 6) con su salida en el PR |
| TC-TT-WEB-02-10 | Dado el aviso integral, cuando se analiza la sección «datos-tratados», entonces existe un elemento con `data-categoria` por **cada** categoría del inventario de §5 (lista cerrada en la prueba), las sensibles (`ine-selfie`) están dentro de la sección «datos-sensibles», y las secciones «alojamiento-fuera-de-mexico» y «datos-sensibles» existen y no están vacías (constitución §6: datos en EE. UU. y consentimiento expreso para INE y selfie). | `landing/tests/test_paginas_legales.py` → `test_TC_TT_WEB_02_10_inventario_completo_en_el_aviso` |

**Por qué TC-07 y TC-10 son casos aparte:** no los pide Jira literalmente, pero son los controles de las dos amenazas más serias de esta tarea (§6): publicar un texto provisional como si fuera el vigente, y que el aviso omita un dato que la app sí trata.

## 3. Alcance / No-alcance
- **In (este repositorio):**
  - Tres páginas HTML estáticas en `landing/` (carpeta que fija la constitución §4 y `docs/VERSIONAMIENTO.md`), con el mismo estilo y hoja de estilos que defina TT-WEB-01:
    - `landing/privacidad/index.html` → `/privacidad/`: **aviso de privacidad integral** (secciones de §7).
    - `landing/privacidad/simplificado/index.html` → `/privacidad/simplificado/`: **aviso simplificado**, el que la app puede mostrar o enlazar al recabar datos (TT-MOB-06).
    - `landing/eliminar-cuenta/index.html` → `/eliminar-cuenta/`: **manejo de datos y eliminación de cuenta** (URL web de eliminación que pide Google Play).
  - Enlaces a `/privacidad/` y `/eliminar-cuenta/` en el pie de página de la landing (archivo de TT-WEB-01; se toca solo el pie).
  - Estructura (encabezados con `id` estables, índice, versión y fecha, estado borrador/vigente) y **marcadores `[PENDIENTE: …]`** donde va el texto del líder. El contenido de cada sección lo aporta el líder; el agente solo puede proponer redacción marcada como borrador.
  - Pruebas automáticas de estructura (`landing/tests/test_paginas_legales.py`, Python 3 con la biblioteca estándar, sin dependencias nuevas; §8 decisión 5) y verificación con comandos contra la URL publicada.
  - Despliegue de las páginas con el mismo mecanismo de TT-WEB-01 (Railway).
  - `Memoria.md`.
- **Out:**
  - **Redactar el texto legal definitivo:** lo redacta o aprueba José Julián (PLAN_ADAPTACION A10 y línea TT-WEB-02). Revisión por abogado: recomendada (DECISIONES §10), fuera de esta tarea.
  - El enlace y la pantalla del aviso **dentro de la app** (Mi cuenta → Legal, consentimientos y permisos): TT-MOB-06 (§8, decisión 2).
  - Un formulario web o endpoint para pedir la eliminación, y el flujo de eliminación en la app: HU-006 (KNOCK-104, Sprint 6). Esta página solo explica cómo pedirla.
  - Llenar la sección «Seguridad de los datos» (Data safety) y registrar las URLs en Play Console: TT-TIE-01/TT-TIE-03. Esta tarea entrega el inventario que se usa para llenarla.
  - Términos y condiciones (constitución §14 los pone en la landing; ninguna tarea del plan los tiene asignados; §8, duda 9).
  - Banner de consentimiento de cookies y Google Analytics de la landing: TT-WEB-01. Las páginas legales no cargan analítica (TC-08).
  - Versión en inglés de las páginas (§8, duda 10).
  - Registro de consentimientos y versión aceptada: HU-001 y HU-021 (backend y app).
  - Encabezados HTTP de seguridad (CSP, HSTS, `nosniff`) y dominio del sitio: configuración del servidor de TT-WEB-01.
  - Panel, app Flutter, contrato OpenAPI y clientes generados: no se tocan.

## 4. Contratos API y eventos
- **Sin endpoints ni eventos.** No consume `contracts/openapi.v1.json`.
- **Contrato público de URLs** (lo consumen la landing de TT-WEB-01, la app en TT-MOB-06 y Play Console en TT-TIE-01/03). Una vez aprobadas, estas rutas y sus `id` no cambian sin una spec nueva:

| Ruta | Página | `id` de ancla estables |
|---|---|---|
| `/privacidad/` | Aviso de privacidad integral | los 16 de §7 (p. ej. `/privacidad/#datos-sensibles`, `/privacidad/#derechos-arco`) |
| `/privacidad/simplificado/` | Aviso simplificado | `responsable`, `finalidades`, `como-negarse` |
| `/eliminar-cuenta/` | Manejo de datos y eliminación de cuenta | `como-solicitar-en-la-app`, `como-solicitar-sin-la-app`, `que-se-borra`, `que-se-conserva-y-por-cuanto-tiempo`, `plazo-de-gracia`, `contacto` |

- El dominio lo fija TT-WEB-01. La **versión del aviso** (`data-version`) es la que la app y el backend registran al pedir el consentimiento (HU-001: «registro del consentimiento (versión del aviso y fecha)»); por eso se ve en la página (TC-06).

## 5. Modelo de datos
Sin persistencia ni estado. Metadatos de cada página en el `<html>`: `lang="es-MX"`, `data-estado` (`borrador` | `vigente`) y `data-version` (`N.N`); en el contenido, `Versión N.N` y `<time datetime="AAAA-MM-DD">`.

**Inventario de datos personales que trata Knock según el repositorio** (base del aviso integral, de la página de eliminación y de la «Seguridad de los datos» de Google Play). Cada fila es una `data-categoria` de TC-10. **No es texto legal:** el líder decide cómo se redacta y confirma lo marcado «por confirmar».

| `data-categoria` | Dato | Para qué / con quién se comparte | Conservación y control | Fuente en el repositorio |
|---|---|---|---|---|
| `celular` | Número de celular (+52) | Crear la cuenta e iniciar sesión con código SMS de Firebase; se muestra al técnico elegido (WhatsApp) solo al aceptar su cotización | Cifrado a nivel de campo; un celular = una cuenta | Constitución §6 («celular cifrados», «SMS solo a números +52») · ADR-004 · FUNCIONES §3.2 y §3.6 («Al elegir se revela el teléfono/WhatsApp») · HU-001 |
| `perfil` | Nombre, foto de perfil (opcional), colonia y código postal | Mostrar el perfil y buscar expertos cercanos | Foto reducida a 320 px | FUNCIONES §3.2 (tabla de registro), §3.10 «Mis datos» |
| `ubicacion` | Ubicación del dispositivo (permiso opcional) | Calcular la colonia; **las coordenadas se descartan**; el mapa usa Google Maps para Flutter | Solo se guarda la colonia; dónde se convierte (teléfono o servidor) y qué recibe Google Maps: **por confirmar** | Constitución §6 («ubicación del dispositivo convertida en colonia y descartada») · FUNCIONES §3.3 («nunca las coordenadas») · DECISIONES #22 · FUNCIONES §7.2 |
| `direccion` | Calle y número (cliente) y dirección del taller (técnico) | Servicio a domicilio; se comparte con el técnico elegido; el técnico solo ve la colonia antes | Cifrada a nivel de campo | Constitución §6 · FUNCIONES §3.5, §3.6, §4.1 y §6 (Dirección «cifrada») · security-core #1 y #7 |
| `tecnico` | Negocio, oficios, taller o domicilio, radio, años, descripción, horarios, precios de referencia, fotos de trabajos | Perfil público del técnico y sección Explorar | Públicos mientras la cuenta exista | FUNCIONES §4.1, §3.9 y §6 (Técnico, Servicio) |
| `solicitudes` | Descripción del problema, fotos (1 a 5), día y horario, cotizaciones, citas y código de visita (hash) | Pedir y comparar cotizaciones; los técnicos de la zona ven la solicitud | Fotos moderadas antes de guardarse, sin EXIF, en almacenamiento privado con enlaces temporales | FUNCIONES §3.5, §3.6 y §6 · constitución principio 14 · security-core #9 |
| `mensajes` | Mensajes del chat y fotos adjuntas | Hablar con el técnico o cliente; moderados antes de guardarse | Se borran al eliminar la cuenta | FUNCIONES §3.8 · constitución principio 14 · HU-006 CA4 |
| `opiniones` | Calificaciones, comentario y hasta 3 fotos | Reputación pública del técnico | Al eliminar la cuenta se **anonimizan** («Usuario eliminado»), no se borran | FUNCIONES §3.7 · constitución §6 · HU-006 CA4 · DECISIONES #11 |
| `reportes` | Reportes, motivos, evidencias y decisiones | Seguridad y moderación | Se conservan **solo el tiempo que obligue la ley**; con reporte abierto, datos mínimos restringidos hasta resolver | Constitución §6 · HU-006 CA5 · DECISIONES §6 |
| `ine-selfie` | **Sensible:** INE (frente y, en verificación completa, reverso) y selfie; CURP solo como HMAC | Verificación de identidad opcional del técnico, revisada por una persona del equipo; **nunca** pasa por moderación automática ni por IA | Consentimiento expreso y separado; contenedor privado, cifrado con llave propia por verificación, enlaces de 5 min, registro de cada acceso; **se borran al decidir o a los 7 días**; queda solo el resultado | Constitución §6, principios 5 y 14 · HU-021 · HU-022 CA4 · security-core #8 · DECISIONES #4 y FUNCIONES §4.2 dicen 30 días (desactualizado; ver §8 duda 7) |
| `casa-auto` | Datos del auto (marca, modelo, año) y de la casa | Historial y solicitudes más precisas | Se borran al eliminar la cuenta | FUNCIONES §3.10 «Mi casa y mi auto» · HU-006 (maqueta: «casa y auto») |
| `contactos-confianza` | Nombre y número de un contacto que la persona elige avisar de una visita | Enviar por WhatsApp o SMS quién va y cuándo | La app no pide el permiso de contactos; si se guarda y cuánto tiempo: **por confirmar** | FUNCIONES §3.6 «Avisar a alguien de confianza» · constitución §14 |
| `notificaciones` | Token de notificaciones push (FCM) y preferencias de avisos | Avisos de solicitud nueva, cotización recibida y elegida, cita confirmada | El token se elimina al cerrar sesión | Constitución §14 (Push) · security-core #10 · HU-050 · ADR-004 |
| `sesion` | Tokens de sesión, sesiones y dispositivos, consentimientos aceptados (documento, versión, fecha, dispositivo) | Mantener la sesión y probar qué se aceptó | Refresh guardado como huella hasta 30 días; el cierre de sesión lo revoca | Constitución §3 (Acceso), principio 13, §14 · HU-001 · HU-021 CA2 · HU-055 |
| `ia` | Texto de solicitudes y conversaciones que se envía al asistente | Resumen y borrador de cotización con Azure OpenAI; la IA propone, la persona decide | Filtro de datos personales antes del modelo; nunca INE, CURP, dirección ni teléfono; ML.NET (orden y rango de precio) corre en el backend | Constitución principio 5 y §13 (IA) · FUNCIONES §4.4 y §7.2 · security-core #16 |
| `tecnicos-registros` | Dirección IP, registros de la API sin datos personales, errores de la app | Límite de peticiones por IP, diagnóstico y seguridad | Logs sin datos personales; Sentry en la app está **planeado** (TT-OBS-01); plazos de retención de logs: **por confirmar** | Constitución §6 (límite por IP) y §12 (observabilidad) · `docs/backlog/TT-OBS-01.md` · AGENTS.md §4 |
| `sitio-web` | Cookies y datos de navegación de la landing | Google Analytics **solo si la persona acepta las cookies**; registros del servidor de Railway | Las páginas legales no usan cookies ni analítica | Constitución §3 (Landing) y §14 · DECISIONES §10 doc. 8 |

**Proveedores que reciben datos (encargados o terceros; el líder decide cómo se clasifican):** Google (Firebase Authentication, Firebase Cloud Messaging, Google Maps, Google Analytics en la web, Google Play) · Microsoft Azure (Container Apps, Azure DocumentDB en West US, Blob Storage, Key Vault, Application Insights, Content Safety, Azure OpenAI) · Railway (landing) · Sentry (planeado, TT-OBS-01) · WhatsApp (solo cuando la persona decide continuar por ahí). Fuentes: constitución §3, §6 («los datos se alojan en Estados Unidos (Azure y Google)») y §13 (región West US) · ADR-004 · ADR-006.

**Respaldo:** `mongodump` diario a Blob (constitución §13, TT-BD-04); afecta a cuándo desaparece del todo un dato borrado (§8, duda 8).

## 6. Seguridad, privacidad y amenazas
Riesgo técnico bajo (páginas estáticas, sin formularios, sin datos de usuarios), pero **riesgo legal y de confianza alto**: el texto promete cosas sobre datos sensibles. STRIDE breve:

| Amenaza | Control | Caso que lo prueba |
|---|---|---|
| **Repudio / información engañosa:** se publica un texto provisional (escrito por el agente o con huecos) como si fuera el aviso vigente, y Google Play o una persona lo toman como definitivo | `data-estado="borrador"` muestra un aviso visible de texto provisional y `noindex`; solo el líder cambia a `vigente` (commit propio, nombre y fecha en el PR); `vigente` no admite marcadores `[PENDIENTE`; el agente no marca `vigente` | TC-TT-WEB-02-07 |
| **Información incorrecta:** el aviso omite un dato que la app sí trata (p. ej. ubicación, contactos de confianza) o contradice al sistema (INE 30 días frente a 7) | Inventario de §5 con fuente por fila; prueba de categorías completas; las contradicciones entre documentos se resuelven en §8 antes de aprobar; TT-TIE-03 llena «Seguridad de los datos» desde el mismo inventario | TC-TT-WEB-02-10 · TC-TT-WEB-02-03 |
| **Fuga de datos / rastreo:** scripts, fuentes o analítica de terceros en las páginas legales rastrean a quien lee el aviso (y antes de aceptar cookies) | Sin `<script>` y sin recursos de otros orígenes en las páginas legales; la analítica de la landing respeta el consentimiento (TT-WEB-01) | TC-TT-WEB-02-08 |
| **Alteración (cadena de suministro):** un recurso externo comprometido cambia el contenido de la página | Mismo control: todo se sirve desde el propio origen; CSP restrictiva del servidor (TT-WEB-01) | TC-TT-WEB-02-08 |
| **Suplantación / phishing:** la página de eliminación pide datos (código SMS, INE, contraseña) o enlaza a un formulario no oficial | La página no tiene formularios ni campos; dice explícitamente que Knock nunca pide el código SMS ni fotos del INE por correo; los canales son la app y el correo del proyecto | TC-TT-WEB-02-04 |
| **Fuga de datos del equipo:** el contacto o el domicilio del responsable expone datos personales de un integrante (correo o teléfono personal, domicilio particular) | Se usa el correo único del proyecto (constitución §9: «un solo correo del proyecto»); el domicilio y la identidad del responsable los decide el líder (§8, duda 1); revisión del diff antes del commit | Revisión de `security-reviewer` (check 7) |
| **Intercepción / contenido mixto:** la página se sirve por HTTP o carga algo por HTTP | HTTPS de Railway con redirección de HTTP; sin recursos externos | TC-TT-WEB-02-01 · TC-TT-WEB-02-08 |
| **Denegación:** el sitio cae y Google Play no puede revisar las URLs | Páginas estáticas sin dependencias; la comprobación de TC-01 se repite antes de cada envío a revisión de Play (TT-TIE-01/03) | TC-TT-WEB-02-01 |
| **Exclusión:** una persona con discapacidad no puede leer el aviso | WCAG 2.1 AA | TC-TT-WEB-02-09 |

Checks de `security-core` que aplican: #7 (datos sensibles: nada personal en las páginas ni en el repositorio), #12 (encabezados: los configura TT-WEB-01), #13 (secretos: no hay), #14 (sin dependencias nuevas). Los demás no aplican (sin API, sesión ni archivos).

## 7. Pantallas
Tres páginas web estáticas, sin JavaScript, con el estilo de la landing (TT-WEB-01). Estructura común: `header` (logo o nombre «Knock» y enlace a inicio), enlace «Saltar al contenido», `main` con `h1`, línea de **versión y fecha de última actualización**, índice (en el integral), secciones `h2` con `id`, y `footer` con enlaces a las otras páginas legales y la versión de la landing (`landing-vX.Y.Z`, `docs/VERSIONAMIENTO.md`).

**Estados:** `borrador` (aviso visible de texto provisional + `noindex`) y `vigente` (texto aprobado por el líder). No hay estados de carga, vacío ni error: son documentos estáticos.

**Aviso integral — secciones obligatorias en este orden** (`id` · qué debe decir · base). La lista sigue lo que DECISIONES §10 y FUNCIONES §7.4 piden revisar; **el líder confirma los elementos exactos contra el texto vigente de la ley publicada en el DOF el 20-mar-2025**:

| # | `id` | Contenido que aporta el líder | Base |
|---|---|---|---|
| 1 | `responsable` | Identidad y domicilio del responsable del tratamiento | LFPDPPP (aviso integral) · FUNCIONES §7.4 («razón social, domicilio, correo de privacidad») |
| 2 | `datos-tratados` | Datos por categoría (inventario §5, un elemento `data-categoria` por fila) | DECISIONES §10 doc. 1 · Google Play (política de privacidad: qué datos se recopilan) |
| 3 | `datos-sensibles` | INE y selfie: finalidad, consentimiento expreso, conservación (≤ 7 días), revisión humana, revocación | Constitución §6 · DECISIONES §10 doc. 4 · HU-021 |
| 4 | `finalidades-necesarias` | Finalidades que dan origen a la relación (no requieren consentimiento adicional) | DECISIONES §10 («finalidades con y sin consentimiento») |
| 5 | `finalidades-voluntarias` | Finalidades secundarias (promociones, encuestas, recomendaciones) | FUNCIONES §3.10 y §7.4 · HU-055 |
| 6 | `como-negarse` | Cómo negarse a las finalidades voluntarias | LFPDPPP |
| 7 | `transferencias-y-encargados` | Proveedores y con quién se comparte (incluido el técnico o cliente de un servicio) | DECISIONES §10 doc. 7 · Google Play (con quién se comparten los datos) |
| 8 | `alojamiento-fuera-de-mexico` | Datos alojados en Estados Unidos (Azure y Google) | Constitución §6 y §13 |
| 9 | `derechos-arco` | Acceso, rectificación, cancelación y oposición: medio, requisitos y plazos | FUNCIONES §7.4 · DECISIONES §10 pregunta 5 |
| 10 | `revocar-consentimiento` | Cómo revocar el consentimiento | LFPDPPP · HU-021 (revocación del biométrico) |
| 11 | `limitar-uso` | Opciones para limitar el uso o divulgación (p. ej. avisos y consentimientos opcionales en la app) | LFPDPPP · FUNCIONES §3.10 |
| 12 | `conservacion-y-eliminacion` | Plazos por tipo de dato y enlace a `/eliminar-cuenta/` | DECISIONES §10 doc. 6 · constitución §6 · Google Play (retención y eliminación) |
| 13 | `cookies-y-analitica` | Cookies del sitio web y Google Analytics con consentimiento | Constitución §14 · DECISIONES §10 doc. 8 |
| 14 | `menores-de-edad` | A quién va dirigida la app y edad mínima | FUNCIONES §7.4 («validar mayoría de edad») · Google Play (público objetivo) |
| 15 | `cambios-al-aviso` | Cómo se avisan los cambios y dónde ver la versión vigente | LFPDPPP · §4 (versión registrada en el consentimiento) |
| 16 | `contacto` | Correo de privacidad del proyecto (y medio para ARCO) | FUNCIONES §7.4 · constitución §9 (correo único) |

**Aviso simplificado:** `responsable`, `finalidades` (necesarias y voluntarias, resumidas), `como-negarse` y enlace al integral.

**Manejo de datos y eliminación de cuenta** (requisitos de Google Play para la URL de eliminación: nombre de la app o del desarrollador como en la ficha, pasos para pedirla, qué se borra y qué se conserva, y por cuánto tiempo; DECISIONES §6 y su enlace a la ayuda de Google Play):
- `como-solicitar-en-la-app`: Mi cuenta → Configuración → Eliminar mi cuenta, con lo pendiente, «Cancelar lo pendiente y eliminar» y código SMS (FUNCIONES §3.11, HU-006).
- `como-solicitar-sin-la-app`: canal web o correo para quien ya no tiene la app (§8, duda 3).
- `que-se-borra`: perfil y foto, historial, mensajes, dirección, casa y auto, técnicos de confianza (HU-006 CA4, FUNCIONES §3.11).
- `que-se-conserva-y-por-cuanto-tiempo`: opiniones anonimizadas; reportes y datos mínimos el tiempo que obligue la ley; hash de CURP de técnicos suspendidos (HU-006 §8); respaldos (§8, duda 8).
- `plazo-de-gracia`: 7 días con opción de cancelar al volver a entrar (constitución §6, HU-006 CA2–CA3).
- `contacto`.

**Textos:** español de México. **Accesibilidad:** WCAG 2.1 AA (TC-09): contraste ≥ 4.5:1, texto escalable al 200 % sin pérdida, sin desplazamiento horizontal a 320 px, foco visible, orden de lectura lógico, tablas con encabezados `th` si se usan.

## 8. Pruebas, gates y límites
**Plan de pruebas** (meta de mutación: N/A, no hay lógica de dominio):

| Tipo | ¿Aplica? | Motivo / herramienta |
|---|---|---|
| Unitarias (UM) | No | No hay lógica: son documentos HTML |
| Widget / componente (W) | No | No hay app ni panel en el cambio |
| Aceptación (ACC) | Sí | Cada caso con su ID en el nombre de la prueba (`test_TC_TT_WEB_02_KK_…`) o con su comando; pruebas sobre el HTML con `html.parser` de Python, sin red |
| Contrato (CON) | No | No consume la API; el «contrato» de URLs de §4 lo cubren TC-02 a TC-05 |
| Mutación (MUT) | No | Sin lógica de negocio |
| E2E | Sí (por comando) | TC-01, TC-02 y TC-07 contra el sitio publicado con `curl` |
| Usabilidad (USA) | No | Se cubre en las pruebas con usuarios de TT-QA-03/05; aquí basta la legibilidad de A11Y |
| Accesibilidad (A11Y) | Sí | TC-09: estructura en la prueba de Python + auditoría automática WCAG 2.1 AA sobre las URLs publicadas (decisión 6) |
| Seguridad negativa | Sí | TC-04 (sin formularios), TC-07 (sin provisional como vigente), TC-08 (sin terceros) |
| Compatibilidad | Parcial | Revisión manual en Chrome de Android y en un navegador de escritorio (captura en el PR) |
| Regresión visual | No | Sin herramienta en el repositorio para la landing |
| Rendimiento | No | Páginas estáticas pequeñas |

**Gates:** `AGENTS.md §5` no tiene todavía gates para `landing/` (los define TT-WEB-01). Para esta tarea: `python -m unittest discover -s landing/tests -v` en verde; comandos de TC-01, TC-02, TC-07 y TC-09 con salida en el PR; `sdd_lint.py`, `sdd_lint.py --trace TT-WEB-02` (ver decisión 5), `codemap.py --check`, `check_exceptions.py` y `sync_agents.py --check` en OK; `security-reviewer` LIBERA; `Memoria.md` al día; «Uso de IA» en el PR.

**Decisiones (propuestas por el agente; las confirma quien aprueba):**
1. **Carpeta y rutas:** `landing/` como dice la constitución §4 (el pedido inicial decía «una carpeta web»; manda la constitución), rutas en español sin extensión (`/privacidad/`, `/privacidad/simplificado/`, `/eliminar-cuenta/`) con `index.html` por carpeta, que cualquier servidor estático resuelve. **Se alinea con lo que se apruebe en TT-WEB-01** (stack, hoja de estilos, servidor y dominio); si TT-WEB-01 fija otra carpeta o generador, esta spec se ajusta antes de aprobarse.
2. **Enlace desde la app:** se propone que vaya en **TT-MOB-06** (S3, también de Erick) y no aquí. Porqué: Mi cuenta está vacía (solo el interruptor de prueba de TT-MOB-01); abrir una URL desde Flutter necesita `url_launcher`, una dependencia nueva que hay que evaluar (constitución §3); TT-MOB-06 ya es «aviso de privacidad y permisos en la app» y la matriz de cumplimiento (fila 16d) pone ambas tareas juntas; y meterlo aquí rompe el tope de 2 puntos. Esta tarea deja fijas las URLs (§4) que TT-MOB-06 usará. **Consecuencia:** el «Terminada cuando» de Jira («enlazadas… desde la app») no se cumple con esta tarea sola; el líder decide si ajusta el criterio en Jira o si se agrega aquí una fila mínima en Mi cuenta → «Aviso de privacidad» (+1 punto, evaluación de `url_launcher`, prueba de widget y cambios en `app/lib`).
3. **Versión del aviso:** `N.N` propia de cada texto legal, independiente de `landing-vX.Y.Z`; la primera vigente es `1.0`. Todo cambio de texto vigente sube la versión y la fecha; la app y el backend registran esa versión al pedir el consentimiento (HU-001, HU-021).
4. **Borrador publicado:** si Google Play necesita la URL antes de que el líder apruebe el texto, se publica con `data-estado="borrador"` y su aviso visible (TC-07). El agente nunca cambia el estado a `vigente`.
5. **Pruebas en Python con la biblioteca estándar** (`unittest` + `html.parser`) en `landing/tests/`, sin `npm` ni paquetes nuevos (el CI ya tiene Python). **Problema:** `.agents/knock.json` → `test_globs` no incluye `landing/tests/**`, así que `sdd_lint.py --trace TT-WEB-02` dirá FALTA; y el job `detect` de `ci-pr.yml` solo mira `app/` y `panel/`, así que el CI no corre estas pruebas ni la trazabilidad. Propuesta: que TT-WEB-01 (o el Tech Lead, porque `scripts/` y `.github/` están protegidos) agregue `landing/tests/**/*.py` a `test_globs`, `landing/**` a `code_dirs` (para que el guardián exija spec aprobada) y un job `landing` en `ci-pr.yml`. Si TT-WEB-01 elige otra herramienta de pruebas, estas se escriben con ella.
6. **Auditoría de accesibilidad:** la hace la herramienta que adopte TT-WEB-01; si no adopta ninguna, Lighthouse de Chrome DevTools (sin instalar nada) en modo navegación sobre cada URL, con la puntuación y la lista de fallos en el PR, más la revisión manual de contraste y teclado. No se agrega `axe-core` ni Playwright a `landing/` sin evaluarlos (constitución §3).

**Límites y dudas abiertas** (no se resuelven inventando; las responde el líder en el PR):
1. **Responsable del tratamiento:** ¿quién figura (nombre de persona, equipo o proyecto escolar) y con qué domicilio? Publicar un domicilio particular de un estudiante expone datos personales (§6).
2. **Contacto de privacidad:** ¿qué correo? Se propone el correo único del proyecto (constitución §9). ¿Hay medio para ARCO además del correo? ¿Plazos de respuesta?
3. **Eliminación sin la app:** HU-006 (eliminar desde la app y «Página web para solicitar la eliminación») es del Sprint 6, y HU-055 (descargar y corregir datos) está en Reserva. Hasta entonces, ¿la página ofrece el correo del proyecto como canal manual? ¿Quién lo atiende y en qué plazo? ¿Cómo se comprueba que quien escribe es el dueño de la cuenta sin pedirle datos de más? El aviso no debe prometer funciones que no existen (p. ej. «descargar mis datos en 48 h»).
4. **¿Google Play acepta un aviso marcado como provisional** para la prueba cerrada o la solicitud de producción (TT-TIE-01/06)? Si no, el texto vigente es requisito antes de esa fecha y debe planearse.
5. **Fecha:** KNOCK-159 vence el 30-oct y es Sprint 2, pero la rama sale de `sprint-01` y el PR va a `sprint-01`. ¿Desde qué rama despliega Railway (TT-WEB-01)? Si solo despliega desde `main`, «publicadas» depende de que el cambio llegue a `main` esa semana.
6. **Texto en dos lugares:** el aviso de la app (TT-MOB-06) y el de la landing deben ser el mismo texto y la misma versión. ¿La app lo muestra dentro (copiado en ARB) o solo enlaza a la landing? Se propone que solo enlace, para que exista una sola fuente.
7. **Conservación de INE y selfie:** la constitución §6, HU-021 y HU-022 dicen «al decidir o a los 7 días»; DECISIONES #4 y FUNCIONES §4.2 dicen 30 días, y FUNCIONES §6 dice «sin guardar las fotos». Manda la constitución (7 días); se propone corregir esos documentos de referencia en otra tarea para que nadie copie el plazo viejo al aviso.
8. **Plazos que faltan:** respaldos (`mongodump` diario, TT-BD-04) y cuándo se purga un dato borrado de ellos; retención de logs de Application Insights y de Sentry; reportes «el tiempo que obligue la ley» (¿cuánto?); contactos de confianza (¿se guardan?).
9. **Términos y condiciones:** la constitución §14 los pone en la landing y la app los hace aceptar al registrarse (HU-001), pero ninguna tarea del plan los tiene asignados. ¿Se agregan aquí (más puntos), a TT-WEB-01 o a una tarea nueva?
10. **Inglés:** la app tiene ARB es/en. ¿Hace falta el aviso en inglés? Se propone solo español (México) para el MVP.
11. **Edad mínima y público:** ¿la app es solo para mayores de 18? Afecta la sección `menores-de-edad` y la declaración de público objetivo en Google Play.
12. **Ubicación y Google Maps:** ¿la conversión a colonia ocurre en el teléfono o en el servidor? ¿Qué datos recibe Google por el SDK de mapas? (TT-MOB-04 lo estudia).
13. **Transferencias o remisiones:** cómo clasificar legalmente a cada proveedor de §5 (encargado, transferencia) y si alguno requiere consentimiento; DECISIONES §10 pregunta 8 lo deja al abogado.
14. **Revisión por abogado:** DECISIONES §10 la recomienda, sobre todo por los datos biométricos. ¿Se hará antes de pasar a `vigente`? Si no, dejarlo como riesgo aceptado por el líder en `Memoria.md`.

## Aprobación
- [ ] Revisor 1 — nombre: ________ fecha: ________
- [ ] Sin conflicto con la constitución
- **Estados:** Borrador (agente) → Aprobada (persona; habilita el código) → Firmada (tras el merge)
