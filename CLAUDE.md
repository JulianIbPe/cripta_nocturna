# Cripta Nocturna — notas para Claude

Juego survivors para celular en un solo archivo, `index.html` (HTML + CSS + JS sin dependencias ni build). Funciona sin internet: las fuentes van incrustadas en base64 (subset latin) y todo lo online (cuenta, clasificación, aviso de versión) falla sin romper el juego. Idioma de la interfaz y de las respuestas al usuario: español rioplatense.

## Publicación

- El juego también está publicado como artifact de claude.ai: https://claude.ai/artifact/SAwN8hy8ZUgAMZfhDAwgrD
- El artifact se publica con el contenido de `index.html` **sin** el esqueleto (`<!doctype>`, `<html>`, `<head>`, `<body>` y el `<style>` de reset del principio): la plataforma de artifacts agrega su propio esqueleto. Para republicar, sacá ese envoltorio y publicá el resto al mismo URL.
- Capacidades del artifact: `db` (reglas `scores` read view / write owner, `scores/{self}` read view / write interact y `data/users/{self}` write interact), `user` con scope `profile` y `downloads`. Si se republica sin pasar `capabilities`, se mantienen.

## Apps

- **APK:** `android/` (WebView sin Gradle, `bash android/build.sh`; JDK y SDK en `D:\Programas\JDK17` y `D:\Programas\AndroidSDK`). El keystore `android/cripta.keystore` no está en git y tiene que ser siempre el mismo.
- **.exe:** `desktop/` (Electron portable). Cada push a `main` publica los dos en un Release de GitHub.

## Estructura del código (todo dentro de un IIFE en el `<script>`)

- **Datos:** `WDEF` (armas, con arrays de 5 niveles; del 6 al 20 suman +12% de daño; `excl` = arma exclusiva de un élite, arranca con ella y solo le sale a él), `PDEF` (objetos; `desc(m)`/`apply(m)` reciben el multiplicador de rareza), `RAR` (rarezas), `CHARS` (personajes; `gems` = élite; `grow` = cuánto sube su pasiva por nivel de mejora, hasta `CHAR_MAX`=7, el 6 y el 7 con gemas), `ETYPES` (enemigos), `DIFFS` (`spd` = velocidad de enemigos y `gem` = caída de gemas; si falta, usa `coin`), `BUFFS` (tienda), `MISSIONS` (sin `reward` desbloquean un arma; con `reward` pagan monedas/gemas una vez vía `payMissions`, registradas en `SAVE.misPaid`).
- **Estado de partida:** objeto global `G` creado en `newGame(ch, diff)`. Estadísticas en `G.st`.
- **Progreso permanente:** `SAVE` en `localStorage` (`cripta-save`), normalizado con `normalizeSave`; `persist()` guarda y agenda la subida a la nube. Partida en curso en `cripta-run` (`saveRun`/`resumeRun`).
- **Cuenta:** login con mail y contraseña contra Firebase por REST (sin SDK): config en `FB`, sesión en `cripta-auth` (`fbLogin`/`fbToken`), guardado en Realtime Database `saves/<uid>` = `{at, data}` (data como texto JSON) vía `cloudRef()` (`pushCloud`/`pullCloud`, gana el `savedAt` más nuevo). Entrar es en dos pasos: contraseña y después el código del link de mail (`EMAIL_SIGNIN`, `fbConfirmLink`); el link lleva a `verificar.html` en GitHub Pages, que muestra el código. Usar el link verifica el mail y las reglas de la base exigen `auth.token.email_verified`; cambio de contraseña en `#passForm`. Con `FB.apiKey` vacío no hay cuentas. Copia en archivo con `exportSave` (en el APK usa `window.CriptaApp.saveFile`) y la importación con vista previa (`previewImport`).
- **Versiones:** `APP_VER` vale `'dev'` en el repo; el workflow `release.yml` lo reemplaza por `1.0.<run>` y `checkUpdate()` (solo en APK/Electron) avisa si el último Release de GitHub es más nuevo.
- **Menú de pruebas:** pantalla `#mod` (`renderMod`/`modAction`), visible solo si el mail de la sesión coincide con `DEV_HASH` (`checkDev`). Casillas en `MOD_FLAGS` (`G.god`, `G.infHp`, `G.maxDmg`, `G.noCd`). Cualquier truco pone `G.mod` (y `SAVE.mod` si toca el progreso), y esas partidas no van a la clasificación.
- **Teclado (PC):** un solo `keydown` en la sección Input; Esc toca el `.backBtn` visible.
- **Bucle:** `update(dt)` + `draw(now)`; con el Reloj del tiempo, `update` corre varias veces por frame.
- **Daño:** todo pasa por `hurt(e, base, kx, ky, src)` (críticos/overcrit, multiplicadores por arma, robo de vida, monedas, gemas y puntos).
- **Clasificación:** `initOnline`, `joinBoard`, `submitScore`, `subscribeBoard` usan `window.claude.use('db'|'user')`; sin eso el juego sigue funcionando.

## Al cambiar algo

- Probá en un navegador headless con viewport de celular (390×844) y revisá que no haya errores de consola.
- Mantené los precios en gemas más caros que en monedas y las gemas raras.
