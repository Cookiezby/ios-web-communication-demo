import UIKit
import WebKit

enum BridgeEvent: String {
    case getRandomTitle
}

class ViewController: UIViewController {
    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.userContentController.add(self, name: "bridge")
        let view = WKWebView(frame: .zero, configuration: config)
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webView)
        
        webView.frame = view.frame
        webView.isInspectable = true
        loadHTML()
        loadJS()
    }
    
    private func loadHTML() {
        let filePath = Bundle.main.path(forResource: "local", ofType: "html")!
        let contents =  try! String(contentsOfFile: filePath, encoding: .utf8)
        let baseUrl = URL(fileURLWithPath: filePath)
        webView.loadHTMLString(contents as String, baseURL: baseUrl)
    }
    
    private func loadJS() {
        guard let scriptPath = Bundle.main.path(forResource: "bridge", ofType: "js") else { return }
        guard let scriptSource = try? String(contentsOfFile: scriptPath) else { return }
        let userScript = WKUserScript(
            source: scriptSource,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        webView.configuration.userContentController.addUserScript(userScript)
    }
}

extension ViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "bridge",
           let body = message.body as? [String: Any],
           let requestId = body["requestId"] as? String,
           let eventNameString = body["eventName"] as? String,
           let event = BridgeEvent(rawValue: eventNameString) {
            switch event {
            case .getRandomTitle:
                let script = "window.handleNativeResponse('\(getRandomTitle())','\(requestId)')"
                webView.evaluateJavaScript(script)
            }
        }
    }
    
    private func getRandomTitle() -> String {
        return "Title: \(UUID().uuidString)"
    }
}
