import SwiftUI
import WebKit

#if os(macOS)
typealias ViewRepresentable = NSViewRepresentable
#elseif os(iOS)
typealias ViewRepresentable = UIViewRepresentable
#endif

public struct CodeView: ViewRepresentable {
    private static var globalWebView: WKWebView!
    private static var codeViewController = CodeViewController()

    private let useGlobalWebView: Bool
    private let isDarkMode: Bool
    @Binding public var code: String

    public init(useGlobalWebView: Bool = true, code: Binding<String>, isDarkMode: Bool = false) {
        _code = code
        self.useGlobalWebView = useGlobalWebView
        self.isDarkMode = isDarkMode
        if self.useGlobalWebView && CodeView.globalWebView == nil {
            CodeView.globalWebView = doCreateWebView(code: self.code)
        }
    }

    #if os(macOS)
    public func makeNSView(context: Context) -> WKWebView {
        createWebView(context: context)
    }

    public func updateNSView(_ nsView: WKWebView, context: Context) {
        context.coordinator.updateCode(code: code)
    }

    #else
    public func makeUIView(context: Context) -> WKWebView {
        createWebView(context: context)
    }

    public func updateUIView(_ uiView: WKWebView, context: Context) {
        context.coordinator.updateCode(code: code)
    }
    #endif

    public func makeCoordinator() -> CodeViewController {
        CodeView.codeViewController
    }

    private func createWebView(context: Context) -> WKWebView {
        if useGlobalWebView {
            context.coordinator.webView = CodeView.globalWebView
            return CodeView.globalWebView
        } else {
            context.coordinator.webView = doCreateWebView(code: code)
            return context.coordinator.webView
        }
    }

    private func doCreateWebView(code: String = "") -> WKWebView {
        let wkUserContentController = WKUserContentController()
        wkUserContentController.add(CodeView.codeViewController, name: "log")
        let hexString = code.data(using: .utf8)!.map {
            String(format: "%02hhx", $0)
        }
        .joined()
        let userScript = WKUserScript(source: "const theme='\(isDarkMode ? "material-palenight" : "default")';const code = '\(hexString)'",
                injectionTime: .atDocumentStart, forMainFrameOnly: false)
        wkUserContentController.addUserScript(userScript)
        let wkConfiguration = WKWebViewConfiguration()
        wkConfiguration.userContentController = wkUserContentController
        let webView = WKWebView(frame: .zero, configuration: wkConfiguration)
        webView.setValue(true, forKey: "drawsTransparentBackground")
        let bundleURL = Bundle.module.resourceURL!.appendingPathComponent("CodeView").appendingPathExtension("bundle")
        let bundle = Bundle(url: bundleURL)!
        let codeViewHTMLURL = bundle.url(forResource: "codeview", withExtension: "html")!
        let codeViewHTML = try! String(contentsOf: codeViewHTMLURL)
        webView.loadHTMLString(codeViewHTML, baseURL: bundle.resourceURL)
        return webView
    }
}
