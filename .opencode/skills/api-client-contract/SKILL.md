---
name: api-client-contract
description: Cómo el frontend consume el contrato OpenAPI del backend y genera sus clientes; úsala al especificar llamadas a la API.
---

# api-client-contract

- El contrato vive en `contracts/openapi.v1.json` y se actualiza copiándolo del backend.
- Los clientes generados no se editan a mano.
- El CI regenera el cliente y falla si no corresponde al contrato.
