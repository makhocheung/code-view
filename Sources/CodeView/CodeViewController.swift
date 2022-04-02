//
// Created by Mak Ho-Cheung on 2022/3/30.
//

import Foundation
import WebKit

public class CodeViewController: NSObject, WKScriptMessageHandler {
    var webView: WKWebView!

    func updateCode(code: String) {
        let hexString = code.data(using: .utf8)!.map {
            String(format: "%02hhx", $0)
        }
        .joined()
        webView.evaluateJavaScript("updateCode('\(hexString)');") { result, error in
            if let error = error {
                print("CodeView error \(error)")
            }
        }
    }

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.body)
    }
}


