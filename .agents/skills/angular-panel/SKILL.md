---
name: angular-panel
description: Cómo construir el panel interno de Knock en Angular con Angular Material (moderación de reportes, verificación de identidad, métricas y catálogos) con rutas protegidas por permiso, doble factor y cliente TypeScript generado. Úsala en cada historia con capa [Panel].
---

# angular-panel

## Estructura (`panel/`)
```
src/app/
  core/        # auth (sesión, guardas por permiso, 2FA), interceptores, manejo de errores, i18n
  shared/      # componentes y pipes reutilizables (tablas, filtros, diálogos de confirmación)
  features/<feature>/
    pages/        # componentes de ruta (standalone)
    components/   # componentes de presentación
    services/     # fachada de la feature: llama al cliente generado y expone signals/observables
    models/
  api/         # cliente generado desde contracts/openapi.v1.json (no se edita)
e2e/           # Playwright + axe
```

## Reglas
- Componentes standalone con `ChangeDetectionStrategy.OnPush` y signals; nada de lógica de negocio en plantillas.
- Los componentes **no** usan `HttpClient`: llaman al servicio de su feature, que usa `src/app/api`. Una feature no importa internos de otra; lo común va a `shared/` o `core/`.
- Rutas protegidas con guardas por permiso (`verification:review`, `reports:moderate`, `metrics:read`); la autorización real la hace el backend (403).
- Formularios reactivos tipados con validación; mensajes de error claros.
- Seguridad: sin `[innerHTML]` ni `bypassSecurityTrust*`; las fotos de verificación se muestran con el enlace temporal de 5 min y nunca se descargan ni se guardan en caché; cierre de sesión por inactividad.
- TypeScript `strict`, ESLint (angular-eslint) sin errores, sin `any` salvo excepción registrada.
- Accesibilidad: Angular Material con etiquetas, foco visible, navegación por teclado, contraste ≥ 4.5:1.

## Pruebas
Ver skill `testing-strategy-frontend` (unitarias con `ng test`, E2E y accesibilidad con Playwright + axe, mutación con StrykerJS).
