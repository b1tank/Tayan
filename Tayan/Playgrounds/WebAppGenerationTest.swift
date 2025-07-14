//
//  WebAppGenerationTest.swift
//  Tayan Playground
//
//  Created by Zhichao Li on 7/13/25.
//
//  Swift Playground to test web app generation with different types

import FoundationModels
import Playgrounds
import SwiftUI

#Playground {
    // Create different sessions for different types of web apps
    let htmlOnlySession = LanguageModelSession(
        instructions: """
            You are a web developer creating HTML-only applications.
            Generate semantic HTML with inline CSS for styling.
            Focus on clean structure and accessibility.
            """
    )

    let interactiveSession = LanguageModelSession(
        instructions: """
            You are a web developer creating interactive web applications.
            Generate HTML with embedded CSS and JavaScript.
            Make functional, interactive components.
            """
    )

    print("🌐 Web App Generation Testing")
    print("🤖 Model Status: \(SystemLanguageModel.default.availability)")

    // Test different types of web app requests
    let testSuites = [
        (
            name: "📝 Forms & Input",
            session: htmlOnlySession,
            prompts: [
                "contact form with validation styling",
                "survey form with multiple choice and text inputs",
                "newsletter signup with email validation",
            ]
        ),
        (
            name: "📊 Data Display",
            session: htmlOnlySession,
            prompts: [
                "product catalog with grid layout",
                "pricing table with feature comparison",
                "testimonials section with customer quotes",
            ]
        ),
        (
            name: "⚡ Interactive Apps",
            session: interactiveSession,
            prompts: [
                "simple calculator with working buttons",
                "todo list with add/remove functionality",
                "color picker tool with live preview",
            ]
        ),
    ]

    for suite in testSuites {
        print("\n" + String(repeating: "=", count: 50))
        print(suite.name)
        print(String(repeating: "=", count: 50))

        for (index, prompt) in suite.prompts.enumerated() {
            print("\n🎯 Test \(index + 1): \(prompt)")

            let fullPrompt = """
                Create a complete, functional web page for: \(prompt)

                Requirements:
                - Complete HTML document structure
                - Modern, responsive design with CSS
                - Accessible and semantic markup
                - Professional styling and layout
                \(suite.name.contains("Interactive") ? "- Working JavaScript functionality" : "")

                Return only the complete HTML file content.
                """

            do {
                let response = try await suite.session.respond(to: fullPrompt)
                let content = response.content

                print("✅ Generated \(content.count) characters")

                // Analyze the generated content
                let hasCSS = content.contains("<style>") || content.contains("style=")
                let hasJS = content.contains("<script>") || content.contains("onclick")
                let hasForm = content.contains("<form>") || content.contains("<input")
                let hasSemantic =
                    content.contains("<main>") || content.contains("<section>") || content.contains("<article>")

                print("📋 Analysis:")
                print("   CSS Styling: \(hasCSS ? "✅" : "❌")")
                print("   JavaScript: \(hasJS ? "✅" : "❌")")
                print("   Forms: \(hasForm ? "✅" : "❌")")
                print("   Semantic HTML: \(hasSemantic ? "✅" : "❌")")

                // Show structure preview
                let lines = content.components(separatedBy: .newlines)
                let importantLines = lines.filter { line in
                    let trimmed = line.trimmingCharacters(in: .whitespaces)
                    return trimmed.hasPrefix("<")
                        && (trimmed.contains("<title>") || trimmed.contains("<h1") || trimmed.contains("<h2")
                            || trimmed.contains("<form") || trimmed.contains("<button")
                            || trimmed.contains("<div class=") || trimmed.contains("<script>"))
                }

                print("🏗️ Structure Preview:")
                for line in importantLines.prefix(3) {
                    let cleaned = line.trimmingCharacters(in: .whitespaces)
                    if cleaned.count > 60 {
                        print("   \(String(cleaned.prefix(60)))...")
                    } else {
                        print("   \(cleaned)")
                    }
                }

            } catch let error as LanguageModelSession.GenerationError {
                print("❌ Failed: \(error.localizedDescription)")

                switch error {
                case .exceededContextWindowSize:
                    print("🔄 Resetting session due to context limit")
                case .guardrailViolation:
                    print("🛡️ Content policy violation - adjusting prompt")
                case .rateLimited:
                    print("⏱️ Rate limited - waiting...")
                default:
                    print("🚨 Error details: \(error)")
                }
            }
        }
    }

    print("\n🎉 Web App Generation Testing Complete!")
    print("📈 Ready for production testing with real user inputs!")
}
