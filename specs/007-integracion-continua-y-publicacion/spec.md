# Spec 007 — Integración continua y publicación

> **Estado:** Borrador · **Repositorio:** knock-frontend · **Rector:** `constitution.md`

## 1. Objetivo
Definir las verificaciones automáticas de cada cambio y cómo la app llega a Google Play.

## 2. Alcance
**Dentro**
- Workflow por pull request para la app, el panel y la landing.
- Análisis, formato, pruebas y cobertura.
- Detección de secretos y auditoría de dependencias.
- Construcción del paquete firmado de la app y su publicación por etapas.

**Fuera**
- Contenido de la ficha de la tienda.

## 3. Requisitos
- **R-01:** Cada PR que toca `app/` corre `flutter pub get`, `flutter analyze`, `dart format` y `flutter test` con cobertura.
- **R-02:** Cada PR que toca `panel/` corre `npm ci`, lint, pruebas y build.
- **R-03:** Un job busca secretos y otro audita dependencias y licencias.
- **R-04:** Las acciones de terceros se fijan por SHA y los permisos son los mínimos.
- **R-05:** El paquete firmado (AAB) se construye y se publica con la API de Google Play; la firma y las credenciales viven en GitHub Secrets.
- **R-06:** La publicación pasa por etapas: pista interna, prueba cerrada con al menos 12 testers durante 14 días seguidos y producción.

## 4. Criterios de aceptación
- **CA-01:** Dado un PR con una prueba fallida, cuando corre el CI, entonces el check falla.
- **CA-02:** Dado un PR que solo toca `panel/`, cuando corre el CI, entonces no corre el job de la app.
- **CA-03:** Dado el proceso de publicación, cuando termina, entonces la versión aparece en la pista interna.

## 5. Contrato
No aplica. Interfaces que fija: los nombres de los checks obligatorios y la secuencia de pistas de Google Play.

## 6. Amenazas y controles
| Amenaza | Control |
|---|---|
| Una acción de terceros cambia y roba secretos | Acciones fijadas por SHA y permisos mínimos por job |
| La firma de la app se filtra | La firma y las credenciales viven en GitHub Secrets y nunca en el código |
| Se publica una versión sin pasar el CI | La publicación solo corre sobre la rama principal y después del CI en verde |

## 7. Plan de pruebas
| Tipo | ¿Aplica? | Motivo |
|---|---|---|
| Unitarias | Sí | Scripts de detección de cambios por carpeta |
| Integración | Sí | Workflow sobre un PR de prueba |
| Seguridad negativa | Sí | Secreto de ejemplo en un PR |
| Humo / extremo a extremo | Sí | Publicación en la pista interna |
| Arquitectura | No | No aplica |
| Contrato | No | No aplica |

## 8. Decisiones
- **Jobs por carpeta:** el CI es rápido y barato.
- **Publicar desde GitHub:** se establece como requerimiento desplegar desde GitHub a Google Play, y las claves nunca se escriben en el código.
- **Etapas de publicación:** Google Play exige una prueba cerrada con testers antes de producción para cuentas nuevas.

## 9. Riesgos y dudas abiertas
- Ninguna duda abierta por ahora; se agregan aquí las que surjan al revisar la spec.

## Aprobación
- [ ] Revisor 1 — nombre: ________ fecha: ________
- [ ] Sin conflicto con la constitución
- **Estados:** Borrador → Aprobada (una persona; habilita el código) → Implementada (tras el merge)
