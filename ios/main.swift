// Cripta Nocturna para iOS: una vista web a pantalla completa con el juego (index.html) adentro, como el APK.
import UIKit
import WebKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = GameViewController()
        window?.makeKeyAndVisible()
        return true
    }
}

class GameViewController: UIViewController, WKScriptMessageHandler, WKUIDelegate {
    var web: WKWebView!

    override func loadView() {
        let conf = WKWebViewConfiguration()
        conf.allowsInlineMediaPlayback = true
        conf.mediaTypesRequiringUserActionForPlayback = []
        conf.websiteDataStore = .default() // localStorage: progreso y partida en curso
        // Mismo puente que el APK: el juego abre los links de descarga con CriptaApp.openUrl
        let js = "window.CriptaApp={openUrl:function(u){window.webkit.messageHandlers.cripta.postMessage({t:'open',u:String(u)});},ios:true};"
        conf.userContentController.addUserScript(WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: true))
        conf.userContentController.add(self, name: "cripta")
        web = WKWebView(frame: .zero, configuration: conf)
        web.uiDelegate = self
        web.scrollView.contentInsetAdjustmentBehavior = .never // el juego usa env(safe-area-inset-*)
        web.scrollView.bounces = false
        web.isOpaque = false
        web.backgroundColor = UIColor(red: 0.04, green: 0.03, blue: 0.08, alpha: 1)
        view = web
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = Bundle.main.url(forResource: "index", withExtension: "html") {
            web.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
    }

    override var prefersStatusBarHidden: Bool { true }
    override var prefersHomeIndicatorAutoHidden: Bool { true }

    func userContentController(_ c: WKUserContentController, didReceive m: WKScriptMessage) {
        guard let d = m.body as? [String: Any], d["t"] as? String == "open", let s = d["u"] as? String,
              s.hasPrefix("https://github.com/"), let u = URL(string: s) else { return }
        UIApplication.shared.open(u)
    }

    // Links con target _blank (por ejemplo, el de la página de verificación): se abren en Safari
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let u = navigationAction.request.url, u.scheme == "https" { UIApplication.shared.open(u) }
        return nil
    }
}
