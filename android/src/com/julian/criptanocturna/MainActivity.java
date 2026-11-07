package com.julian.criptanocturna;

import android.app.Activity;
import android.app.DownloadManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.IntentFilter;
import android.database.Cursor;
import android.content.ClipboardManager;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.webkit.JavascriptInterface;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import java.io.File;

public class MainActivity extends Activity {
    private static final int PICK_FILE = 1;
    private WebView web;
    private ValueCallback<Uri[]> pending;

    @Override
    protected void onCreate(Bundle state) {
        super.onCreate(state);
        web = new WebView(this);
        WebSettings s = web.getSettings();
        s.setJavaScriptEnabled(true);
        s.setDomStorageEnabled(true); // localStorage: progreso y partida en curso
        s.setMediaPlaybackRequiresUserGesture(false);
        web.addJavascriptInterface(new Bridge(), "CriptaApp");
        web.setWebChromeClient(new WebChromeClient() {
            @Override
            public boolean onShowFileChooser(WebView v, ValueCallback<Uri[]> cb, FileChooserParams p) {
                if (pending != null) pending.onReceiveValue(null);
                pending = cb;
                try {
                    startActivityForResult(p.createIntent(), PICK_FILE);
                } catch (Exception e) {
                    pending = null;
                    return false;
                }
                return true;
            }
        });
        setContentView(web);
        if (state != null) web.restoreState(state);
        else web.loadUrl("file:///android_asset/index.html");
    }

    @Override
    protected void onActivityResult(int req, int res, Intent data) {
        if (req == PICK_FILE && pending != null) {
            pending.onReceiveValue(WebChromeClient.FileChooserParams.parseResult(res, data));
            pending = null;
        }
    }

    @Override
    protected void onSaveInstanceState(Bundle out) {
        super.onSaveInstanceState(out);
        web.saveState(out);
    }

    // Atrás del celular: el juego cierra la pantalla abierta o pausa la partida; en el menú principal, la app va al fondo
    @Override
    public void onBackPressed() {
        web.evaluateJavascript("(window.criptaBack&&window.criptaBack())?1:0", v -> {
            if (!"1".equals(v)) moveTaskToBack(true);
        });
    }

    @Override
    protected void onPause() {
        web.onPause(); // corta el audio y el bucle al salir de la app
        super.onPause();
    }

    @Override
    protected void onResume() {
        super.onResume();
        web.onResume();
    }

    class Bridge {
        // Abre la página de descargas en el navegador (solo links de GitHub).
        @JavascriptInterface
        public void openUrl(String url) {
            if (url.startsWith("https://github.com/")) startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(url)));
        }

        // Baja el APK de la versión nueva con DownloadManager y al terminar abre el instalador de Android
        @JavascriptInterface
        public boolean downloadApk(String url) {
            // Se compara el host y el camino ya parseados: un startsWith se podía esquivar con "../"
            Uri u = Uri.parse(url);
            String path = u.getPath();
            if (!"https".equals(u.getScheme()) || !"github.com".equals(u.getHost()) || path == null || path.contains("..")
                || !path.startsWith("/JulianIbPe/cripta_nocturna/releases/download/") || !path.endsWith(".apk")) return false;
            try {
                File old = new File(getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS), "cripta-update.apk");
                if (old.exists()) old.delete();
                final DownloadManager dm = (DownloadManager) getSystemService(DOWNLOAD_SERVICE);
                DownloadManager.Request r = new DownloadManager.Request(Uri.parse(url))
                    .setTitle("Cripta Nocturna: versión nueva")
                    .setMimeType("application/vnd.android.package-archive")
                    .setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE)
                    .setDestinationInExternalFilesDir(MainActivity.this, Environment.DIRECTORY_DOWNLOADS, "cripta-update.apk");
                final long id = dm.enqueue(r);
                BroadcastReceiver done = new BroadcastReceiver() {
                    @Override
                    public void onReceive(Context c, Intent i) {
                        if (i.getLongExtra(DownloadManager.EXTRA_DOWNLOAD_ID, -1) != id) return;
                        unregisterReceiver(this);
                        boolean ok = false;
                        try (Cursor q = dm.query(new DownloadManager.Query().setFilterById(id))) {
                            ok = q.moveToFirst() && q.getInt(q.getColumnIndex(DownloadManager.COLUMN_STATUS)) == DownloadManager.STATUS_SUCCESSFUL;
                        }
                        Uri apk = ok ? dm.getUriForDownloadedFile(id) : null;
                        if (apk == null) { web.evaluateJavascript("window.criptaUpdFail&&criptaUpdFail()", null); return; }
                        // Android pide confirmar (y la primera vez, permitir instalar desde esta app)
                        startActivity(new Intent(Intent.ACTION_VIEW).setDataAndType(apk, "application/vnd.android.package-archive")
                            .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_ACTIVITY_NEW_TASK));
                    }
                };
                IntentFilter f = new IntentFilter(DownloadManager.ACTION_DOWNLOAD_COMPLETE);
                // Exportado a propósito: DOWNLOAD_COMPLETE lo manda el proceso de DownloadManager, no el sistema; se ignora todo lo que no sea esta descarga
                if (Build.VERSION.SDK_INT >= 33) registerReceiver(done, f, Context.RECEIVER_EXPORTED);
                else registerReceiver(done, f);
                return true;
            } catch (Exception e) {
                return false;
            }
        }

        // Lee el texto copiado, para el botón Pegar del código de verificación.
        @JavascriptInterface
        public String readClipboard() {
            try {
                ClipboardManager cm = (ClipboardManager) getSystemService(CLIPBOARD_SERVICE);
                if (cm == null || !cm.hasPrimaryClip() || cm.getPrimaryClip().getItemCount() == 0) return "";
                CharSequence t = cm.getPrimaryClip().getItemAt(0).coerceToText(MainActivity.this);
                return t == null ? "" : t.toString();
            } catch (Exception e) {
                return "";
            }
        }

    }
}
