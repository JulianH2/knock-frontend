---
name: flutter-dart
description: Reglas al editar la app Flutter de Knock
paths: ["app/lib/**/*.dart", "app/test/**/*.dart", "app/integration_test/**/*.dart"]
---

# Reglas de la app (Dart)

- Antes de crear un widget, caso de uso o repositorio: `python scripts/codemap.py --query "<qué necesitas>"` y revisa `app/lib/core`.
- `features/<feature>/{presentation,domain,data}`; `domain/` es Dart puro; `presentation/` no llama HTTP; una feature no usa internos de otra.
- HTTP solo con `app/packages/knock_api` (generado). Tokens en almacenamiento seguro.
- 4 estados por pantalla, textos en ARB, accesibilidad (Semantics, contraste, texto escalado).
- Pruebas con el caso en el nombre; prohibido `skip:`. Skill: `flutter-clean-architecture`.
