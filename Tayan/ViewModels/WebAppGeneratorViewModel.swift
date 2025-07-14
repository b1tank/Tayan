//
//  WebAppGeneratorViewModel.swift
//  Tayan
//
//  Created by Zhichao Li on 7/13/25.
//

import Foundation
import FoundationModels
import SwiftUI

@MainActor
class WebAppGeneratorViewModel: ObservableObject {
    @Published var userInput: String = ""
    @Published var generatedHTML: String = ""
    @Published var isLoading: Bool = false
    @Published var currentError: AppGenerationError?
    @Published var showError: Bool = false
    @Published var modelAvailability: ModelAvailability

    private let aiService: AIGenerationService

    init(aiService: AIGenerationService? = nil) {
        self.aiService = aiService ?? AIGenerationService()
        self.modelAvailability = ModelAvailability()
    }

    var canGenerate: Bool {
        !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading
            && modelAvailability.isAvailable
    }

    var hasGeneratedContent: Bool {
        !generatedHTML.isEmpty
    }

    func generateWebApp() {
        guard canGenerate else { return }

        isLoading = true
        currentError = nil

        let request = GenerationRequest(
            prompt: userInput,
            type: .html  // Start with HTML only for Milestone 1
        )

        Task {
            do {
                let response = try await aiService.generateHTML(from: request)

                await MainActor.run {
                    self.generatedHTML = response.content
                    self.userInput = ""  // Clear input after successful generation
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    // Handle FoundationModels specific errors
                    if let generationError = error as? LanguageModelSession.GenerationError {
                        self.handleError(generationError)
                    } else {
                        self.currentError = AppGenerationError(
                            title: "Unexpected Error",
                            message: error.localizedDescription,
                            recoverySuggestion: "Please try again."
                        )
                        self.showError = true
                        self.isLoading = false
                    }
                }
            }
        }
    }

    func clearGeneration() {
        generatedHTML = ""
        currentError = nil
        showError = false
    }

    func refreshModelStatus() {
        modelAvailability = ModelAvailability()
    }

    private func handleError(_ error: Error) {
        if let generationError = error as? LanguageModelSession.GenerationError {
            currentError = AppGenerationError(from: generationError)
            showError = true
            isLoading = false
        } else {
            currentError = AppGenerationError(
                title: "Unexpected Error",
                message: error.localizedDescription,
                recoverySuggestion: "Please try again."
            )
            showError = true
            isLoading = false
        }
    }
}
