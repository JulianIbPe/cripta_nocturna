// Ventana de escritorio de Cripta Nocturna: carga index.html (el workflow lo copia acá antes de compilar).
const { app, BrowserWindow, Menu, shell, net } = require('electron');
const path = require('path');
const fs = require('fs');
const { spawn } = require('child_process');

const EXE_RE = /^https:\/\/github\.com\/JulianIbPe\/cripta_nocturna\/releases\/download\/[^/]+\/criptanocturna-[\d.]+\.exe$/;
// Se actualiza solo: baja el .exe nuevo al lado del actual y un .bat lo reemplaza cuando este se cierra y lo vuelve a abrir.
// PORTABLE_EXECUTABLE_FILE es el .exe que abrió el usuario (el portable corre desde una copia temporal)
async function selfUpdate(win, url) {
  const exe = process.env.PORTABLE_EXECUTABLE_FILE;
  if (!exe) return shell.openExternal('https://github.com/JulianIbPe/cripta_nocturna/releases/latest');
  const tmp = exe + '.new', bat = path.join(app.getPath('temp'), 'cripta-update.bat');
  try {
    win.setProgressBar(2); // barra de la barra de tareas en modo "cargando"
    const r = await net.fetch(url);
    if (!r.ok) throw new Error('HTTP ' + r.status);
    fs.writeFileSync(tmp, Buffer.from(await r.arrayBuffer()));
    // Reintenta mover hasta 60 s: el .exe sigue bloqueado unos instantes después de cerrar
    fs.writeFileSync(bat, ['@echo off', 'set n=0', ':w', 'timeout /t 1 /nobreak >nul', 'set /a n+=1',
      `move /y "${tmp}" "${exe}" >nul 2>&1 || (if %n% lss 60 goto w)`, `start "" "${exe}"`, 'del "%~f0"'].join('\r\n'));
    spawn('cmd.exe', ['/c', bat], { detached: true, stdio: 'ignore', windowsHide: true }).unref();
    app.quit();
  } catch (e) {
    win.setProgressBar(-1);
    try { fs.unlinkSync(tmp); } catch (_) {}
    shell.openExternal('https://github.com/JulianIbPe/cripta_nocturna/releases/latest');
  }
}

Menu.setApplicationMenu(null);
app.whenReady().then(() => {
  const win = new BrowserWindow({ width: 1280, height: 800, backgroundColor: '#140c1f', title: 'Cripta Nocturna',
    // La partida sigue aunque la ventana esté minimizada o tapada
    webPreferences: { backgroundThrottling: false } });
  win.loadFile(path.join(__dirname, 'index.html'));
  // El aviso de actualización: el .exe del Release se instala solo; el resto de GitHub se abre en el navegador
  win.webContents.setWindowOpenHandler(({ url }) => {
    if (EXE_RE.test(url)) selfUpdate(win, url);
    else if (url.startsWith('https://github.com/')) shell.openExternal(url);
    return { action: 'deny' };
  });
  win.webContents.on('before-input-event', (e, input) => {
    if (input.type === 'keyDown' && input.key === 'F11') { win.setFullScreen(!win.isFullScreen()); e.preventDefault(); }
  });
});
app.on('window-all-closed', () => app.quit());
