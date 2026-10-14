# TT-PRU-03 — Crear el proyecto Angular del panel de administración y su pantalla inicial

> **Jira:** KNOCK-31 · **Épica:** por confirmar · **Módulo:** Panel — Prueba de roles · **Responsable:** Ángel Alexis Blas Castillo · **Sprint:** S0 · **Puntos:** por confirmar · **Capas:** Panel
> **Repositorio:** knock-frontend · **Otra parte en:** —
> **Fuentes:** Requisitos del usuario en esta conversación; `Product_Backlog_Knock.docx` (HU-046, referencia funcional relacionada); `README.md` §Primeros pasos; `docs/DECISION_TECNICA.md` §9; `AGENTS.md` §§6, 8; `docs/templates/README.md`. El documento proporcionado no incluye la tarea técnica TT-PRU-03 ni KNOCK-31.
> **Skills:** spec-first-writing, story-workflow, angular-panel, testing-strategy-frontend, security-core, traceability
> **Estado:** Borrador

## 1. Objetivo
Crear en `panel/` el proyecto inicial Angular del panel de administración y una pantalla de entrada accesible en el navegador, cuyo encabezado visible sea exactamente **“Knock — Panel de administración”**. Para este ejercicio, el proyecto no incorpora inicio de sesión ni consume la API de Knock; debe compilar y poder abrirse localmente en un navegador.

La solución se limita al arranque del proyecto y a la pantalla estática solicitada. Se ajustará a las decisiones documentadas para el panel (Angular, componentes standalone, signals y Angular Material) sin anticipar funciones administrativas que no están en los requisitos de esta tarea.

## 2. Historia y casos de prueba
**TT-PRU-03** — Como equipo de Knock, quiero inicializar el proyecto Angular del panel y abrir una pantalla de bienvenida, para disponer de una base compilable y visible en navegador antes de añadir funciones administrativas.

**Contexto relacionado:** el Product Backlog proporcionado incluye HU-046 «Acceso de administrador por permisos» (Alta, Sprint 1), con acceso administrativo y autorización por permisos. Esa historia es funcional y distinta de este ejercicio de bootstrap; no cambia el requisito de no implementar login, permisos ni llamadas a API aquí.

| Caso | Criterio (Dado / Cuando / Entonces) | Verificación |
|---|---|---|
| TC-TT-PRU-03-01 | Dado el proyecto Angular y sus dependencias declaradas, cuando se instalan desde el lockfile y se ejecuta el build, entonces la compilación termina correctamente. | `cd panel && npm ci && npx ng build` |
| TC-TT-PRU-03-02 | Dado el proyecto compilado, cuando se inicia la aplicación en la ruta inicial y se abre un navegador, entonces la pantalla muestra el encabezado visible exacto “Knock — Panel de administración”. | Prueba de componente del componente raíz con el nombre `TC-TT-PRU-03-02 …`; humo manual en navegador con `cd panel && npx ng serve --open`. |
| TC-TT-PRU-03-03 | Dada una sesión nueva sin autenticación, cuando se abre la ruta inicial, entonces no se presenta un login ni una redirección de autenticación, y la pantalla no necesita ni realiza llamadas a la API de Knock para mostrarse. | Prueba de navegador `TC-TT-PRU-03-03 …` (si se aprueba automatizar el humo con Playwright) o comprobación manual de la ruta y de la pestaña Network; no deben existir solicitudes a la API de Knock ni a Firebase para renderizar la pantalla. |

## 3. Alcance / No-alcance
- **In (este repositorio):**
  - Crear el proyecto Angular en `panel/` mediante el flujo de generación acordado para el repositorio.
  - Configurar dependencias y lockfile reproducibles, y conservar la configuración TypeScript estricta y las reglas de panel aplicables.
  - Crear la pantalla inicial estática con el encabezado indicado, semántica de encabezado y navegación local suficiente para arrancar en navegador.
  - Verificar instalación, build, renderizado del encabezado y ausencia de dependencia de login/API conforme a los casos de §2.
- **Out:**
  - Login, sesión, Firebase Auth, guardas, permisos, doble factor, interceptor o cierre de sesión.
  - Consumo de endpoints, generación o integración del cliente TypeScript, datos reales, persistencia, SignalR o FCM.
  - Funciones de administración (moderación, verificación, métricas, catálogos), navegación funcional entre módulos y diseño distinto al contenido mínimo de esta pantalla.
  - Despliegue, publicación o configuración de servicios externos.

## 4. Contratos API y eventos
— (sin endpoints ni eventos; la pantalla inicial no consume API ni publica o escucha eventos).

## 5. Modelo de datos
— (sin entidades ni persistencia; la pantalla solo presenta contenido estático).

## 6. Seguridad, privacidad y amenazas
| Amenaza | Control | Caso que lo prueba |
|---|---|---|
| Fuga de información por llamadas accidentales a servicios o por renderizar datos sensibles | No integrar API, Firebase ni datos de usuarios en esta tarea; la pantalla inicial no recibe datos externos. | TC-TT-PRU-03-03 |
| Suplantación o elevación de privilegios en una pantalla de acceso | No crear login, sesión ni operaciones privilegiadas; no añadir guardas ni presentar esta pantalla como autenticación. | TC-TT-PRU-03-03 |
| Alteración/inyección de contenido | Mostrar únicamente el texto estático requerido; no usar `[innerHTML]` ni `bypassSecurityTrust*`. | TC-TT-PRU-03-02 |
| Riesgo de cadena de suministro de dependencias del proyecto nuevo | Usar lockfile y `npm ci` para la verificación; evaluar antes de añadir paquetes que no sean necesarios para la base Angular definida. | TC-TT-PRU-03-01 |

El alcance no maneja identidad, datos personales ni acciones sensibles; controles de auditoría, límites de API y sesión no aplican mientras no se integre un backend.

## 7. Pantallas
- **Pantalla inicial del panel** en la ruta inicial:
  - Muestra el encabezado **“Knock — Panel de administración”**.
  - No requiere sesión, llamadas de red ni datos externos.
  - No tiene estados de carga, error o vacío dependientes de servicios. Cualquier contenido adicional, estilo visual, idioma alternativo o navegación fuera de la ruta inicial queda fuera de esta tarea hasta que se acuerde.
  - Debe usar semántica HTML accesible para el encabezado y conservar el comportamiento seguro de Angular para texto.

## 8. Pruebas, gates y límites
**Plan de pruebas** (Sí/No con motivo; meta de mutación):

| Tipo | ¿Aplica? | Motivo / herramienta |
|---|---|---|
| Build | Sí | `cd panel && npm ci && npx ng build`; criterio TC-TT-PRU-03-01. |
| Unitarias / componente | Sí | Prueba del componente raíz que verifica el encabezado exacto; el nombre de la prueba incluye `TC-TT-PRU-03-02`. Sin red. |
| Integración | No | No hay servicios ni límites entre módulos en el alcance estático. |
| Contrato API | No | No se consume la API ni se genera/usa el cliente. |
| E2E / navegador | Sí | Humo de la ruta inicial en navegador (`ng serve --open`) para confirmar que abre y muestra el título; verificar la ausencia de login y solicitudes a API conforme a TC-TT-PRU-03-03. Automatización con Playwright pendiente de confirmar por las dudas de §8. |
| Accesibilidad | Sí | Confirmar encabezado semántico y ausencia de violaciones serias en la pantalla inicial; usar el gate Angular/axe disponible cuando se resuelva la configuración de pruebas. |
| Compatibilidad | No | No se solicita una matriz de navegadores para este bootstrap; cualquier matriz adicional queda para una decisión del equipo. |
| Mutación | No | No se especifica lógica de negocio, servicios ni guardas mutables. No se propone reducir el umbral general del repositorio; confirmar el tratamiento de esta tarea sin lógica en el gate de mutación. |
| Rendimiento / usabilidad formal | No | No hay flujo funcional ni medición de rendimiento en los requisitos de esta tarea. |

**Gates:** aplicar `AGENTS.md` §5 en lo que corresponda a un proyecto Panel: build, lint/análisis y pruebas establecidos para el proyecto, cobertura y accesibilidad según los gates existentes, además de `sdd_lint.py`, `sdd_lint.py --trace TT-PRU-03`, `codemap.py --check`, `check_exceptions.py` y `sync_agents.py --check`. Esta especificación no afirma que se hayan ejecutado esas verificaciones.

**Límites y dudas abiertas:**
- El documento Product Backlog proporcionado contiene HU-046 relacionada con el acceso administrativo, pero no la ficha técnica TT-PRU-03 ni KNOCK-31. Se toman responsable Ángel Alexis Blas Castillo, Sprint S0 y área Prueba de roles de los requisitos del usuario; confirmar desde Jira/ficha autorizada el título oficial de la tarea, épica y puntos, y si existen criterios adicionales.
- Confirmar versiones de Angular, Node.js y npm, gestor de paquetes y opciones de `ng new` (incluido SSR o ausencia de SSR). No se fija una versión sin consultar el estándar vigente del equipo.
- Confirmar qué pruebas de navegador se exigen para el proyecto inicial. `docs/templates/README.md` menciona configuración Playwright, axe y Stryker para `panel/`, pero los archivos plantilla de Panel referenciados no están en `docs/templates/` en este checkout.
- Confirmar si la pantalla debe incluir Angular Material desde este primer corte o solo respetar la decisión arquitectónica para las siguientes funciones. `docs/DECISION_TECNICA.md` y `AGENTS.md` establecen Angular Material para el panel, mientras que el requisito de usuario solo concreta el título y la apertura en navegador.
- La constitución `.specify/memory/constitution.md` no se pudo leer: el guardián del repositorio bloqueó su acceso por protección. La spec queda en Borrador y la persona revisora debe confirmar compatibilidad con la constitución antes de aprobarla.

## Aprobación
- [ ] Revisor 1 — nombre: ________ fecha: ________
- [ ] Sin conflicto con la constitución
- **Estados:** Borrador (agente) → Aprobada (persona; habilita el código) → Firmada (tras el merge)
