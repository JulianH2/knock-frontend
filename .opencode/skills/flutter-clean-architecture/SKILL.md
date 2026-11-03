---
name: flutter-clean-architecture
description: Reglas de capas por función para la app Flutter con Riverpod y go_router; úsala al escribir specs de la app o revisar dependencias entre capas.
---

# flutter-clean-architecture

- Cada función tiene `presentation`, `domain` y `data`; `domain` es Dart puro, sin pantallas ni red.
- Los widgets no llaman a HTTP; usan controladores y repositorios inyectados con Riverpod.
- Cada pantalla se dibuja desde un estado: cargando, con datos, vacía o con error.
- Todo texto visible sale de los archivos de traducción; todo color y tipografía, del tema.
