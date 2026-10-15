# TT-PRU-03 — Crear el proyecto Angular del panel de administración y su pantalla inicial

> **Jira:** KNOCK-31 · **Épica:** EP-13 · **Módulo:** Panel — Prueba de roles · **Responsable:** Ángel Alexis Blas Castillo · **Sprint:** S0 · **Puntos:** 1 · **Depende de:** TT-STD-01 · **Capas:** Panel
> **Repositorio:** knock-frontend · **Otra parte en:** —
> **Fuentes:** Ficha TT-PRU-03 compartida en la revisión del PR; `.specify/memory/constitution.md`; `README.md` §Primeros pasos; `docs/DECISION_TECNICA.md` §9; `AGENTS.md` §§6, 8.
> **Skills:** spec-first-writing, story-workflow, angular-panel, testing-strategy-frontend, security-core, traceability
> **Estado:** Aprobada

## 1. Objetivo
Crear en `panel/` el proyecto Angular del panel con `ng new panel`, componentes standalone, enrutamiento y SCSS, y una pantalla inicial accesible cuyo encabezado visible sea exactamente **“Panel Knock”**. La pantalla muestra un menú lateral estático con las opciones “Verificaciones”, “Reportes” y “Métricas”, sin funcionalidad.

El proyecto sigue la estructura `core/` y `features/`, usa Angular Material y queda preparado para el cliente TypeScript generado de la API. No se realizan llamadas reales a la API en esta tarea.

**Terminada cuando:** el Panel compila y abre en el navegador.

## 2. Historia y casos de prueba
**TT-PRU-03** — Como equipo de Knock, quiero inicializar el proyecto Angular del panel y abrir una pantalla de bienvenida, para disponer de una base compilable y visible en navegador antes de añadir funciones administrativas.

| Caso | Criterio (Dado / Cuando / Entonces) | Verificación |
|---|---|---|
| TC-TT-PRU-03-01 | Dado el proyecto Angular y sus dependencias declaradas, cuando se instalan desde el lockfile, se ejecuta el build y se auditan las dependencias, entonces la compilación termina correctamente, la auditoría no reporta vulnerabilidades altas o críticas y la evaluación de dependencias directas (necesidad, mantenimiento y licencia declarada) queda documentada en el PR. | (comando) `cd panel && npm ci && npx ng build && npm audit --audit-level=high`; revisión documentada de dependencias directas en el PR. |
| TC-TT-PRU-03-02 | Dado el proyecto compilado, cuando se inicia la aplicación en la ruta inicial y se abre un navegador, entonces la pantalla muestra el encabezado visible exacto “Panel Knock”. | Prueba de componente del componente raíz con el nombre `TC-TT-PRU-03-02 …`; humo manual en navegador con `cd panel && npx ng serve --open`. |
| TC-TT-PRU-03-03 | Dada una sesión nueva sin autenticación, cuando se abre la ruta inicial, entonces no se presenta un login ni una redirección de autenticación, y la pantalla no necesita ni realiza solicitudes de red a servicios remotos para mostrarse. | Prueba de navegador `TC-TT-PRU-03-03 …` (si se aprueba automatizar el humo con Playwright) o comprobación manual de la ruta y de Network: no debe haber solicitudes a Knock, Firebase ni a otros hosts remotos; solo se permiten los recursos locales del servidor de desarrollo. |
| TC-TT-PRU-03-04 | Dado el menú lateral de la pantalla inicial, cuando se renderiza el componente del menú, entonces muestra las tres opciones “Verificaciones”, “Reportes” y “Métricas” sin activar navegación ni acciones. | Prueba unitaria del componente del menú con nombre `TC-TT-PRU-03-04 …`, ejecutada con `cd panel && ng test`, que comprueba la presencia de las tres etiquetas. |

## 3. Alcance / No-alcance
- **In (este repositorio):**
  - Crear el proyecto con `ng new panel`, componentes standalone, enrutamiento, SCSS y estructura `core/` y `features/`.
  - Incorporar Angular Material.
  - Dejar prevista la ubicación `panel/src/app/api` para el cliente TypeScript generado desde OpenAPI; en esta tarea no se hacen llamadas reales.
  - Crear la pantalla inicial con encabezado semántico “Panel Knock” y menú lateral estático con las etiquetas “Verificaciones”, “Reportes” y “Métricas”, sin funcionalidad.
  - Verificar instalación reproducible, build, encabezado, menú, ausencia de autenticación y ausencia de solicitudes remotas conforme a los casos de §2.
- **Out:**
  - Login y doble factor (HU-066, Sprint 3), sesión, Firebase Auth, guardas, permisos, interceptor o cierre de sesión.
  - Llamadas reales a endpoints, datos reales, persistencia, SignalR o FCM.
  - Funcionalidad en las opciones del menú, incluidas navegación, revisión de verificaciones, reportes o métricas.
  - Despliegue, publicación o configuración de servicios externos.

## 4. Contratos API y eventos
— (sin llamadas a endpoints ni eventos; el cliente TypeScript generado se integrará desde `contracts/openapi.v1.json` cuando exista).

**Decisión sobre el cliente generado:** el archivo `contracts/openapi.v1.json` no existe actualmente en este repositorio. Se posponen la generación e integración del cliente `typescript-angular` hasta que el contrato OpenAPI del backend esté disponible; no se inventará ni se añadirá un contrato provisional. La ubicación prevista del cliente generado es `panel/src/app/api`, conforme a la constitución.

## 5. Modelo de datos
— (sin entidades ni persistencia; la pantalla solo presenta contenido estático).

## 6. Seguridad, privacidad y amenazas
| Amenaza | Control | Caso que lo prueba |
|---|---|---|
| Fuga de información o comunicación remota accidental durante el renderizado | No integrar API, Firebase, analítica ni datos de usuarios; verificar en la pestaña Network que la aplicación no inicia solicitudes a ningún host remoto. | TC-TT-PRU-03-03 |
| Suplantación o elevación de privilegios en una pantalla de acceso | No crear login, sesión ni operaciones privilegiadas; el login y el doble factor quedan fuera por HU-066 (Sprint 3). | TC-TT-PRU-03-03 |
| Alteración/inyección de contenido | Mostrar únicamente el texto estático requerido; no usar `[innerHTML]` ni `bypassSecurityTrust*`. | TC-TT-PRU-03-02 |
| Riesgo de cadena de suministro por dependencias vulnerables, innecesarias o con licencia no evaluada | Usar lockfile y `npm ci`; ejecutar `npm audit --audit-level=high`; antes de añadir cada dependencia directa, documentar en el PR su necesidad, mantenimiento y licencia declarada. | TC-TT-PRU-03-01 |

El alcance no maneja identidad, datos personales ni acciones sensibles; controles de auditoría, límites de API y sesión no aplican mientras no se integre un backend.

## 7. Pantallas
- **Pantalla inicial del panel** en la ruta inicial:
  - Muestra el encabezado **“Panel Knock”**.
  - Muestra un menú lateral estático con “Verificaciones”, “Reportes” y “Métricas”; las opciones no navegan ni ejecutan acciones.
  - No requiere sesión, llamadas de red ni datos externos.
  - No tiene estados de carga, error o vacío dependientes de servicios. Las funciones y pantallas administrativas quedan fuera de esta tarea.
  - Debe usar semántica HTML accesible para el encabezado y conservar el comportamiento seguro de Angular para texto.

## 8. Pruebas, gates y límites
**Plan de pruebas** (Sí/No con motivo; meta de mutación):

| Tipo | ¿Aplica? | Motivo / herramienta |
|---|---|---|
| Build | Sí | `cd panel && npm ci && npx ng build`; criterio TC-TT-PRU-03-01. |
| Auditoría de dependencias | Sí | `cd panel && npm audit --audit-level=high`; TC-TT-PRU-03-01. Documentar en el PR necesidad, mantenimiento y licencia declarada de las dependencias directas. |
| Unitarias / componente | Sí | Prueba del componente raíz que verifica el encabezado exacto; el nombre de la prueba incluye `TC-TT-PRU-03-02`. Sin red. |
| Unitarias / componente de menú | Sí | `cd panel && ng test`; verifica que el menú muestra las tres opciones y no implementa acciones; criterio TC-TT-PRU-03-04. |
| Integración | No | No se invoca la API ni hay servicios remotos en el alcance. |
| Contrato API | No | El contrato `contracts/openapi.v1.json` aún no existe; se posponen generación e integración del cliente `typescript-angular` hasta que el contrato esté disponible. |
| E2E / navegador | Sí | Humo de la ruta inicial en navegador (`ng serve --open`) para confirmar que abre y muestra el título; verificar ausencia de login y solicitudes a cualquier host remoto en Network, conforme a TC-TT-PRU-03-03. Automatización con Playwright pendiente de confirmar por las dudas de §8. |
| Accesibilidad | Sí | Usar encabezados y etiquetas semánticas; la plantilla de axe para Panel está pendiente de KNOCK-41 y no bloquea esta tarea. |
| Compatibilidad | No | No se solicita una matriz de navegadores para este bootstrap; cualquier matriz adicional queda para una decisión del equipo. |
| Mutación | No | Solo hay presentación estática y no se especifica lógica de negocio mutable. La plantilla de Stryker para Panel está pendiente de KNOCK-41 y no bloquea esta tarea; no se reduce ningún umbral del repositorio. |
| Rendimiento / usabilidad formal | No | No hay flujo funcional ni medición de rendimiento en los requisitos de esta tarea. |

**Gates:** aplicar `AGENTS.md` §5 en lo que corresponda a un proyecto Panel: build, lint/análisis y pruebas establecidos para el proyecto, cobertura y accesibilidad según los gates existentes, además de `sdd_lint.py`, `sdd_lint.py --trace TT-PRU-03`, `codemap.py --check`, `check_exceptions.py` y `sync_agents.py --check`. Esta especificación no afirma que se hayan ejecutado esas verificaciones.

**Límites y dudas abiertas:**
- Confirmar la versión de Angular/Node.js/npm y las opciones exactas de generación que no define la ficha.
- Las plantillas de Playwright, axe y Stryker para Panel están pendientes de KNOCK-41; no son bloqueo para esta tarea.
- **Decisión:** como no existe `contracts/openapi.v1.json`, posponer la generación e integración del cliente `typescript-angular` hasta que el contrato OpenAPI del backend esté disponible; no crear un contrato provisional.
- Confirmar en qué actualización de contrato y con qué comando se generará el cliente; la salida prevista es `panel/src/app/api` y no se harán llamadas reales en esta tarea.

## Aprobación
- [x] Revisor 1 — nombre: José Julián Hernández Hernández fecha: 2026-10-14
- [x] Sin conflicto con la constitución
- **Estados:** Borrador (agente) → Aprobada (persona; habilita el código) → Firmada (tras el merge)
