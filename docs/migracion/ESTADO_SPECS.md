# Estado de las specs (2026-11-03)

**Cómo leerlo.** *Estado* es lo que dice cada `spec.md`: Borrador → Aprobada (una persona; habilita el código) → Firmada (tras el merge) → Implementada. *Con prueba* cuenta los casos TC de la spec que aparecen nombrados en alguna prueba del repositorio; **no significa que la prueba pase ni que el código esté completo**. Las tareas de proceso o configuración (repositorio, ramas, Jira, SDD, Azure, CI) se verifican con comandos, no con pruebas, y por eso salen «sin pruebas».

## Specs del equipo (`specs/_legacy`)
Resumen por estado: 15 Aprobada.

| Spec | Estado | Casos | Con prueba | Avance en pruebas |
|---|---|---|---|---|
| HU-052-elegir-idioma-y-tema-en-configuracion | Aprobada | 12 | 10 | parcial (10/12) |
| TT-CI-01-github-actions-en-cada-pr-job-branch-nam | Aprobada | 4 | 0 | sin pruebas |
| TT-FB-01-proyecto-de-firebase-autenticacion-por-t | Aprobada | 4 | 0 | sin pruebas |
| TT-MOB-01-proyecto-flutter-con-clean-architecture | Aprobada | 4 | 3 | parcial (3/4) |
| TT-MOB-02-tema-claro-oscuro-y-traducciones-arb | Aprobada | 4 | 4 | completo |
| TT-MOB-04-spike-google-maps-pines-agrupacion | Aprobada | 7 | 5 | parcial (5/7) |
| TT-PRU-02-pantalla-flutter-que-lista-los-oficios | Aprobada | 12 | 10 | parcial (10/12) |
| TT-PRU-03-crear-proyecto-angular-panel-administracion | Aprobada | 4 | 3 | parcial (3/4) |
| TT-REPO-01-crear-repositorios-knock-backend-y-frontend | Aprobada | 3 | 0 | sin pruebas |
| TT-REPO-02-ramas-main-release-develop-y-sprint-00-c | Aprobada | 4 | 0 | sin pruebas |
| TT-REPO-03-conectar-github-con-jira-clave-knock-par | Aprobada | 2 | 0 | sin pruebas |
| TT-SDD-01-constitucion-agents-md-y-skills-base-par | Aprobada | 5 | 0 | sin pruebas |
| TT-STD-01-reglas-de-codificacion-editorconfig-anal | Aprobada | 4 | 0 | sin pruebas |
| TT-WEB-01-landing-page-minima-railway | Aprobada | 9 | 7 | parcial (7/9) |
| TT-WEB-02-paginas-de-aviso-de-privacidad-y-manejo-de-datos | Aprobada | 12 | 0 | sin pruebas |

## Specs de Demo Base (`specs/NNN-tema`)
Todas están en **Borrador**: ninguna está aprobada ni firmada, y ninguna tiene código propio que la implemente. El código que existe (Hosting y Catalog en `Knock.Market.Api`) viene de las specs del equipo de arriba.
