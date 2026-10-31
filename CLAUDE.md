# Cripta Nocturna — notas para Claude

Juego survivors para celular en un solo archivo, `index.html` (HTML + CSS + JS sin dependencias ni build). Idioma de la interfaz y de las respuestas al usuario: español rioplatense.

## Publicación

- El juego también está publicado como artifact de claude.ai: https://claude.ai/artifact/SAwN8hy8ZUgAMZfhDAwgrD
- El artifact se publica con el contenido de `index.html` **sin** el esqueleto (`<!doctype>`, `<html>`, `<head>`, `<body>` y el `<style>` de reset del principio): la plataforma de artifacts agrega su propio esqueleto. Para republicar, sacá ese envoltorio y publicá el resto al mismo URL.
- Capacidades del artifact: `db` (reglas `scores` read view / write owner, `scores/{self}` read view / write interact y `data/users/{self}` write interact), `user` con scope `profile` y `downloads`. Si se republica sin pasar `capabilities`, se mantienen.

## Estructura del código (todo dentro de un IIFE en el `<script>`)

- **Datos:** `WDEF` (armas, con arrays de 5 niveles; del 6 al 20 suman +12% de daño), `PDEF` (objetos; `desc(m)`/`apply(m)` reciben el multiplicador de rareza), `RAR` (rarezas), `CHARS` (personajes; `gems` = élite), `ETYPES` (enemigos), `DIFFS`, `BUFFS` (tienda), `MISSIONS`.
- **Estado de partida:** objeto global `G` creado en `newGame(ch, diff)`. Estadísticas en `G.st`.
- **Progreso permanente:** `SAVE` en `localStorage` (`cripta-save`), normalizado con `normalizeSave`; `persist()` guarda y agenda la subida a la nube. Partida en curso en `cripta-run` (`saveRun`/`resumeRun`).
- **Cuenta:** nube en `data/users/<id>/save` (`pushCloud`/`pullCloud`, gana el `savedAt` más nuevo); copia en archivo con `exportSave` y la importación con vista previa (`previewImport`).
- **Bucle:** `update(dt)` + `draw(now)`; con el Reloj del tiempo, `update` corre varias veces por frame.
- **Daño:** todo pasa por `hurt(e, base, kx, ky, src)` (críticos/overcrit, multiplicadores por arma, robo de vida, monedas, gemas y puntos).
- **Clasificación:** `initOnline`, `joinBoard`, `submitScore`, `subscribeBoard` usan `window.claude.use('db'|'user')`; sin eso el juego sigue funcionando.

## Al cambiar algo

- Probá en un navegador headless con viewport de celular (390×844) y revisá que no haya errores de consola.
- Mantené los precios en gemas más caros que en monedas y las gemas raras.
