---
name: angular-panel-structure
description: Estructura del panel Angular: `core`, `shared`, `features` y cliente generado; úsala al especificar páginas, servicios o componentes del panel.
---

# angular-panel-structure

- Componentes standalone; sin `HttpClient` en componentes.
- Los servicios hablan con el cliente generado en `api/`.
- TypeScript estricto y sin `any` sin justificación.
- Nada de `innerHTML` ni `bypassSecurityTrust*` sin revisión de seguridad.
