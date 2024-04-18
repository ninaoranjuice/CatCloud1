//
//  GeneralViewController.swift
//  CatCloud
//
//  Created by Нина Гурстиева on 02.04.2024.
//

import UIKit
import WebKit

class RegistrationViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = WKWebView(frame: view.bounds)
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        let urlString = "https://oauth.yandex.ru/authorize?response_type=token&client_id=776e88da6f194321921ae5c972e5a206&redirect_uri=https://oauth.yandex.ru/verification_code"
        
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        print("URL: \(url.absoluteString)")
        
        if url.absoluteString.hasPrefix("https://oauth.yandex.ru/verification_code") {
            if let token = extractToken(from: url) {
                print("Токен доступа: \(token)")
                TokenManager.shared.accessToken = token
                register()
            } else {
                print("Не удалось извлечь токен доступа из URL.")
            }
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    func extractToken(from url: URL) -> String? {
        guard let fragment = url.fragment else {
            return nil
        }
        let components = fragment.components(separatedBy: "&")
        for component in components {
            let keyValue = component.components(separatedBy: "=")
            if keyValue.count == 2, keyValue[0] == "access_token" {
                return keyValue[1]
            }
        }
        return nil
    }
    
  private func register() {
        let generalPage = TapBarController()
         if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first {
             window.rootViewController = generalPage
         }
     }
}

