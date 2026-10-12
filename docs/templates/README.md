# Plantillas de configuración (copiar al crear los proyectos)

Los proyectos `app/` (TT-MOB-01, `flutter create`) y `panel/` (TT-PRU-03, `ng new`) se generan con sus herramientas.
Después de crearlos, copia estos archivos (los workflows ya los esperan):

| Archivo | Destino | Para qué |
|---|---|---|
| `app/analysis_options.yaml` | `app/analysis_options.yaml` | Lints estrictos y tipos (`flutter analyze --fatal-infos`) |
| `app/mutation_test.xml` | `app/mutation_test.xml` | Mutación de `domain/` con umbral 70 % (nightly) |
| `app/layer_rules_test.dart` | `app/test/architecture/layer_rules_test.dart` | Prueba de capas: `domain/` puro, `presentation/` sin HTTP |
| `panel/playwright.config.ts` | `panel/playwright.config.ts` | E2E en 3 navegadores, humo con `@smoke`, capturas |
| `panel/a11y.spec.ts` | `panel/e2e/a11y.spec.ts` | Accesibilidad con axe en cada página |
| `panel/stryker.config.mjs` | `panel/stryker.config.mjs` | Mutación de services y guardas con umbral |

Cobertura del panel: configura el reporte `json-summary` (Istanbul) en `ng test`; el CI lee `panel/coverage/coverage-summary.json`.

Paquetes de desarrollo a evaluar e instalar (registrar en `Memoria.md`):
- App: `mocktail`, `mutation_test`, `flutter_lints` (ya viene), `integration_test` (SDK).
- Panel: `@angular-eslint/*` (`ng add @angular-eslint/schematics`), `@playwright/test`, `@axe-core/playwright`,
  `@stryker-mutator/core` y el runner que corresponda al de `ng test`.
