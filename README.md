# Cripta Nocturna

Survivors de Halloween para celular, al estilo Vampire Survivors / Megabonk. Te movés arrastrando el dedo, tus armas atacan solas y tenés que aguantar hasta el amanecer (10:00). Después el reloj sigue y los enemigos se vuelven cada vez más letales.

## Cómo jugar

Abrí `index.html` en el navegador (celular o compu). No necesita instalación ni servidor.

- **Celular:** arrastrá el dedo en cualquier parte para moverte; botón de abajo a la derecha para la habilidad.
- **Compu:** WASD o flechas para moverte, E para la habilidad, espacio para pausar.

## Qué tiene

- 12 personajes: 6 se desbloquean con monedas y 6 élite con gemas. Cada uno tiene pasiva, habilidad activa y mejoras compradas con monedas.
- 17 armas (5 se desbloquean con misiones) y 21 objetos de estadísticas, hasta nivel 20.
- Mejoras con rareza (Común a Mítica) según la suerte, y efectos al pasarse del máximo (overcrit, sobrecarga, contraataque).
- Tres dificultades (Fácil, Medio, Difícil) con multiplicador de puntos.
- Tienda de mejoras permanentes (Cambiar, Bloquear, Saltar, Sabiduría, Imán de gemas, Reloj del tiempo).
- Partida guardada automáticamente, récords y registro del caos.

## Guardado

- **En el navegador:** el progreso (monedas, gemas, personajes, récords y la partida en curso) se guarda solo en el `localStorage`.
- **En tu cuenta:** abierto desde su link de Claude, el progreso también se guarda en tu cuenta de Claude y se sincroniza entre dispositivos (pantalla Cuenta).
- **En un archivo:** desde la pantalla Cuenta podés guardar el progreso en un archivo `.json` y dejarlo en la carpeta que quieras (por ejemplo `saves/`). Después lo cargás con "Cargar archivo" en este u otro dispositivo.

## Clasificación online

La tabla de clasificación usa la base de datos y la identidad de los artifacts de claude.ai, así que solo funciona cuando el juego se abre desde su link de Claude. Abierto como archivo local, el resto del juego funciona igual y la clasificación avisa que no está disponible.
