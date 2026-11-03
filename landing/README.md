# landing/ — sitio estático de Knock

> Spec: [`specs/TT-WEB-01-landing-page-minima-railway/spec.md`](../specs/TT-WEB-01-landing-page-minima-railway/spec.md) (KNOCK-148). El aviso de privacidad, el manejo de datos y `/eliminar-cuenta/` son de TT-WEB-02 (KNOCK-159).

HTML y CSS sin JavaScript ni build, servidos por nginx sin root (`nginxinc/nginx-unprivileged`, fijada por versión y digest) en el puerto 8080. Railway construye la imagen con el `Dockerfile` de esta carpeta. El `Dockerfile` aplica con `apk upgrade` los parches de Alpine que la imagen base aún no trae (lista en su comentario); al subir el digest base, revisa con Trivy si esa línea sigue haciendo falta.

## Rutas
| Ruta | Archivo | Nota |
|---|---|---|
| `/` | `index.html` | Inicio, bloque de Google Play y pie con la versión |
| `/privacidad/` | `privacidad/index.html` | Provisional «en preparación» (`data-estado="en-preparacion"`, `noindex`). TT-WEB-02 la reemplaza sin cambiar la ruta |
| cualquier otra | `404.html` | 404 propio (también para carpetas sin `index.html`) |
| `/favicon.ico` | — | 204 hasta tener el icono de la app |
| `/terminos/` | — | Reservada para la tarea de términos; todavía no existe |

## Correr en local
```bash
python -m unittest discover -s landing/tests -v      # desde la raíz del repositorio, sin red
docker build -t knock-landing landing
docker run -d --rm -p 8080:8080 --name kl knock-landing
curl -sI http://localhost:8080/            # cabeceras de seguridad
docker exec kl id -u                       # 101 (sin root)
docker stop kl
```
Si el puerto 8080 de tu máquina está ocupado, publica otro: `-p 18080:8080` y usa `http://localhost:18080/`.

Validar el HTML con el Nu HTML Checker fijado por digest (en Git Bash, antepón `MSYS_NO_PATHCONV=1`). La imagen trae el validador como `/vnu.jar`, no como `/vnu-runtime-image/bin/vnu`:
```bash
docker run --rm ghcr.io/validator/validator@sha256:8f21030474e68e06905cfa801b37376e99c0e37867c653c5b6cd7e2dcaf3f503 java -jar /vnu.jar --version
docker run --rm -v "$PWD/landing":/w ghcr.io/validator/validator@sha256:8f21030474e68e06905cfa801b37376e99c0e37867c653c5b6cd7e2dcaf3f503 java -jar /vnu.jar --skip-non-html /w
```

## Reglas que rompen la CSP si se ignoran
- Nada de `<script>`, `style=""`, `<style>`, atributos `on*`, formularios ni recursos de otro origen. La CSP es `default-src 'none'; style-src 'self'; font-src 'self'; img-src 'self'; …`.
- No declares `add_header` dentro de un `location` de `nginx.conf`: nginx deja de heredar las cabeceras del `server`. La caché usa `expires`.
- Los colores salen solo de los tokens `--color-*` de `css/landing.css`, con los pares permitidos de TT-MOB-02. La prueba TC-06 rechaza otro par.

## Google Play: de «próximamente» a «disponible»
Al nacer, `index.html` tiene la variante «próximamente». Cuando la ficha de Play sea pública, cambia en un PR esa línea por la variante «disponible» y sube la versión del pie:
```html
<!-- Antes -->
<p class="play" data-play="proximamente">Próximamente en Google Play</p>
<!-- Después -->
<p class="play" data-play="disponible"><a class="play-boton" href="https://play.google.com/store/apps/details?id=app.knock.mobile&amp;referrer=utm_source%3Dlanding%26utm_medium%3Dweb%26utm_campaign%3Dlanding">Descargar en Google Play</a></p>
```
Solo una variante puede estar presente. No uses `target="_blank"` (si algún día hace falta, con `rel="noopener noreferrer"`). La prueba `test_TC_TT_WEB_01_02_enlaces` exige la URL exacta.

## Fuentes
`fonts/nunito-400-latin.woff2` y `fonts/nunito-700-latin.woff2` son subconjuntos de `app/assets/fonts/nunito/Nunito-Regular.ttf` y `Nunito-Bold.ttf` (TT-MOB-02). `fonts/OFL.txt` es copia sin cambios de `app/assets/fonts/nunito/OFL.txt` (OFL 1.1, sin Reserved Font Name). Se generaron una vez con fontTools 4.68.0 y brotli 1.2.1 en un entorno virtual fuera del repositorio; no entran al contenedor ni al CI:
```bash
pyftsubset app/assets/fonts/nunito/Nunito-Regular.ttf --unicodes="U+0020-007E,U+00A0-00FF,U+2013-2014,U+2018-2019,U+201C-201D,U+2026" --flavor=woff2 --output-file=landing/fonts/nunito-400-latin.woff2
pyftsubset app/assets/fonts/nunito/Nunito-Bold.ttf --unicodes="U+0020-007E,U+00A0-00FF,U+2013-2014,U+2018-2019,U+201C-201D,U+2026" --flavor=woff2 --output-file=landing/fonts/nunito-700-latin.woff2
```
| Archivo | Bytes | SHA-256 |
|---|---|---|
| `nunito-400-latin.woff2` | 13 200 | `117502c8a30d28bec3fdebf04a6375e2cc6f1f43410bbaba55a5ac5af355dc2c` |
| `nunito-700-latin.woff2` | 13 144 | `af6534af220df798e5d1bef74283cfc989d5d516de268e61cd550ed1665f1710` |

## Railway (lo configura el líder)
- Servicio en el proyecto del líder conectado a `knock-frontend` con la app de GitHub de Railway limitada a ese repositorio y de solo lectura; sin tokens, deploy keys ni secretos.
- Root Directory `landing`, builder Dockerfile, rutas vigiladas `landing/**`. `railway.json` lleva esa configuración, la ruta de salud `/` y una réplica; Railway no aplica el Root Directory al archivo de configuración, así que puede hacer falta indicarlo como `/landing/railway.json`.
- Dominio `*.up.railway.app` con puerto destino 8080, límite de memoria bajo (p. ej. 128 MB), ninguna variable de entorno, «Wait for CI» y el límite de uso de la cuenta.
- Rama: `develop` de forma temporal (excepción a la constitución §9, en `Memoria.md`); pasa a `main` en la primera promoción.
- Con la URL publicada se corren TC-04, 06, 07, 08 y 09 de la spec y se anota la fila en `docs/VERSIONES_DESPLEGADAS.md`.

## Plan B
La imagen es portátil: corre igual en cualquier hosting de contenedores. También sirven los mismos archivos en un hosting estático que permita cabeceras propias (p. ej. Azure Static Web Apps con `staticwebapp.config.json`; confirmar). GitHub Pages solo como último recurso, porque no permite cabeceras. Cambiar de URL obliga a actualizarla en Play Console y en la app.
