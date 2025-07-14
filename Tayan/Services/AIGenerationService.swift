//
//  AIGenerationService.swift
//  Tayan
//
//  Created by Zhichao Li on 7/13/25.
//

import Foundation
import FoundationModels

@MainActor
class AIGenerationService: ObservableObject {
    private var session: LanguageModelSession

    init() {
        self.session = LanguageModelSession(
            instructions: """
                You are an expert web developer. Generate clean, modern, and functional HTML code based on user descriptions.

                For HTML-only requests:
                - Create semantic, accessible HTML
                - Use proper HTML5 structure
                - Include inline styles if needed for basic styling
                - Make forms functional with proper input types
                - Ensure responsive design principles

                Always respond with complete, valid HTML that can be rendered immediately.
                Do not include markdown code blocks or explanations - just the HTML code.
                """
        )
    }

    func generateHTML(from request: GenerationRequest) async throws -> GenerationResponse {
        let prompt = createPrompt(for: request)

        do {
            let response = try await session.respond(to: prompt)

            return GenerationResponse(
                content: response.content,
                metadata: GenerationMetadata(
                    requestType: request.type,
                    title: extractTitle(from: request.prompt)
                )
            )
        } catch let error as LanguageModelSession.GenerationError {
            // Handle context window exceeded by creating new session
            if case .exceededContextWindowSize = error {
                await resetSession()
                // Retry once with new session
                let response = try await session.respond(to: prompt)
                return GenerationResponse(
                    content: response.content,
                    metadata: GenerationMetadata(
                        requestType: request.type,
                        title: extractTitle(from: request.prompt)
                    )
                )
            }
            throw error
        }
    }

    private func createPrompt(for request: GenerationRequest) -> String {
        switch request.type {
        case .html:
            return """
                Create a complete HTML page for: \(request.prompt)

                Requirements:
                - Complete HTML document with DOCTYPE, html, head, and body tags
                - Include a title in the head section
                - Use semantic HTML5 elements
                - Add basic inline CSS for styling and layout
                - Make it responsive and accessible
                - Ensure all forms are functional

                Generate only the HTML code, no explanations or markdown.
                """

        case .htmlWithCSS:
            return """
                Create a complete HTML page with embedded CSS for: \(request.prompt)

                Requirements:
                - Complete HTML document structure
                - Embedded CSS in <style> tags within <head>
                - Modern, clean design
                - Responsive layout
                - Proper color scheme and typography

                Generate only the HTML code with embedded CSS, no explanations.
                """

        case .fullWebApp:
            return """
                Create a complete web application for: \(request.prompt)

                Requirements:
                - Complete HTML document with CSS and JavaScript
                - Interactive functionality using JavaScript
                - Modern UI with good UX
                - Responsive design
                - Proper error handling in JavaScript

                Generate only the complete HTML file with embedded CSS and JavaScript.
                """
        }
    }

    private func extractTitle(from prompt: String) -> String {
        // Simple title extraction - take first few words or use prompt as-is if short
        let words = prompt.split(separator: " ").prefix(4)
        return words.joined(separator: " ").capitalized
    }

    private func resetSession() async {
        session = LanguageModelSession(
            instructions: """
                You are an expert web developer. Generate clean, modern, and functional HTML code based on user descriptions.

                For HTML-only requests:
                - Create semantic, accessible HTML
                - Use proper HTML5 structure
                - Include inline styles if needed for basic styling
                - Make forms functional with proper input types
                - Ensure responsive design principles

                Always respond with complete, valid HTML that can be rendered immediately.
                Do not include markdown code blocks or explanations - just the HTML code.
                """
        )
    }
}
