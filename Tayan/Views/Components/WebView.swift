//
//  WebView.swift
//  Tayan
//
//  Created by Zhichao Li on 7/13/25.
//

import SwiftUI
import WebKit

/// A SwiftUI view that displays HTML content using the native iOS 26+ WebKit integration
struct WebView: View {
    let htmlContent: String
    @State private var webPage: WebPage?

    var body: some View {
        Group {
            if let webPage = webPage {
                WebKit.WebView(webPage)
            } else {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task {
            await setupWebPage()
        }
        .onChange(of: htmlContent) { _, _ in
            Task {
                await loadHTMLContent()
            }
        }
    }

    /// Sets up a new WebPage with optimized configuration for HTML rendering
    private func setupWebPage() async {
        // Configure WebPage for optimal HTML rendering
        var configuration = WebPage.Configuration()
        configuration.loadsSubresources = true
        configuration.defaultNavigationPreferences.allowsContentJavaScript = true

        let newWebPage = WebPage(configuration: configuration)
        self.webPage = newWebPage

        await loadHTMLContent()
    }

    /// Loads HTML content into the WebPage with proper error handling
    private func loadHTMLContent() async {
        guard let webPage = webPage else { return }

        do {
            let cleanedHTML = htmlContent.strippingMarkdownWrapper()

            // Create a base URL for relative resources
            let baseURL = URL(string: "about:blank")!

            // Load the HTML content into the WebPage and wait for completion
            for try await event in webPage.load(html: cleanedHTML, baseURL: baseURL) {
                switch event {
                case .finished:
                    // Page finished loading successfully
                    break
                default:
                    continue
                }
                break  // Exit after handling the completion event
            }
        } catch {
            print("Failed to load HTML content: \(error)")
        }
    }
}

#Preview {
    WebView(
        htmlContent: """
            <!DOCTYPE html>
            <html>
            <head>
                <title>Sample Contact Form</title>
                <style>
                    body { 
                        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                        padding: 20px;
                        margin: 0;
                        background-color: #f5f5f5;
                    }
                    .container {
                        max-width: 600px;
                        margin: 0 auto;
                        background: white;
                        padding: 30px;
                        border-radius: 10px;
                        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                    }
                    h1 { color: #333; margin-bottom: 20px; }
                    .form-group {
                        margin-bottom: 15px;
                    }
                    label {
                        display: block;
                        margin-bottom: 5px;
                        color: #555;
                        font-weight: 500;
                    }
                    input, textarea {
                        width: 100%;
                        padding: 10px;
                        border: 1px solid #ddd;
                        border-radius: 5px;
                        font-size: 16px;
                    }
                    button {
                        background: #007AFF;
                        color: white;
                        border: none;
                        padding: 12px 24px;
                        border-radius: 5px;
                        cursor: pointer;
                        font-size: 16px;
                        font-weight: 500;
                    }
                    button:hover {
                        background: #0056b3;
                    }
                </style>
            </head>
            <body>
                <div class="container">
                    <h1>Contact Us</h1>
                    <form>
                        <div class="form-group">
                            <label for="name">Name</label>
                            <input type="text" id="name" name="name" required>
                        </div>
                        <div class="form-group">
                            <label for="email">Email</label>
                            <input type="email" id="email" name="email" required>
                        </div>
                        <div class="form-group">
                            <label for="message">Message</label>
                            <textarea id="message" name="message" rows="5" required></textarea>
                        </div>
                        <button type="submit">Send Message</button>
                    </form>
                </div>
            </body>
            </html>
            """
    )
    .frame(height: 400)
}
