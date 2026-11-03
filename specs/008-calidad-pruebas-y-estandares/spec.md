# Spec 008 — Calidad, pruebas y estándares

> **Estado:** Borrador · **Repositorio:** knock-frontend · **Rector:** `constitution.md`

## 1. Objetivo
Definir las reglas de código y los tipos de pruebas que se esperan en la app y en el panel.

## 2. Alcance
**Dentro**
- Reglas de Dart (`flutter_lints`) y de TypeScript (ESLint y Prettier).
- Convenciones de nombres.
- Tipos de pruebas y cobertura mínima.
- Accesibilidad básica.
- Definición de terminado.

**Fuera**
- Pruebas de rendimiento y de mutación.

## 3. Requisitos
- **R-01:** `flutter analyze` y el lint del panel no tienen hallazgos.
- **R-02:** El código y los comentarios técnicos van en inglés; las specs y los textos de la interfaz, en español.
- **R-03:** Cada criterio de aceptación de una spec tiene una prueba que falla si la lógica está mal.
- **R-04:** La cobertura mínima es del 50 % de líneas en la app y del 60 % en el panel.
- **R-05:** Las pruebas de pantallas comprueban los cuatro estados: cargando, con datos, vacía y con error.
- **R-06:** Los controles de la app tienen etiqueta semántica y área táctil de al menos 48 dp.
- **R-07:** No se agregan dependencias sin evaluar necesidad, licencia, mantenimiento y vulnerabilidades.

## 4. Criterios de aceptación
- **CA-01:** Dado un hallazgo del analizador, cuando corre el CI, entonces falla.
- **CA-02:** Dado un botón sin etiqueta semántica, cuando corre la prueba de accesibilidad, entonces falla.
- **CA-03:** Dado un PR que baja la cobertura del mínimo, cuando corre el CI, entonces falla.

## 5. Contrato
No aplica.

## 6. Amenazas y controles
| Amenaza | Control |
|---|---|
| Pruebas debilitadas o desactivadas para que pase el CI | Los umbrales no se bajan; la constitución lo prohíbe y la revisión lo comprueba |
| Dependencia con vulnerabilidad o licencia incompatible | Evaluación previa en `Memoria.md` y auditoría automática en el CI |

## 7. Plan de pruebas
| Tipo | ¿Aplica? | Motivo |
|---|---|---|
| Unitarias | Sí | Analizadores y reglas |
| Widget / componente | Sí | Cuatro estados de cada pantalla |
| Accesibilidad | Sí | Etiquetas semánticas y áreas táctiles |
| Integración | Sí | El CI sobre un PR de prueba |
| Contrato | No | No aplica |

## 8. Decisiones
- **Lints estrictos desde el inicio:** es más barato que corregir después.
- **Accesibilidad desde la base:** cuesta menos que agregarla al final.

## 9. Riesgos y dudas abiertas
- Ninguna duda abierta por ahora; se agregan aquí las que surjan al revisar la spec.

## Aprobación
- [ ] Revisor 1 — nombre: ________ fecha: ________
- [ ] Sin conflicto con la constitución
- **Estados:** Borrador → Aprobada (una persona; habilita el código) → Implementada (tras el merge)
