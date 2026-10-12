---
name: api-client-contract
description: Cómo consume knock-frontend el contrato de knock-backend - contrato vendorizado en contracts/, clientes Dart y TypeScript generados, verificación en CI y qué hacer cuando cambia la API. Úsala cuando una historia use un endpoint nuevo o modificado.
---

# api-client-contract

## Flujo
1. knock-backend publica `docs/openapi.v1.json` en cada merge (workflow `contract-publish.yml`) y abre un PR aquí que actualiza `contracts/openapi.v1.json` (o se copia con `python scripts/sync_contract.py --from ../knock-backend`).
2. Se regeneran los clientes:
   - Dart: `bash scripts/gen_clients.sh dart` → `app/packages/knock_api/`
   - TypeScript (Angular): `bash scripts/gen_clients.sh ts` → `panel/src/app/api/`
3. El CI comprueba que los clientes generados coinciden con el contrato (`git diff --exit-code` tras regenerar) y que el contrato no tiene cambios incompatibles respecto a main (oasdiff).

## Reglas
- **Nunca** editar `contracts/`, `app/packages/knock_api/` ni `panel/src/app/api/` a mano (el guardián lo bloquea).
- Si una historia necesita un endpoint que no está en el contrato, la parte de backend va primero; aquí se usa un repositorio falso en pruebas mientras tanto, nunca un endpoint inventado.
- Un cambio incompatible del contrato exige versión nueva (`/api/v2`) acordada en ambas specs.
