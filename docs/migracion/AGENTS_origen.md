# AGENTS.md — knock-frontend

> Manual operativo para **cualquier agente de IA** (Claude Code, Codex, Copilot, Cursor, Gemini CLI, opencode…) y para las personas del equipo.
> Rector: `.specify/memory/constitution.md` (espejo `./constitution.md`). Porqué: `docs/DECISION_TECNICA.md`. Este archivo dice **cómo**.
> Este repositorio contiene la **app móvil Flutter** (`app/`) y el **panel interno Angular** (`panel/`). La API y la base de datos viven en `knock-backend`.

## 0. Antes de tocar nada
1. Lee `Memoria.md` y la spec del issue: `specs/<ID>-*/spec.md` (índice en `specs/README.md`).
2. La spec debe estar **Aprobada** y tener la clave `KNOCK-<N>` de tu rama `<tipo>/KNOCK-<N>-<english-description>`. Si no, detente.
3. Sigue la skill **`story-workflow`**.
4. Antes de crear algo: `python scripts/codemap.py --query "<qué necesitas>"` (skill `reuse-before-create`).
5. Si necesitas un endpoint que no está en `contracts/openapi.v1.json`, la parte de backend va primero (skill `api-client-contract`).

## 1. Forma de trabajo
- 1 issue de Jira = 1 rama = 1 PR hacia la rama `sprint-XX` actual. Ramas, commits y PR según `CONTRIBUTING.md`: commits en inglés (`type(scope): description (KNOCK-N)`, p. ej. `feat(requests): upload up to 5 photos with the request (KNOCK-45)`), ramas `<tipo>/KNOCK-N-english-kebab-description`.
- Orden: contrato vendorizado y clientes al día → dominio/casos de uso (app) o servicio de feature (panel) + unitarias → pantalla/página con sus estados + widget/componente → accesibilidad → E2E del recorrido → gates → `Memoria.md` → informe.

## 2. Comandos
```bash
# Contrato y clientes generados
python scripts/sync_contract.py --from ../knock-backend   # o el PR automático de contract-publish
bash scripts/gen_clients.sh all                           # dart → app/packages/knock_api · ts → panel/src/app/api
# App (Flutter)
cd app && flutter pub get
dart format --set-exit-if-changed lib test
flutter analyze --fatal-infos
flutter test --coverage
flutter test integration_test            # emulador o dispositivo
dart run mutation_test                    # mutación (nightly)
# Panel (Angular)
cd panel && npm ci
npx ng lint && npx tsc -p tsconfig.app.json --noEmit
npx ng test --watch=false --code-coverage
npx playwright test                       # E2E + accesibilidad (axe)
npx stryker run                           # mutación (nightly)
# Gobierno (los mismos que corre el CI)
python scripts/sdd_lint.py && python scripts/sdd_lint.py --trace <ID>
python scripts/codemap.py --check
python scripts/ci/check_exceptions.py
python scripts/sync_agents.py --check
```

## 3. Memoria
- Al terminar agrega a `Memoria.md`: estado, decisiones (con porqué) y errores a evitar. Nunca datos sensibles.

## 4. Límites — no hacer
- **Nunca** agregues atribución a IA en commits o PR: ni trailers `Co-Authored-By` de agentes (Claude, Copilot, Codex, Gemini, Cursor, opencode o `noreply@anthropic.com`), ni líneas «Generated with…». El uso de IA se declara solo en la sección «Uso de IA» de la plantilla del PR. Un `Co-Authored-By` de una persona del equipo (trabajo en parejas) sí se permite. El hook `commit-msg` y el CI rechazan lo primero.
- No editar `contracts/`, `app/packages/knock_api/` ni `panel/src/app/api/` (generados).
- App: `domain/` sin flutter/dio/riverpod/knock_api; `presentation/` sin HTTP; una feature no usa internos de otra.
- Panel: componentes sin `HttpClient`; sin `[innerHTML]` ni `bypassSecurityTrust*`; sin `any`.
- Tokens solo en almacenamiento seguro (nunca SharedPreferences/localStorage). Nada de datos personales en logs o Sentry.
- No desactivar pruebas, reglas o escáneres; no bajar umbrales; no suprimir sin `EXC-NNN`; no agregar paquetes sin evaluación.
- No publicar en tiendas ni tocar credenciales de firma; no usar datos reales.

## 5. Definición de terminado (gates)
- App: `dart format` sin cambios, `flutter analyze --fatal-infos` limpio, `flutter test` verde, cobertura ≥ 50 %.
- Panel: `ng lint`, `tsc --noEmit`, `ng test` verde, cobertura ≥ 60 % líneas / 50 % ramas, Playwright + axe sin violaciones serias.
- Clientes generados idénticos al contrato vendorizado.
- Cada caso `TC-<ID>-KK` de este repo con prueba (`sdd_lint.py --trace`).
- `codemap.py --check`, `check_exceptions.py`, `sdd_lint.py`, `sync_agents.py --check` en OK.
- `security-reviewer` LIBERA, `traceability-clerk` sin drift, informe de `story-workflow` en el PR, `Memoria.md` al día.

## 6. Convenciones técnicas
- App: Riverpod (Notifier → UiState inmutable), go_router con redirect por sesión, ARB es/en, tema claro/oscuro, 4 estados por pantalla.
- Panel: standalone + OnPush + signals, formularios reactivos tipados, guardas por permiso, Angular Material.

## 7. Seguridad
Matriz en la skill `security-core`. Sesión con Firebase + tokens propios en almacenamiento seguro; fotos de verificación solo por enlace temporal; IA etiquetada y sin datos personales.

## 8. Pruebas
Skill `testing-strategy-frontend`. Nombres con el caso TC; sin red en unitarias; E2E con datos ficticios y números de prueba de Firebase.

## 9. Sub-agentes
| Agente | Edita | Cuándo |
|---|---|---|
| `spec-writer` | `specs/**`, `Memoria.md` | Antes de implementar |
| `flutter-builder` | `app/lib`, `app/test`, `app/integration_test` | Capa [Mobile] |
| `panel-builder` | `panel/src`, `panel/e2e` | Capa [Panel] |
| `security-reviewer` | **Nada** | Antes del PR |
| `traceability-clerk` | **Nada** | Antes del PR |
| `docs-keeper` | `**/*.md` | Al cerrar |

## 10. Estructura
| Ruta | Contenido |
|---|---|
| `app/` | App Flutter (`lib/core`, `lib/features`, `test`, `integration_test`, `packages/knock_api` generado) |
| `panel/` | Panel Angular (`src/app/{core,shared,features,api}`, `e2e`) |
| `contracts/` | `openapi.v1.json` vendorizado desde knock-backend |
| `specs/` | specs por issue · `docs/` decisión técnica, arquitectura, QA · `security/` excepciones |
| `scripts/` | gates, mapa de código, guardián de agentes, contrato y clientes, CI |

## 11. Archivos generados
Adaptadores de agentes (`CLAUDE.md`, `GEMINI.md`, `.claude/`, `.opencode/`, `.codex/`, `.gemini/`, `.cursor/`, `.github/copilot-instructions.md`, `.github/agents|instructions|hooks/`) con `python scripts/sync_agents.py`; `docs/architecture/*` con `scripts/codemap.py`; clientes con `scripts/gen_clients.sh`.

<!-- skills-index:start -->
## 12. Índice de skills, agentes y reglas (generado)

> Si tu herramienta no carga skills por sí sola, abre el `SKILL.md` indicado cuando la tarea coincida con su descripción.

| Skill | Cuándo usarla | Archivo |
|---|---|---|
| `angular-panel` | Cómo construir el panel interno de Knock en Angular con Angular Material (moderación de reportes, verificación de identidad, métricas y catálogos) con rutas protegidas por permiso, doble factor y cliente TypeScript generado. Úsala en cada historia con capa [Panel]. | `.agents/skills/angular-panel/SKILL.md` |
| `api-client-contract` | Cómo consume knock-frontend el contrato de knock-backend - contrato vendorizado en contracts/, clientes Dart y TypeScript generados, verificación en CI y qué hacer cuando cambia la API. Úsala cuando una historia use un endpoint nuevo o modificado. | `.agents/skills/api-client-contract/SKILL.md` |
| `devsecops-audit` | Auditoría integral de calidad, pruebas, seguridad y DevSecOps de un repositorio de Knock por fases (inventario, propuesta priorizada, implementación incremental, verificación, informe). Úsala cuando pidan auditar el repositorio o revisar que los controles existen y funcionan. | `.agents/skills/devsecops-audit/SKILL.md` |
| `flutter-clean-architecture` | Cómo construir una feature de la app móvil de Knock en Flutter con Clean Architecture de 3 capas, Riverpod, go_router, cliente Dart generado desde OpenAPI, sesión con Firebase, chat SignalR e i18n ARB. Úsala en cada historia con capa [Mobile]. | `.agents/skills/flutter-clean-architecture/SKILL.md` |
| `reuse-before-create` | Obliga a buscar en el mapa de código de Knock antes de crear una clase, función, servicio, widget, componente o archivo nuevo, para reutilizar o extender lo existente y evitar duplicados. Úsala siempre que vayas a crear algo nuevo. | `.agents/skills/reuse-before-create/SKILL.md` |
| `security-core` | Matriz de seguridad y privacidad de Knock basada en OWASP Top 10 y OWASP API Security Top 10 (autenticación, autorización por recurso, entradas, datos sensibles y biométricos, archivos, sesiones, límites, secretos, cadena de suministro). Úsala al construir endpoints o pantallas y al revisar antes del PR. | `.agents/skills/security-core/SKILL.md` |
| `spec-first-writing` | Refina el borrador de spec de una historia (HU-NNN), tarea técnica (TT-ÁREA-NN) o defecto (BUG-NNN) de Knock antes de escribir código - alcance por capa, contrato, amenazas, verificación por caso y plan de pruebas. Úsala al iniciar cualquier issue o cuando pidan algo sin spec. | `.agents/skills/spec-first-writing/SKILL.md` |
| `story-workflow` | Flujo obligatorio de Knock para implementar cualquier historia, tarea técnica, bug, refactor o cambio de arquitectura - leer, analizar amenazas, planear pruebas por criterio, implementar, verificar de verdad e informar con honestidad. Úsala siempre antes de cambiar código. | `.agents/skills/story-workflow/SKILL.md` |
| `testing-strategy-frontend` | Estrategia de pruebas de knock-frontend - unitarias, widget y componentes, aceptación por caso TC, E2E en emulador y navegador, accesibilidad, compatibilidad, contrato, mutación (mutation_test y StrykerJS), regresión visual y usabilidad. Úsala al planear y escribir pruebas de la app o el panel. | `.agents/skills/testing-strategy-frontend/SKILL.md` |
| `traceability` | Verifica la trazabilidad spec ↔ código ↔ prueba de un issue de Knock (casos TC-<ID>-KK, endpoints, eventos, alcance) y reporta drift sin editar. Úsala antes de cada PR. | `.agents/skills/traceability/SKILL.md` |

| Agente | Para qué | Archivo |
|---|---|---|
| `docs-keeper` | Mantiene vivos los Markdown de Knock (README, docs, índice de specs y Memoria) al cerrar un issue, sin tocar código. | `.agents/agents/docs-keeper.md` |
| `flutter-builder` | Implementa la capa [Mobile] de un issue aprobado en la app Flutter de Knock (casos de uso, repositorio, controlador, pantallas, ARB, accesibilidad y pruebas) usando el cliente generado y siguiendo story-workflow. | `.agents/agents/flutter-builder.md` |
| `panel-builder` | Implementa la capa [Panel] de un issue aprobado en el panel Angular de Knock (páginas, componentes, servicios de feature, guardas por permiso, accesibilidad y pruebas) usando el cliente TypeScript generado y siguiendo story-workflow. | `.agents/agents/panel-builder.md` |
| `security-reviewer` | Audita sin editar la seguridad y privacidad del cambio de un issue de Knock (OWASP Top 10 y API Top 10, amenazas de la spec, datos sensibles, cadena de suministro) y entrega PASS/FAIL; un FAIL bloquea. | `.agents/agents/security-reviewer.md` |
| `spec-writer` | Refina el borrador de spec de un issue de Knock (HU, TT o BUG) - clave de Jira, verificación por caso, alcance por capa, contrato, amenazas y plan de pruebas - sin tocar código. Úsalo antes de implementar. | `.agents/agents/spec-writer.md` |
| `traceability-clerk` | Reporta sin editar el drift entre la spec, el código y las pruebas de un issue de Knock antes del PR. | `.agents/agents/traceability-clerk.md` |

| Regla | Aplica a | Archivo |
|---|---|---|
| `angular-ts` | `panel/src/**/*.ts`, `panel/src/**/*.html`, `panel/src/**/*.scss`, `panel/e2e/**/*.ts` | `.agents/rules/angular-ts.md` |
| `flutter-dart` | `app/lib/**/*.dart`, `app/test/**/*.dart`, `app/integration_test/**/*.dart` | `.agents/rules/flutter-dart.md` |
| `specs` | `specs/**` | `.agents/rules/specs.md` |
| `tests-frontend` | `app/test/**`, `app/integration_test/**`, `panel/src/**/*.spec.ts`, `panel/e2e/**` | `.agents/rules/tests-frontend.md` |
<!-- skills-index:end -->
