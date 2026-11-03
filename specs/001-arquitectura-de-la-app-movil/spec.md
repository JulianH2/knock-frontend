# Spec 001 — Arquitectura de la app móvil

> **Estado:** Borrador · **Repositorio:** knock-frontend · **Rector:** `constitution.md`

## 1. Objetivo
Definir cómo está hecha la app Flutter: su organización por función y capas, su estado, su navegación y su estructura de carpetas, sin implementar pantallas de negocio.

## 2. Alcance
**Dentro**
- Flutter para Android y su publicación en Google Play.
- Organización por función en tres capas y reglas de dependencia.
- Estado de cada pantalla (cargando, con datos, vacía o con error).
- Navegación con go_router y barra de cinco pestañas vacías.
- Proyecto de arranque que compila y abre.

**Fuera**
- Pantallas y funciones de negocio.
- Llamadas reales a la API (spec 006).

## 3. Requisitos
- **R-01:** La app compila y abre en Android sin funciones de negocio.
- **R-02:** Existen las cinco funciones (Inicio, Explorar, Actividad, Trabajo y Cuenta) con pantallas vacías y barra de pestañas.
- **R-03:** `domain/` no importa Flutter ni paquetes de red; `presentation/` no importa `data/`.
- **R-04:** La navegación se declara en un solo lugar con rutas nombradas.
- **R-05:** Cada pantalla se dibuja desde un estado de cuatro tipos: cargando, con datos, vacía o con error.
- **R-06:** Las pruebas de arquitectura verifican las reglas de dependencia.

## 4. Criterios de aceptación
- **CA-01:** Dado el repositorio, cuando se ejecuta `flutter analyze` y `flutter test`, entonces no hay hallazgos y las pruebas pasan.
- **CA-02:** Dado un archivo de `domain/` que importa Flutter, cuando corre la prueba de arquitectura, entonces falla.
- **CA-03:** Dada la app abierta, cuando se toca una pestaña, entonces navega a su función.

## 5. Contrato
No consume endpoints todavía. Interfaces que fija: la estructura de funciones y capas, las rutas nombradas de navegación y el estado de pantalla de cuatro tipos.

## 6. Amenazas y controles
| Amenaza | Control |
|---|---|
| Una capa de presentación llama a la red y se salta las reglas | Prueba de arquitectura: `presentation/` no importa `data/` y `domain/` no importa Flutter ni red |
| Estado de una pantalla incoherente que muestra datos de otra sesión | Los controladores se reinician al cerrar sesión y no guardan datos personales fuera de la caché controlada |

## 7. Plan de pruebas
| Tipo | ¿Aplica? | Motivo |
|---|---|---|
| Unitarias | Sí | Reglas de `domain/` y controladores |
| Widget / componente | Sí | Cada pantalla en cargando, con datos, vacía y con error |
| Arquitectura | Sí | Dependencias entre capas |
| Accesibilidad | Sí | Etiquetas semánticas y áreas táctiles de 48 dp |
| Contrato | No | No consume la API todavía |
| Seguridad negativa | No | Se cubre en la spec 009 |

## 8. Decisiones
- **Flutter:** con un solo código se obtiene una interfaz consistente, hay buenos paquetes para mapas, cámara, notificaciones y almacenamiento seguro, y encaja con los requerimientos de aplicaciones móviles.
- **Tres capas por función:** las reglas de negocio se prueban sin abrir la app y se pueden cambiar sin tocar las pantallas.
- **Riverpod:** inyección de dependencias y estado con pruebas sencillas.

## 9. Riesgos y dudas abiertas
- Ninguna duda abierta por ahora; se agregan aquí las que surjan al revisar la spec.

## Aprobación
- [ ] Revisor 1 — nombre: ________ fecha: ________
- [ ] Sin conflicto con la constitución
- **Estados:** Borrador → Aprobada (una persona; habilita el código) → Implementada (tras el merge)
