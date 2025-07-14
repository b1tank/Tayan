//
//  WebViewRepresentable.swift
//  Tayan
//
//  Created by Zhichao Li on 7/13/25.
//
//  Note: This file contains the proper WebView implementation that will be used
//  when the iOS SDK is properly configured. For now, we use a placeholder.

import SwiftUI

#if canImport(WebKit) && canImport(UIKit)
    import WebKit
    import UIKit

    struct WebViewRepresentable: UIViewRepresentable {
        let htmlContent: String

        func makeUIView(context: Context) -> WKWebView {
            let configuration = WKWebViewConfiguration()

            let webView = WKWebView(frame: .zero, configuration: configuration)
            webView.navigationDelegate = context.coordinator
            return webView
        }

        func updateUIView(_ webView: WKWebView, context: Context) {
            let cleanedHTML = htmlContent.strippingMarkdownWrapper()
            webView.loadHTMLString(cleanedHTML, baseURL: nil)
        }

        func makeCoordinator() -> Coordinator {
            Coordinator()
        }

        class Coordinator: NSObject, WKNavigationDelegate {
            func webView(
                _ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error
            ) {
                print("WebView navigation failed: \(error.localizedDescription)")
            }

            func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
                print("WebView loading failed: \(error.localizedDescription)")
            }

            func webView(
                _ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
            ) {
                // Allow all navigation for now, but could be restricted for security
                decisionHandler(.allow)
            }
        }
    }

#endif
