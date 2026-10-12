---
name: flutter-clean-architecture
description: Cómo construir una feature de la app móvil de Knock en Flutter con Clean Architecture de 3 capas, Riverpod, go_router, cliente Dart generado desde OpenAPI, sesión con Firebase, chat SignalR e i18n ARB. Úsala en cada historia con capa [Mobile].
---

# flutter-clean-architecture

## Estructura (`app/`)
```
lib/
  core/        # red (interceptor de sesión), errores (Failure), tema, i18n, almacenamiento seguro, analítica
  features/<feature>/
    presentation/   # <x>_screen.dart, widgets/, <x>_controller.dart (Notifier → UiState inmutable)
    domain/         # entities/, usecases/, repositories/ (interfaces) — Dart puro
    data/           # repositories/ (implementación), mappers/ (DTO generado → entidad)
packages/knock_api/ # cliente generado desde contracts/openapi.v1.json (no se edita)
test/  integration_test/
```

## Reglas
- `domain/` no importa flutter, dio, riverpod ni knock_api; `presentation/` no importa dio ni knock_api. Una feature no usa `data/` ni `domain/` de otra: lo compartido va a `core/`.
- HTTP solo con `packages/knock_api`; errores ProblemDetails → `Failure` tipado; 401 → el interceptor renueva el token o lleva a iniciar sesión y regresa a la acción pendiente.
- Cada pantalla maneja cargando, vacío, error (con reintentar) y datos. Textos solo en ARB (es y en). Tema claro/oscuro con la paleta de la maqueta.
- Accesibilidad: `Semantics` en controles sin texto, contraste ≥ 4.5:1, soporta texto escalado al 200 %, áreas táctiles ≥ 48 dp.
- Sesión: Firebase Phone Auth → `POST /auth/session` → tokens en `flutter_secure_storage` (nunca SharedPreferences). Al cerrar sesión se borra el token de push.
- Chat: `signalr_netcore` con reconexión; si el socket falla, recarga por REST.
- IA: todo lo sugerido por IA se etiqueta «Sugerido por IA, revísalo» y es editable; la app nunca envía INE, CURP, dirección ni teléfono al asistente.
- Privacidad: el código de visita se guarda cifrado para mostrarse sin conexión; nada de datos personales en logs ni en Sentry.

## Pruebas
Ver skill `testing-strategy-frontend`. Nombre con el caso: `testWidgets('TC-HU-024-03 muestra el error sin fotos', …)`.
