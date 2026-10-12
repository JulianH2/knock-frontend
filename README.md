# knock-frontend

App móvil y panel interno de **Knock** — gente de confianza, cerca de ti.
Flutter (Android e iOS, Clean Architecture, Riverpod) · Angular + Angular Material (panel de moderación, verificación y métricas).
La API y la base de datos están en **knock-backend**; el contrato llega a `contracts/`.

## Empieza aquí
| Si quieres… | Lee |
|---|---|
| Entender la arquitectura y por qué | [`docs/DECISION_TECNICA.md`](docs/DECISION_TECNICA.md) |
| Las reglas no negociables | [`.specify/memory/constitution.md`](.specify/memory/constitution.md) |
| Trabajar en el código (personas o agentes) | [`AGENTS.md`](AGENTS.md) · [`CONTRIBUTING.md`](CONTRIBUTING.md) |
| Usar tu agente de IA con SDD | [`docs/SDD_GUIA.md`](docs/SDD_GUIA.md) · [`docs/AGENTES_GUARDARRAILES.md`](docs/AGENTES_GUARDARRAILES.md) |
| Ver las specs del backlog | [`specs/README.md`](specs/README.md) |
| Controles de calidad y seguridad | [`docs/QA_DEVSECOPS.md`](docs/QA_DEVSECOPS.md) · [`SECURITY.md`](SECURITY.md) |
| Mapa de código | [`docs/architecture/CODEMAP.md`](docs/architecture/CODEMAP.md) · `docs/architecture/graph.html` |
| Configurar GitHub | [`docs/BRANCH_PROTECTION.md`](docs/BRANCH_PROTECTION.md) |

## Primeros pasos
```bash
python scripts/install_githooks.py
python scripts/sync_agents.py
```
La app se crea en **TT-MOB-01** (`flutter create app`) y el panel en **TT-PRU-03** (`ng new panel`); después copia las
configuraciones de [`docs/templates/`](docs/templates/README.md).

## Estructura
`app/` Flutter · `panel/` Angular · `contracts/` contrato de la API · `specs/` · `docs/` · `security/` · `scripts/`
