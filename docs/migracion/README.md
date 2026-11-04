# Migración desde el repositorio del equipo (JulianH2/knock-frontend)

Fecha: 2026-11-03. Origen: rama `sprint-02`, respaldada en el bundle `_respaldos/knock-frontend-origen-2026-11-03.bundle` y en la etiqueta `legacy-2026-11-03` del espejo. No se conservó el historial: la autoría va en el autor y los `Co-authored-by` de cada commit de la rama `migracion`, y en las secciones «Responsable» y «Aprobación» de cada spec.

## Qué se migró y dónde quedó
| Origen | Destino |
|---|---|
| `specs/` (TT y HU) | `specs/_legacy/` tal cual, con su estado y firmas |
| `docs/` (backlog, decisiones, arquitectura, referencias, guías) | `docs/` y `docs/migracion/` |
| Constitución, `AGENTS.md` y `Memoria.md` del origen | `docs/migracion/*_origen.md` (no sustituyen a los de Demo Base) |
| `.agents`, `.claude`, `.codex`, `.cursor`, `.gemini`, `.opencode`, `.specify`, skills | Misma ruta; los adaptadores se regeneraron con `sync_agents.py` |
| Workflows, `scripts/`, `security/`, configuraciones de calidad | Misma ruta, adaptados (ver abajo) |
| `app/`, `panel/`, `landing/` | Misma ruta (sustituyen a las plantillas vacías de Demo Base) |

## Cambios hechos al migrar
- Los workflows usan `global.json` para la versión de .NET (net11.0); se desactivó la verificación de nombre de rama `KNOCK-n`.
- `scripts/sdd_lint.py` valida solo `specs/_legacy` (formato TT/HU); las specs `NNN-tema` aún no tienen validador.
- `scripts/codemap.py` y `.jscpd.json` ignoran `legacy/`.
- Las skills `api-client-contract` y `flutter-clean-architecture` (frontend) se sustituyeron por las del equipo; la versión anterior está en el historial de la rama.
- El `spec-writer` de `.opencode` se sustituyó por el generado; el anterior está en `docs/migracion/spec-writer_destino.md`.

## Estado de las specs (12 sin firma o en borrador)
| Spec | Procede de | Estado | Responsable | Revisión |
|---|---|---|---|---|
| HU-052-elegir-idioma-y-tema-en-configuracion | origen (equipo) | Aprobada | Erick Trejo Reséndiz | José Julián Hernández Hernández (2026-11-02) |
| TT-CI-01-github-actions-en-cada-pr-job-branch-nam | origen (equipo) | Aprobada | José Julián Hernández Hernández | José Julián Hernández Hernández (2026-10-12) |
| TT-FB-01-proyecto-de-firebase-autenticacion-por-t | origen (equipo) | Aprobada | José Julián Hernández Hernández | José Julián Hernández Hernández (2026-10-12) |
| TT-MOB-01-proyecto-flutter-con-clean-architecture | origen (equipo) | Aprobada | Erick Trejo Reséndiz | José Julián Hernández Hernández (2026-10-16) |
| TT-MOB-02-tema-claro-oscuro-y-traducciones-arb | origen (equipo) | Aprobada | Erick Trejo Reséndiz | José Julián Hernández Hernández (2026-10-22) |
| TT-MOB-04-spike-google-maps-pines-agrupacion | origen (equipo) | Aprobada | Erick Trejo Reséndiz | José Julián Hernández Hernández (2026-10-22) |
| TT-PRU-02-pantalla-flutter-que-lista-los-oficios | origen (equipo) | Aprobada | José Guillermo Rangel Hernández | José Julián Hernández Hernández (2026-10-25) |
| TT-PRU-03-crear-proyecto-angular-panel-administracion | origen (equipo) | Aprobada | Ángel Alexis Blas Castillo | José Julián Hernández Hernández (2026-10-14) |
| TT-REPO-01-crear-repositorios-knock-backend-y-frontend | origen (equipo) | Aprobada | José Julián Hernández Hernández | José Julián Hernández Hernández (2026-10-12) |
| TT-REPO-02-ramas-main-release-develop-y-sprint-00-c | origen (equipo) | Aprobada | José Julián Hernández Hernández | José Julián Hernández Hernández (2026-10-12) |
| TT-REPO-03-conectar-github-con-jira-clave-knock-par | origen (equipo) | Aprobada | José Julián Hernández Hernández | José Julián Hernández Hernández (2026-10-12) |
| TT-SDD-01-constitucion-agents-md-y-skills-base-par | origen (equipo) | Aprobada | José Julián Hernández Hernández | José Julián Hernández Hernández (2026-10-12) |
| TT-STD-01-reglas-de-codificacion-editorconfig-anal | origen (equipo) | Aprobada | José Julián Hernández Hernández | José Julián Hernández Hernández (2026-10-12) |
| TT-WEB-01-landing-page-minima-railway | origen (equipo) | Aprobada | Erick Trejo Reséndiz | José Julián Hernández Hernández (2026-11-03) |
| TT-WEB-02-paginas-de-aviso-de-privacidad-y-manejo-de-datos | origen (equipo) | Aprobada | Erick Trejo Reséndiz | José Julián Hernández Hernández (2026-11-03) |
| 001-arquitectura-de-la-app-movil | Demo Base | Borrador | — | sin firma |
| 002-piezas-comunes-de-la-app | Demo Base | Borrador | — | sin firma |
| 003-arquitectura-del-panel-web | Demo Base | Borrador | — | sin firma |
| 004-landing-page-estructura-y-publicacion | Demo Base | Borrador | — | sin firma |
| 005-estructura-del-repositorio-y-flujo-de-trabajo | Demo Base | Borrador | — | sin firma |
| 006-contrato-de-la-api-y-cliente-generado | Demo Base | Borrador | — | sin firma |
| 007-integracion-continua-y-publicacion | Demo Base | Borrador | — | sin firma |
| 008-calidad-pruebas-y-estandares | Demo Base | Borrador | — | sin firma |
| 009-seguridad-y-configuracion-del-cliente | Demo Base | Borrador | — | sin firma |
| 010-cache-y-trabajo-sin-conexion | Demo Base | Borrador | — | sin firma |
| 011-versionamiento-por-puntos | Demo Base | Borrador | — | sin firma |
| 012-notificaciones-push-y-permisos-del-telefono | Demo Base | Borrador | — | sin firma |
