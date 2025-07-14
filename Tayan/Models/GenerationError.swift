//
//  GenerationError.swift
//  Tayan
//
//  Created by Zhichao Li on 7/13/25.
//

import Foundation
import FoundationModels

struct AppGenerationError {
    let title: String
    let message: String
    let recoverySuggestion: String?

    init(title: String, message: String, recoverySuggestion: String? = nil) {
        self.title = title
        self.message = message
        self.recoverySuggestion = recoverySuggestion
    }

    init(from error: LanguageModelSession.GenerationError) {
        switch error {
        case .exceededContextWindowSize(_):
            self.title = "Context Window Exceeded"
            self.message = "The conversation has become too long."
            self.recoverySuggestion = "Starting a new session to continue."

        case .assetsUnavailable(_):
            self.title = "Model Assets Unavailable"
            self.message = "AI model assets are not currently available."
            self.recoverySuggestion = "Please try again later or check your internet connection."

        case .guardrailViolation(_):
            self.title = "Content Policy Violation"
            self.message = "The request violates content policies."
            self.recoverySuggestion = "Please modify your request and try again."

        case .unsupportedGuide(_):
            self.title = "Unsupported Feature"
            self.message = "The requested feature is not supported."
            self.recoverySuggestion = "Please try a simpler request."

        case .unsupportedLanguageOrLocale(_):
            self.title = "Language Not Supported"
            self.message = "The current language is not supported by the model."
            self.recoverySuggestion = "Please change your device language or try English."

        case .decodingFailure(_):
            self.title = "Response Parsing Error"
            self.message = "Failed to parse the AI response."
            self.recoverySuggestion = "Please try your request again."

        case .rateLimited(_):
            self.title = "Rate Limited"
            self.message = "Too many requests. Please wait before trying again."
            self.recoverySuggestion = "Wait a moment and try again."

        default:
            self.title = "Generation Error"
            self.message = error.localizedDescription
            self.recoverySuggestion = "Please try again."
        }
    }
}
