---
paths:
  - 'panel/src/**/*.ts'
  - 'panel/src/**/*.html'
  - 'panel/src/**/*.scss'
  - 'panel/e2e/**/*.ts'
---
<!-- GENERADO por scripts/sync_agents.py desde .agents/rules/angular-ts.md. No editar a mano. -->
# Reglas del panel (Angular)

- Antes de crear un componente o servicio: `python scripts/codemap.py --query "<qué necesitas>"` y revisa `shared/` y `core/`.
- Standalone + OnPush + signals; componentes sin `HttpClient` (servicio de la feature → `src/app/api` generado).
- Rutas con guardas por permiso; nada de `[innerHTML]` ni `bypassSecurityTrust*`; TypeScript strict sin `any`.
- Pruebas con el caso en el nombre; prohibido `xit`, `fit`, `.only`, `.skip`. Skill: `angular-panel`.
