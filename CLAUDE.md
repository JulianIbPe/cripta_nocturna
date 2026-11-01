# Cripta Nocturna — notas para Claude

Juego survivors para celular en un solo archivo, `index.html` (HTML + CSS + JS sin dependencias ni build). Funciona sin internet: las fuentes van incrustadas en base64 (subset latin) y todo lo online (cuenta, clasificación, aviso de versión) falla sin romper el juego. Idioma de la interfaz y de las respuestas al usuario: español rioplatense.

## Publicación

- El juego también está publicado como artifact de claude.ai: https://claude.ai/artifact/SAwN8hy8ZUgAMZfhDAwgrD
- El artifact se publica con el contenido de `index.html` **sin** el esqueleto (`<!doctype>`, `<html>`, `<head>`, `<body>` y el `<style>` de reset del principio): la plataforma de artifacts agrega su propio esqueleto. Para republicar, sacá ese envoltorio y publicá el resto al mismo URL.
- La clasificación y las cuentas usan Firebase, no la base del artifact; dentro de claude.ai pueden no andar si el artifact bloquea pedidos externos.
- Capacidades del artifact: `db` (reglas `scores` read view / write owner, `scores/{self}` read view / write interact y `data/users/{self}` write interact), `user` con scope `profile` y `downloads`. Si se republica sin pasar `capabilities`, se mantienen.

## Apps

- **APK:** `android/` (WebView sin Gradle, `bash android/build.sh`; JDK y SDK en `D:\Programas\JDK17` y `D:\Programas\AndroidSDK`). El keystore `android/cripta.keystore` no está en git y tiene que ser siempre el mismo.
- **.exe:** `desktop/` (Electron portable). Cada push a `main` publica los dos en un Release de GitHub.

## Estructura del código (todo dentro de un IIFE en el `<script>`)

- **Datos:** `WDEF` (armas, con arrays de 5 niveles; del 6 al 20 suman +12% de daño; `excl` = arma exclusiva de un élite, arranca con ella y solo le sale a él), `PDEF` (objetos; `desc(m)`/`apply(m)` reciben el multiplicador de rareza), `RAR` (rarezas), `CHARS` (personajes; `gems` = élite; `grow` = cuánto sube su pasiva por nivel de mejora, hasta `CHAR_MAX`=7, el 6 y el 7 con gemas), `ETYPES` (enemigos; `boss:true` = jefe con barra de vida arriba y comportamiento propio en el bucle de enemigos: `reina` pone arañas, `conde` embiste, `coloso` golpea el suelo con `G.slams`; salen cada 5 min en el orden de `BOSS_ORDER` y cada vuelta suman +100% de vida vía `G.bossCycle`), `SPAWN_MIX` (qué enemigos salen según el minuto), `DIFFS` (`spd` = velocidad de enemigos y `gem` = caída de gemas; si falta, usa `coin`); el texto de cada dificultad en los menús sale de `diffChanges(k)` con solo los cambios, así que no hace falta escribirlo a mano, `BUFFS` (tienda), `MISSIONS` (sin `reward` desbloquean un arma; con `reward` pagan monedas/gemas una vez vía `payMissions`, registradas en `SAVE.misPaid`).
- **Estado de partida:** objeto global `G` creado en `newGame(ch, diff)`. Estadísticas en `G.st`.
- **Progreso permanente:** `SAVE` en `localStorage` (`cripta-save`), normalizado con `normalizeSave`; `persist()` guarda y agenda la subida a la nube. Partida en curso en `cripta-run` (`saveRun`/`resumeRun`).
- **Cuenta:** login con mail y contraseña contra Firebase por REST (sin SDK): config en `FB`, sesión en `cripta-auth` (`fbLogin`/`fbToken`), guardado en Realtime Database `saves/<uid>` = `{at, data}` (data como texto JSON) vía `cloudRef()` (`pushCloud`/`pullCloud`, gana el `savedAt` más nuevo; guardado automático: 3 s después de cada cambio, cada 30 s si quedó algo sin subir o falló (`cloudDirty`) y al minimizar/cerrar con `keepalive`). Entrar es en dos pasos: contraseña y después el código del link de mail (`EMAIL_SIGNIN`, `fbConfirmLink`); el link lleva a `verificar.html` en GitHub Pages, que muestra el código. Usar el link verifica el mail y las reglas de la base exigen `auth.token.email_verified`; cambio de contraseña en `#passForm`. Nombre de usuario único: `usernames/<minúsculas>` = uid (las reglas solo dejan reservarlo si está libre) y `users/<uid>/name`, escritos juntos con un PATCH multi-ruta (`setUsername`). Con `FB.apiKey` vacío no hay cuentas. Copia en archivo con `exportSave` (en el APK usa `window.CriptaApp.saveFile`) y la importación con vista previa (`previewImport`).
- **Versiones:** `APP_VER` vale `'dev'` en el repo; el workflow `release.yml` lo reemplaza por `1.0.<run>` y `checkUpdate()` (solo en APK/Electron) avisa en el menú y la pausa (`.updbar`) si el último Release es más nuevo (`cmpVer`, número por número); reintenta cada 30 min y al volver internet.
- **Menú de pruebas:** pantalla `#mod` (`renderMod`/`modAction`). Solo la cuenta cuyo mail coincide con `DEV_HASH` (`checkDev`, necesita contexto seguro para `crypto.subtle`) ve la casilla "Menú de pruebas" en Cuenta, que guarda `SAVE.devOn`. `devActive()` = dueño y activado: muestra el botón en Cuenta y en la pausa (`syncDevUi`) y marca `G.mod` al empezar cada partida, así que esas partidas no van a la clasificación. Desactivado, las partidas del dueño cuentan normalmente. Casillas de partida en `MOD_FLAGS` (`G.god`, `G.infHp`, `G.maxDmg`, `G.noCd`); usar cualquier truco también pone `G.mod`. `SAVE.mod` queda solo como registro.
- **Teclado (PC):** un solo `keydown` en la sección Input; Esc toca el `.backBtn` visible.
- **Bucle:** `update(dt)` + `draw(now)`; con el Reloj del tiempo, `update` corre varias veces por frame.
- **Drops:** al morir un enemigo común: curación 0,2%, bomba 0,15% (`bomb()`: mata los comunes en pantalla y saca 15% a jefes y calabazas) e imán 0,15%. Calabaza: imán y 50% de curación. Jefe: curación, imán, 2 gemas y 25 monedas.
- **Daño:** todo pasa por `hurt(e, base, kx, ky, src)` (críticos/overcrit, multiplicadores por arma, robo de vida, monedas, gemas y puntos).
- **Reglas de Firebase:** `firebase-rules.json` (pegarlas en Realtime Database → Reglas cuando cambien).
- **Clasificación:** Firebase `scores/<uid>` = `{name, score, best, at}` (lectura pública; para aparecer hace falta sesión y nombre de usuario, y las reglas exigen que `name` sea el de `users/<uid>/name`). `initOnline` trae tu mejor puntaje, `submitScore` lo guarda en `SAVE.pendScore` y `flushScore` lo sube (reintenta con el guardado automático), `subscribeBoard` recarga la tabla cada 30 s.

## Flujo de trabajo

- GitHub (`JulianIbPe/cripta_nocturna`, rama `main`) es la fuente de verdad. Antes de cambiar algo, traé lo último de `main`.
- Cada cambio se commitea y se pushea directo a `main`, sin ramas ni PR, salvo que el usuario pida otra cosa.
- Cada push a `main` dispara `release.yml` y saca una versión nueva del .exe y el APK. Si el cambio no toca el juego (solo docs o notas), agregá `[skip ci]` al mensaje del commit para no publicar un Release vacío.
- El artifact de claude.ai y la carpeta de la PC se actualizan solo si el usuario lo pide.

## Al cambiar algo

- Probá en un navegador headless con viewport de celular (390×844) y revisá que no haya errores de consola.
- Mantené los precios en gemas más caros que en monedas y las gemas raras.
