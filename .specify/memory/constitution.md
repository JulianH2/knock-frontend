---
version: 1.0.0
status: borrador
methodology: SDD (Spec Driven Development)
applies_to: knock-frontend
---

# Constitución — Knock · Frontend

> Reglas no negociables de este repositorio. Si otro documento (spec, plan, tareas, AGENTS.md o código) la contradice, **manda esta constitución**.
> Fuente: `docs/descripcion-del-proyecto.md`.

## 1. Propósito y alcance
- Knock conecta a personas con técnicos de confianza (mecánica, plomería, electricidad) de su colonia, empezando por una ciudad piloto. Este repositorio es el **frontend**: la app móvil Android, el panel web interno y la landing page. La descripción completa del proyecto está en `docs/descripcion-del-proyecto.md`.
- Se trabaja con **Spec Driven Development**: primero se escribe qué se va a construir y por qué (spec), después cómo (plan), después los pasos (tareas) y solo entonces se escribe código.
- Esta primera versión define la **base**: arquitectura, estructura del repositorio e infraestructura. No incluye funcionalidad de negocio.

## 2. Principios
1. **Spec primero:** no se escribe código sin una spec aprobada que lo justifique.
2. **Una fuente de verdad:** cada decisión vive en un solo documento; los demás la referencian.
3. **Cambios pequeños y trazables:** cada cambio parte de una spec, tiene su plan y sus tareas y termina con pruebas.
4. **Pruebas que prueban:** cada criterio de aceptación tiene una prueba que falla si la lógica está mal.
5. **Seguridad y privacidad desde el diseño:** validar en la frontera, denegar por defecto, mínimo privilegio, sin secretos en el repositorio.
6. **Simplicidad:** se elige la solución más simple que cumpla la spec; no se construye para necesidades futuras.
7. **Honestidad:** no se declara que algo pasó si no se ejecutó, y las limitaciones se informan.
8. **La IA propone, la persona decide:** los agentes redactan y verifican, pero una persona aprueba cada spec y cada cambio.
9. **Caché en la app:** la app guarda por poco tiempo lo que cambia poco, revalida con `ETag` antes de volver a descargar y borra toda la caché al cerrar sesión.
10. **Textos y tema fuera de las pantallas:** todo texto visible sale de los archivos de traducción (español e inglés) y todo color y tipografía, del tema.
11. **Permisos al usarlos:** cada permiso del teléfono se pide cuando se necesita, con una explicación previa, y la app funciona sin los opcionales.
12. **Versionado por puntos:** cada componente (app, panel y landing) lleva su versión `X.Y.Z`; en Android, el `versionCode` se calcula como `X × 1 000 000 + Y × 10 000 + Z × 100 + n`.
13. **Uso de IA declarado:** todo pull request incluye una sección «Uso de IA» con qué generó la IA y qué revisó una persona (la sección va en la plantilla del PR, no en cada spec); la IA nunca recibe datos personales sensibles.

## 3. Stack
| Capa | Tecnología |
|---|---|
| App móvil | Flutter estable para Android, Dart 3, Riverpod (estado) y go_router (navegación); se publica en Google Play |
| Panel interno | Angular con componentes standalone, Angular Material y TypeScript estricto; publicado en Railway |
| Landing page | Sitio estático publicado en Railway con HTTPS; redirige a Google Play y aloja el aviso de privacidad |
| Hosting web | Railway, en un espacio que aporta un integrante del equipo (sin costo adicional para el proyecto) |
| Contrato con el backend | OpenAPI del backend vendorizado en `contracts/`; los clientes se generan, nadie escribe llamadas HTTP a mano |
| Idiomas y tema | Archivos de traducción (español e inglés) desde el inicio y tema claro, oscuro o automático |
| Datos locales | Caché con revalidación por ETag y almacenamiento seguro para la sesión |
| Pruebas | flutter_test e integration_test para la app; pruebas de componentes y Playwright para el panel |
| Calidad y seguridad | `flutter analyze`, `dart format`, ESLint, Semgrep, detección de secretos y revisión de dependencias |
| Integración y entrega continua | GitHub Actions; la app se publica por etapas con la API de Google Play |

No se agregan dependencias sin evaluar necesidad, licencia, mantenimiento y vulnerabilidades, y se registran en `Memoria.md`.

## 4. Arquitectura
- **Un repositorio con tres partes independientes:** `app/` (Flutter), `panel/` (Angular) y `landing/` (sitio estático), más `contracts/` con el OpenAPI del backend.
- **La app se organiza por función y por capas:** cada función (Inicio, Explorar, Actividad, Trabajo y Cuenta) tiene `presentation` (pantallas y controladores), `domain` (entidades y reglas, Dart puro) y `data` (repositorios que hablan con la API y con la caché local). Se organiza así para probar las reglas sin abrir la app.
- **Cada pantalla tiene un estado claro** (cargando, con datos, vacía o con error) y se dibuja solo a partir de él.
- **El cliente de la API se genera** desde el OpenAPI del backend; si el backend cambia, la app deja de compilar hasta ajustarse en lugar de fallar en producción.
- **Piezas comunes:** un componente de sesión agrega y renueva el token, un manejo común de errores los traduce a mensajes en español, y todos los textos viven en archivos de traducción.
- **El panel** separa `core`, `shared` y `features`; los componentes no usan `HttpClient`: lo hacen los servicios sobre el cliente generado.
- **La landing** es estática: sin servidor propio y sin JavaScript innecesario; sus cabeceras de seguridad las fija el contenedor que la sirve.

**Estructura del repositorio**

```
app/lib/
  core/                       tema, navegación, red, sesión, errores, preferencias
  features/<funcion>/{presentation,domain,data}
  l10n/                       archivos de traducción (es, en)
app/packages/knock_api/       cliente generado
app/test/ app/integration_test/
panel/src/app/
  core/ shared/ features/<funcion>/{pages,components,services,models}
  api/                        cliente generado
landing/                      sitio estático
contracts/openapi.v1.json     contrato vendorizado
docs/                         descripción del proyecto y decisiones
specs/                        spec.md, plan.md y task.md de cada cambio
```

## 5. Infraestructura y escalabilidad
- **La infraestructura de la nube vive en `knock-backend`;** este repositorio consume la API por su contrato OpenAPI y no crea recursos de Azure.
- **App móvil:** se construye en GitHub Actions y se publica como paquete firmado (AAB) en Google Play por etapas: pista interna, prueba cerrada con al menos 12 testers durante 14 días seguidos y producción.
- **Landing page:** sitio estático publicado en Railway con HTTPS obligatorio; cada cambio aprobado en la rama principal se publica solo.
- **Panel interno:** se construye como aplicación estática y se publica en Railway con HTTPS, en el mismo espacio que la landing, que aporta un integrante del equipo y no genera costo adicional para el proyecto. Es de uso interno: no se indexa y solo entra el personal autenticado.
- **Claves y firma:** la firma de la app y las credenciales de publicación viven en GitHub Secrets, nunca en el código.
- **Costo cero:** la landing y el panel usan un espacio de Railway que aporta un integrante del equipo; el resto usa niveles gratuitos.

## 6. Código y convenciones
- Código y comentarios técnicos en inglés; specs, documentación y textos de interfaz en español.
- Warnings como errores; complejidad máxima de 10 por método o función.
- Sin `TODO` sin explicación, sin código muerto y sin secretos.
- Nombres claros: el nombre explica la intención, no la implementación.

## 7. Seguridad y privacidad
- Ningún secreto, clave, dato personal real ni documento de identidad vive en el repositorio, en los registros ni en un prompt.
- Se sigue OWASP Top 10 y OWASP API Security Top 10 como lista mínima.
- Toda entrada se valida; toda autorización se decide en el servidor.

## 8. Pruebas y calidad
- Tipos de prueba posibles: unitarias, integración, arquitectura, seguridad negativa, contrato, accesibilidad y de aceptación; cada spec declara cuáles aplican y por qué.
- Cobertura mínima definida en la spec de calidad; los umbrales no se bajan para que el CI pase.
- Un cambio está terminado cuando cumple sus criterios, sus pruebas pasan, el CI está en verde, un par lo revisó y `Memoria.md` está al día.

## 9. Flujo de trabajo
- Ramas: `main` (listo para publicar) ← `develop` (integración) ← `<tipo>/<descripcion-en-ingles>` (una por cambio).
- Commits en inglés con Conventional Commits: `tipo(alcance): descripcion`.
- Todo cambio entra por pull request con descripción, pruebas ejecutadas y revisión de otra persona.
- Ciclo SDD de cada cambio: **spec → plan → tareas → implementación → verificación → memoria**.
- Cada PR declara los puntos que aporta a cada componente que toca (`puntos-<componente>-N`); al publicar se suman y se calcula la versión nueva. Una publicación con cero puntos no cambia la versión.
- La plantilla de PR tiene las secciones Descripción, Pruebas, Seguridad, Riesgos y «Uso de IA».

## 10. Agentes de IA
- Los agentes leen `AGENTS.md`, esta constitución y `Memoria.md` antes de actuar.
- Un agente nunca aprueba una spec, nunca fusiona y nunca opera sobre producción.
- Prohibido: omitir pruebas, desactivar reglas o escáneres, exponer secretos, afirmar ejecuciones que no se hicieron y agregar dependencias sin evaluar.

## 11. Gobernanza
- Estados de una spec: **Borrador** (la escribe un agente o una persona) → **Aprobada** (una persona; habilita el código) → **Implementada** (tras el merge).
- Cambios a esta constitución: pull request con la aprobación de al menos dos integrantes, `version` incrementada y registro en `Memoria.md`.
