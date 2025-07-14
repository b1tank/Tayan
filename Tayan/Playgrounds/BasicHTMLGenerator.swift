//
//  BasicHTMLGenerator.swift
//  Tayan Playground
//
//  Created by Zhichao Li on 7/13/25.
//
//  Swift Playground to test HTML generation functionality

import FoundationModels
import Playgrounds
import SwiftUI

#Playground {
    // Create a language model session specialized for HTML generation
    let session = LanguageModelSession(
        instructions: """
            You are an expert web developer. Generate clean, modern HTML based on user descriptions.
            Create complete HTML documents with proper structure and inline CSS for styling.
            Always respond with valid HTML only, no explanations or markdown.
            """
    )

    // List of web app descriptions to generate HTML for
    let webAppIdeas = [
        "a simple contact form with name, email, and message fields",
        "a personal portfolio landing page with hero section",
        "a basic calculator with number buttons and operations",
        "a todo list app with add and delete functionality",
        "a recipe card with ingredients and instructions",
    ]

    print("🚀 Starting HTML Generation Tests...")
    print("📊 Model Status: \(SystemLanguageModel.default.availability)")

    // Generate HTML for each web app idea
    for (index, idea) in webAppIdeas.enumerated() {
        print("\n📝 Test \(index + 1): Generating '\(idea)'")

        let prompt = """
            Create a complete HTML page for: \(idea)

            Requirements:
            - Complete HTML document with DOCTYPE, html, head, and body tags
            - Include a descriptive title in the head section  
            - Use semantic HTML5 elements
            - Add inline CSS for modern styling and layout
            - Make it responsive and accessible
            - Ensure forms are functional with proper input types
            - Use modern color schemes and typography

            Generate only the HTML code.
            """

        do {
            let response = try await session.respond(to: prompt)
            let htmlContent = response.content

            print("✅ Generated \(htmlContent.count) characters of HTML")

            // Display a preview of the generated HTML structure
            let lines = htmlContent.components(separatedBy: .newlines)
            let previewLines = lines.prefix(5)
            print("📄 HTML Preview:")
            for line in previewLines {
                print("   \(line.trimmingCharacters(in: .whitespaces))")
            }
            if lines.count > 5 {
                print("   ... (\(lines.count - 5) more lines)")
            }

            // In a real implementation, you could save this to a file
            let filename = idea.replacingOccurrences(of: " ", with: "_") + ".html"
            print("💾 Could save as: \(filename)")

        } catch let error as LanguageModelSession.GenerationError {
            print("❌ Generation failed: \(error.localizedDescription)")

            // Handle specific error cases
            switch error {
            case .exceededContextWindowSize:
                print("🔄 Context window exceeded - would reset session")
            case .assetsUnavailable:
                print("📱 Model assets unavailable - check connection")
            case .rateLimited:
                print("⏱️ Rate limited - would wait before retry")
            default:
                print("� Other error: \(error)")
            }
        } catch {
            print("❌ Unexpected error: \(error.localizedDescription)")
        }
    }

    print("\n🎉 HTML Generation Tests Complete!")
}
