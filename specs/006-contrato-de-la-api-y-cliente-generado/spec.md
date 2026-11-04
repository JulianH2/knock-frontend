# Spec 006 — Contrato de la API y cliente generado

> **Estado:** Aprobada · **Repositorio:** knock-frontend · **Rector:** `constitution.md`

## 1. Objetivo
Definir cómo el frontend obtiene el contrato OpenAPI del backend y genera sus clientes para la app y el panel.

## 2. Alcance
**Dentro**
- Vendorización del contrato en `contracts/openapi.v1.json`.
- Generación del cliente Dart y del cliente TypeScript.
- Regla de que nadie escribe llamadas HTTP a mano.
- Verificación en el CI de que el cliente corresponde al contrato.

**Fuera**
- Llamadas de negocio.
- Cambios al contrato, que se hacen en el backend.

## 3. Requisitos
- **R-01:** El contrato vive en `contracts/openapi.v1.json` y se actualiza copiándolo del backend.
- **R-02:** Los clientes generados viven en carpetas propias y no se editan.
- **R-03:** Los clientes se regeneran con un comando documentado.
- **R-04:** El CI falla si el cliente generado no corresponde al contrato.

## 4. Criterios de aceptación
- **CA-01:** Dado un cambio en el contrato, cuando se regeneran los clientes, entonces los tipos cambian sin edición manual.
- **CA-02:** Dado un cliente editado a mano, cuando corre el CI, entonces falla.

## 5. Contrato
Consume `contracts/openapi.v1.json` (versión vendorizada del OpenAPI del backend) y produce el cliente Dart y el cliente TypeScript.

## 6. Amenazas y controles
| Amenaza | Control |
|---|---|
| El cliente se aparta del contrato y falla en producción | El CI regenera el cliente y compara con el contrato; falla si difiere |
| Un contrato manipulado inserta código malicioso | El contrato se copia del repositorio del backend por PR revisado y los generadores se fijan por versión |

## 7. Plan de pruebas
| Tipo | ¿Aplica? | Motivo |
|---|---|---|
| Unitarias | Sí | Scripts de generación |
| Contrato | Sí | Regenerar y comparar el cliente con el contrato |
| Integración | Sí | Cliente contra un servidor simulado |
| Seguridad negativa | No | Se cubre en la spec 009 |
| Arquitectura | No | No aplica |

## 8. Decisiones
- **Contrato primero:** el backend define la API y el frontend la consume sin interpretarla.
- **Clientes generados:** evitan errores de tipos y rutas escritas a mano.

## 9. Riesgos y dudas abiertas
- Ninguna duda abierta por ahora; se agregan aquí las que surjan al revisar la spec.

## Aprobación
- [x] Revisor 1 — nombre: José Julián Hernández Hernández fecha: 2026-11-04
- [x] Sin conflicto con la constitución
- **Estados:** Borrador → Aprobada (una persona; habilita el código) → Implementada (tras el merge)
