---
name: testing-strategy-frontend
description: Estrategia de pruebas de knock-frontend - unitarias, widget y componentes, aceptación por caso TC, E2E en emulador y navegador, accesibilidad, compatibilidad, contrato, mutación (mutation_test y StrykerJS), regresión visual y usabilidad. Úsala al planear y escribir pruebas de la app o el panel.
---
<!-- GENERADO por scripts/sync_agents.py desde .agents/skills/testing-strategy-frontend/SKILL.md. No editar a mano. -->
# testing-strategy-frontend

| Tipo | App (Flutter) | Panel (Angular) | Nivel CI |
|---|---|---|---|
| Unitarias (UM) | `app/test/**` casos de uso y controladores con `mocktail` | `*.spec.ts` de servicios y guardas (`ng test`) | PR |
| Widget / componentes (W) | `testWidgets` por estado de pantalla | pruebas de componente con TestBed | PR |
| Aceptación (ACC) | una prueba por caso `TC-<ID>-KK` de este repo | ídem | PR (trazabilidad) |
| Contrato (CON) | clientes regenerados = contrato | ídem | PR |
| E2E | `integration_test` en emulador Android (recorrido principal de cada historia) | Playwright (chromium, firefox, webkit) | PR (humo) + nightly (completo) |
| Accesibilidad (A11Y) | `meetsGuideline` (contraste, tamaño táctil, etiquetas) en widget tests | `@axe-core/playwright` sin violaciones serias | PR |
| Compatibilidad | build Android + iOS (macOS runner) | 3 navegadores | nightly |
| Mutación (MUT) | paquete `mutation_test` sobre `domain/` | StrykerJS sobre `services/` y guardas | nightly |
| Regresión | suite completa + capturas doradas (`matchesGoldenFile`) de pantallas clave | capturas de Playwright | nightly |
| Usabilidad (USA) | 5 personas sin capacitación, SUS ≥ 70 (TT-QA-03/05) | ídem | manual |

## Reglas
- Nombre con el caso: `'TC-HU-024-03 …'`.
- Nada de llamadas reales a la API en unitarias/widget: repositorios falsos. E2E contra Staging o el backend local con datos ficticios y números de prueba de Firebase.
- Prohibido `skip:`, `xit`, `fit`, `.only`, `.skip` o bajar umbrales.
- Cobertura mínima: app 50 % líneas; panel 60 % líneas y 50 % ramas. Mutación: `domain/` de features críticas (auth, requests) ≥ 70 %.
