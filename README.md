# Cripta Nocturna

Survivors de Halloween para celular, al estilo Vampire Survivors / Megabonk. Te movés arrastrando el dedo, tus armas atacan solas y tenés que aguantar hasta el amanecer (10:00). Después el reloj sigue y los enemigos se vuelven cada vez más letales.

## Cómo jugar

Abrí `index.html` en el navegador (celular o compu). No necesita instalación ni servidor.

- **Celular:** arrastrá el dedo en cualquier parte para moverte; botón de abajo a la derecha para la habilidad.
- **Compu:** WASD o flechas (o arrastrar con el mouse) para moverte, E o Shift para la habilidad, espacio/P/Esc para pausar, V para la velocidad, 1-2-3 para elegir mejoras y R/B/X para Cambiar/Bloquear/Saltar. Esc vuelve atrás en los menús y Enter juega.

## Descargar

En [Releases](https://github.com/JulianIbPe/cripta_nocturna/releases/latest) está la última versión para Windows (`CriptaNocturna.exe`, no se instala: se abre directo) y para Android (`CriptaNocturna.apk`). Cada commit a `main` publica una versión nueva y las apps avisan en el menú cuando hay una.

## Qué tiene

- 12 personajes: 6 se desbloquean con monedas y 6 élite con gemas. Cada uno tiene pasiva, habilidad activa y mejoras compradas con monedas.
- 23 armas (5 se desbloquean con misiones y 6 son exclusivas de los personajes élite) y 20 objetos de estadísticas, hasta nivel 20.
- 21 misiones: las primeras desbloquean armas y las difíciles dan monedas o gemas.
- Mejoras de personaje hasta nivel 7 (el 6 y el 7 con gemas) que también suben su pasiva.
- Mejoras con rareza (Común a Mítica) según la suerte, y efectos al pasarse del máximo (overcrit, sobrecarga, contraataque).
- Tres dificultades (Fácil, Medio, Difícil) con multiplicador de puntos.
- Tienda de mejoras permanentes (Cambiar, Bloquear, Saltar, Sabiduría, Imán de gemas, Reloj del tiempo).
- 10 tipos de enemigos y 3 jefes (Reina Araña, El Conde y Coloso de Lápidas) que aparecen cada 5 minutos.
- Drops de curación, imán y bomba que limpia la pantalla.
- Partida guardada automáticamente, récords y registro del caos.

## Guardado

- **En el navegador:** el progreso (monedas, gemas, personajes, récords y la partida en curso) se guarda solo en el `localStorage`.
- **En tu cuenta:** en la pantalla Cuenta iniciás sesión o te registrás con mail y contraseña; el progreso se guarda en la nube (Firebase) y se sincroniza entre dispositivos.
- **En un archivo:** desde la pantalla Cuenta podés guardar el progreso en un archivo `.json` y dejarlo en la carpeta que quieras (por ejemplo `saves/`). Después lo cargás con "Cargar archivo" en este u otro dispositivo.

## Clasificación online

La tabla de clasificación usa las cuentas del juego (Firebase): cualquiera la puede ver, y para aparecer hay que iniciar sesión y elegir un nombre de usuario. Cada jugador aparece con su mejor partida, que se sube sola al superarla (si no hay internet, queda pendiente y se sube después). Funciona en el navegador, el APK y el .exe.

## Compilar

- **APK:** `bash android/build.sh` (necesita JDK 17 y Android SDK con `platforms;android-34` y `build-tools;34.0.0`; por defecto los busca en `D:\Programas`).
- **.exe:** `cd desktop && cp ../index.html . && npm install && npm run dist`.
- **GitHub Actions** (`.github/workflows/release.yml`) compila los dos y publica el Release. Necesita los secrets `ANDROID_KEYSTORE_B64` (el `android/cripta.keystore` en base64) y `CRIPTA_KS_PASS`.
