# TT-WEB-02 — tareas

## T1 — Estructura de las páginas legales [Landing]
- **Crear:** `landing/privacidad/index.html`, `landing/privacidad/simplificado/index.html`, `landing/eliminar-cuenta/index.html` con `lang="es-MX"`, `data-estado="borrador"`, `data-version`, versión y fecha visibles, índice, secciones `h2` con los `id` de la spec §4 y §7, un `data-categoria` por fila del inventario §5 y marcadores `[PENDIENTE: …]` donde va el texto del líder.
- **Modificar:** —
- **Verificar:** TC-TT-WEB-02-03 · TC-TT-WEB-02-04 · TC-TT-WEB-02-05 · TC-TT-WEB-02-06 · TC-TT-WEB-02-07 · TC-TT-WEB-02-08 · TC-TT-WEB-02-09 · TC-TT-WEB-02-10
- **No hacer:** redactar texto legal presentado como definitivo; poner `data-estado="vigente"`; agregar `<script>`, `<form>`, fuentes o recursos de otros orígenes; escribir correos, teléfonos o domicilios personales.
- **Agente:** el que defina TT-WEB-01 para la landing (hoy no hay agente de landing en `.agents/knock.json`; lo hace el autor con apoyo de IA)

## T2 — Enlaces desde la landing [Landing]
- **Modificar:** pie de página de la landing (TT-WEB-01): enlaces a `/privacidad/` y `/eliminar-cuenta/` con texto descriptivo.
- **Verificar:** TC-TT-WEB-02-02
- **No hacer:** cambiar otras partes de la landing; agregar analítica a las páginas legales.

## T3 — Pruebas [Pruebas]
- **Crear:** `landing/tests/test_paginas_legales.py` (`unittest` + `html.parser`, sin red ni dependencias) con una prueba por caso TC-02 a TC-10, nombres `test_TC_TT_WEB_02_KK_…`.
- **Verificar:** `python -m unittest discover -s landing/tests -v`; romper a propósito cada regla una vez y comprobar que su prueba falla.
- **No hacer:** `skip`, pruebas que solo comprueban que el archivo existe.

## T4 — Texto del líder y estado vigente [Contenido]
- **Modificar:** las 3 páginas con el texto que entregue o apruebe José Julián; él cambia `data-estado` a `vigente` y la versión a `1.0` en un commit propio.
- **Verificar:** TC-TT-WEB-02-07 (sin `[PENDIENTE` en `vigente`) · TC-TT-WEB-02-10
- **No hacer:** que el agente o el autor marquen `vigente`.

## T5 — Publicación y evidencia [Landing]
- **Verificar:** TC-TT-WEB-02-01 · TC-TT-WEB-02-02 · TC-TT-WEB-02-07 · TC-TT-WEB-02-09 con los comandos de `plan.md §5` contra la URL de Railway; capturas en Chrome de Android y escritorio.
- **No hacer:** desplegar a mano fuera del mecanismo de TT-WEB-01.

## T6 — Documentación
- **Modificar:** `Memoria.md` (estado, decisiones, dudas resueltas); avisar a TT-MOB-06 y TT-TIE-03 las URLs finales.
- **Agente:** docs-keeper
