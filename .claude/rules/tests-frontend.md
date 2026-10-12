---
paths:
  - 'app/test/**'
  - 'app/integration_test/**'
  - 'panel/src/**/*.spec.ts'
  - 'panel/e2e/**'
---
<!-- GENERADO por scripts/sync_agents.py desde .agents/rules/tests-frontend.md. No editar a mano. -->
# Reglas de pruebas (frontend)

- Nombre con el caso: `'TC-HU-024-03 …'`.
- Unitarias y widget/componente sin red: repositorios o servicios falsos. E2E con datos ficticios y números de prueba de Firebase.
- Prohibido `skip:`, `xit`, `fit`, `.only`, `.skip`, bajar umbrales o reescribir una prueba para aceptar un comportamiento incorrecto.
- Capturas doradas solo se actualizan con `--update-goldens` en un PR que explique el cambio visual.
- Skill: `testing-strategy-frontend`.
