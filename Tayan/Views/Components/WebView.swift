//
//  WebView.swift
//  Tayan
//
//  Created by Zhichao Li on 7/13/25.
//

import SwiftUI

struct WebView: View {
    let htmlContent: String

    var body: some View {
        #if canImport(WebKit) && canImport(UIKit)
            WebViewRepresentable(htmlContent: htmlContent)
        #else
            // Fallback for when WebKit/UIKit is not available
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Generated HTML Preview")
                        .font(.headline)
                        .foregroundColor(.blue)

                    Text("HTML Content:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(htmlContent)
                        .font(.system(.caption, design: .monospaced))
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(8)
        #endif
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
