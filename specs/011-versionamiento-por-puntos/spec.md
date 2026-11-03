# Spec 011 — Versionamiento por puntos

> **Estado:** Borrador · **Repositorio:** knock-frontend · **Rector:** `constitution.md`

## 1. Objetivo
Definir cómo se numeran las versiones de la app, del panel y de la landing, y cómo se calcula el número interno que exige Google Play.

## 2. Alcance
**Dentro**
- Formato `X.Y.Z` por componente.
- Tabla de puntos por tipo de cambio.
- Cálculo del `versionCode` de Android.
- Etiqueta `puntos-<componente>-N` en cada PR.
- Etiqueta de Git y registro de versiones publicadas.

**Fuera**
- Versionado de los servicios del backend.

## 3. Requisitos
- **R-01:** La app, el panel y la landing llevan cada uno su propia versión `X.Y.Z`; la primera publicada es `1.0.0`.
- **R-02:** `X` sube cuando un cambio rompe lo anterior, `Y` cuando se acumulan funciones y `Z` con cambios pequeños.
- **R-03:** Cada cambio vale puntos según su tipo: 1 por corrección, ajuste de texto, traducción o estilo; 2 por campo nuevo o cambio de regla; 3 por pantalla nueva; 5 por función completa; 10 por integración externa o permiso nuevo del teléfono.
- **R-04:** Cada PR declara sus puntos con la etiqueta `puntos-<componente>-N`.
- **R-05:** Al publicar se suman los puntos y se aplican a `Z`, con los desbordes a `Y` y `X`; un cambio que rompe compatibilidad sube `X` y deja `Y` y `Z` en cero.
- **R-06:** El `versionCode` de Android se calcula como `X × 1 000 000 + Y × 10 000 + Z × 100 + n`, donde `n` (0 a 99) es el número de subida de esa versión.
- **R-07:** Cada publicación crea una etiqueta de Git con la versión y se agrega al registro de versiones publicadas; una publicación con cero puntos no cambia la versión.

## 4. Criterios de aceptación
- **CA-01:** Dada la versión `1.1.2`, cuando se hace la primera subida, entonces el `versionCode` es `1 010 200`.
- **CA-02:** Dada una segunda subida de la misma versión, cuando se calcula, entonces `n` aumenta y el `versionCode` también.
- **CA-03:** Dado un PR sin etiqueta de puntos, cuando corre la comprobación, entonces falla.
- **CA-04:** Dada una publicación con cero puntos, cuando termina, entonces la versión no cambia.

## 5. Contrato
Fija la etiqueta de PR `puntos-<componente>-N`, el formato de la etiqueta de Git `<componente>-vX.Y.Z` y el cálculo del `versionCode`.

## 6. Amenazas y controles
| Amenaza | Control |
|---|---|
| Google Play rechaza una subida por repetir el `versionCode` | El cálculo garantiza que siempre crece |
| Puntos declarados de menos para no subir de versión | La revisión del PR comprueba la etiqueta contra el tipo de cambio |

## 7. Plan de pruebas
| Tipo | ¿Aplica? | Motivo |
|---|---|---|
| Unitarias | Sí | Cálculo de versión y de `versionCode` con los ejemplos |
| Integración | Sí | Script de publicación sobre un repositorio de prueba |
| Seguridad negativa | No | No aplica |
| Arquitectura | No | No aplica |
| Contrato | No | No aplica |

## 8. Decisiones
- **Versión por componente:** un cambio en la landing no cambia el número de la app.
- **`versionCode` derivado de la versión:** siempre crece y no hay que llevarlo a mano.

## 9. Riesgos y dudas abiertas
- Ninguna duda abierta por ahora; se agregan aquí las que surjan al revisar la spec.

## Aprobación
- [ ] Revisor 1 — nombre: ________ fecha: ________
- [ ] Sin conflicto con la constitución
- **Estados:** Borrador → Aprobada (una persona; habilita el código) → Implementada (tras el merge)
