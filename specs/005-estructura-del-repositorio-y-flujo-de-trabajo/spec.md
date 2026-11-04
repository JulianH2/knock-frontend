# Spec 005 — Estructura del repositorio y flujo de trabajo

> **Estado:** Aprobada · **Repositorio:** knock-frontend · **Rector:** `constitution.md`

## 1. Objetivo
Fijar cómo está organizado el repositorio, cómo se nombran las ramas y los commits y cómo se revisa un cambio.

## 2. Alcance
**Dentro**
- Carpetas de la raíz y su propósito.
- Ramas `main`, `develop` y de trabajo.
- Convención de commits y de ramas.
- Plantilla de pull request y CODEOWNERS.
- Archivos de gobierno: `README.md`, `AGENTS.md`, `constitution.md` y `Memoria.md`.

**Fuera**
- Reglas de protección configuradas en GitHub.
- Automatización de CI (spec 007).

## 3. Requisitos
- **R-01:** `main` contiene solo código listo para publicar y `develop` integra los cambios.
- **R-02:** Cada cambio vive en una rama `<tipo>/<descripcion-en-ingles>` creada desde `develop`.
- **R-03:** Los commits siguen Conventional Commits en inglés.
- **R-04:** Todo cambio entra por pull request con descripción, pruebas ejecutadas y revisión de otra persona.
- **R-05:** Una spec aprobada precede al código de cada cambio.
- **R-06:** `Memoria.md` se actualiza al cerrar cada cambio.
- **R-07:** La plantilla de pull request tiene las secciones Descripción, Pruebas, Seguridad, Riesgos y «Uso de IA» (qué generó la IA y qué revisó una persona).

## 4. Criterios de aceptación
- **CA-01:** Dado un commit con otro formato, cuando se valida, entonces se rechaza.
- **CA-02:** Dado un PR sin revisión, cuando se intenta fusionar, entonces no se permite.
- **CA-03:** Dado el repositorio, cuando se abre `README.md`, entonces explica cómo ejecutar la app y el panel.
- **CA-04:** Dado un PR sin la sección «Uso de IA», cuando corre la comprobación de la plantilla, entonces falla.

## 5. Contrato
No aplica. Interfaces que fija: el formato `tipo(alcance): descripcion` de los commits y la plantilla de PR.

## 6. Amenazas y controles
| Amenaza | Control |
|---|---|
| Cambios sin revisión llegan a `main` | Protección de ramas: PR obligatorio, revisión de otra persona y checks en verde |
| Un secreto entra al historial | Hook y job de CI que buscan secretos |
| Un agente de IA aprueba o fusiona por su cuenta | La constitución lo prohíbe y CODEOWNERS exige revisión humana |

## 7. Plan de pruebas
| Tipo | ¿Aplica? | Motivo |
|---|---|---|
| Unitarias | Sí | Validador de formato de commit y de rama |
| Integración | Sí | Hooks de Git en un repositorio de prueba |
| Seguridad negativa | Sí | Commit con un secreto de ejemplo |
| Arquitectura | No | No hay código de producto |
| Contrato | No | No hay contrato |

## 8. Decisiones
- **Un repositorio de frontend:** contiene la app, el panel y la landing, que comparten reglas, versión del contrato y revisión.
- **Flujo con `develop`:** integra y prueba antes de tocar `main`.

## 9. Riesgos y dudas abiertas
- Ninguna duda abierta por ahora; se agregan aquí las que surjan al revisar la spec.

## Aprobación
- [x] Revisor 1 — nombre: José Julián Hernández Hernández fecha: 2026-11-04
- [x] Sin conflicto con la constitución
- **Estados:** Borrador → Aprobada (una persona; habilita el código) → Implementada (tras el merge)
