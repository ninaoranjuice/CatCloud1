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
        
        let urlString = "https://oauth.yandex.ru/authorize?response_type=token&client_id=169ae726a03c42fb94e6ed799ef6061f&redirect_uri=lhttps://oauth.yandex.ru/verification_code"
        
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, url.absoluteString.hasPrefix("lhttps://oauth.yandex.ru/verification_code") {
            let token = extractToken(from: url)
            print("Токен доступа: \(String(describing: token))")
            TokenManager.shared.accessToken = token
            register()
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
    
    func extractToken(from url: URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return nil
        }
        for queryItem in queryItems {
            if queryItem.name == "access_token" {
                return queryItem.value
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
      //   presentingViewController?.dismiss(animated: true, completion: nil)
     }
}

