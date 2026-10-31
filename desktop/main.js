// Ventana de escritorio de Cripta Nocturna: carga index.html (el workflow lo copia acá antes de compilar).
const { app, BrowserWindow, Menu, shell } = require('electron');
const path = require('path');

Menu.setApplicationMenu(null);
app.whenReady().then(() => {
  const win = new BrowserWindow({ width: 1280, height: 800, backgroundColor: '#140c1f', title: 'Cripta Nocturna' });
  win.loadFile(path.join(__dirname, 'index.html'));
  // El aviso de actualización abre la página de descargas en el navegador
  win.webContents.setWindowOpenHandler(({ url }) => {
    if (url.startsWith('https://github.com/')) shell.openExternal(url);
    return { action: 'deny' };
  });
  win.webContents.on('before-input-event', (e, input) => {
    if (input.type === 'keyDown' && input.key === 'F11') { win.setFullScreen(!win.isFullScreen()); e.preventDefault(); }
  });
});
app.on('window-all-closed', () => app.quit());
