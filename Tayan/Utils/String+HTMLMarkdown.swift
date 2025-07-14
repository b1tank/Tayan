//
//  String+HTMLMarkdown.swift
//  Tayan
//
//  Created by Zhichao Li on 7/13/25.
//

import Foundation

extension String {
    /// Strips markdown code block wrapper from HTML content
    /// Handles formats like ```html ... ``` or ``` ... ```
    func strippingMarkdownWrapper() -> String {
        let trimmedContent = self.trimmingCharacters(in: .whitespacesAndNewlines)

        // Check if content starts with markdown code block
        if trimmedContent.hasPrefix("```") {
            let lines = trimmedContent.components(separatedBy: .newlines)

            // Remove first line (```html or ```)
            var htmlLines = Array(lines.dropFirst())

            // Remove last line if it's just ```
            if let lastLine = htmlLines.last, lastLine.trimmingCharacters(in: .whitespacesAndNewlines) == "```" {
                htmlLines = Array(htmlLines.dropLast())
            }

            return htmlLines.joined(separator: "\n")
        }

        return self
    }
}
