# Pendientes y decisiones de la migración (frontend)

Foto del 2026-11-03, rama `migracion`. Nada de esto se ha mezclado en `main`.

## Migrado
`app/` (Flutter), `panel/` (Angular 22), `landing/`, specs a `specs/_legacy/`, docs, agentes, skills y CI. El detalle y las firmas están en `docs/migracion/README.md`.

## Verificado
`sdd_lint`, `sync_agents --check`, `codemap --check`, `check_exceptions` y `pin_actions --check`: en verde.
**No verificado:** `flutter analyze`/`flutter test`, `ng test` y la compilación del panel; los workflows de Actions.

## Pendiente
1. **PR abiertos del origen** (no migrados): #53 (HU-001 app, borrador) y #54 (TT-WEB-02, estructura de páginas legales). Cuando se fusionen se traen.
2. **Landing:** el texto legal sigue como borrador con marcadores; hay que cerrar el nombre legal y el domicilio.
3. **Constitución:** misma fusión que en backend (`docs/migracion/constitution_origen.md`).
4. **Specs sin firma:** ver `docs/migracion/README.md`.
5. **Rulesets:** llenar las comprobaciones obligatorias con los jobs del CI.
