import FoundationModels
import SwiftUI

//
//  ContentView.swift
//  Tayan
//
//  Created by Zhichao Li on 7/10/25.
//

struct ContentView: View {
    @State private var session = LanguageModelSession()
    @State private var userInput: String = ""
    @State private var response: String = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack {
                    Image(systemName: "brain.head.profile")
                        .imageScale(.large)
                        .foregroundStyle(.blue)
                        .font(.system(size: 40))
                    Text("FoundationModels Test")
                        .font(.title2)
                        .fontWeight(.semibold)
                }

                // Input Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ask me anything:")
                        .font(.headline)

                    TextField("Enter your question here...", text: $userInput, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...6)
                }

                // Send Button
                Button(action: sendMessage) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "paperplane.fill")
                        }
                        Text(isLoading ? "Thinking..." : "Send")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading
                            ? Color.gray : Color.blue
                    )
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)

                // Response Section
                if !response.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Response:")
                            .font(.headline)

                        ScrollView {
                            Text(response)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                        }
                        .frame(maxHeight: 200)
                    }
                }

                Spacer()

                // Model Status
                modelStatusView
            }
            .padding()
            .navigationTitle("AI Chat")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Error", isPresented: $showError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    @ViewBuilder
    private var modelStatusView: some View {
        HStack {
            Image(systemName: "circle.fill")
                .foregroundColor(modelStatusColor)
                .font(.caption)
            Text(modelStatusText)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private var modelStatusColor: Color {
        switch SystemLanguageModel.default.availability {
        case .available:
            return .green
        case .unavailable:
            return .red
        }
    }

    private var modelStatusText: String {
        switch SystemLanguageModel.default.availability {
        case .available:
            return "Model Available"
        case .unavailable(let reason):
            return "Model Unavailable: \(reason)"
        }
    }

    private func sendMessage() {
        guard !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        isLoading = true

        Task {
            do {
                let result = try await session.respond(to: userInput)

                await MainActor.run {
                    response = result.content
                    userInput = ""
                    isLoading = false
                }
            } catch let error {
                await MainActor.run {
                    handleGeneratedError(error as! LanguageModelSession.GenerationError)
                }
            }
        }
    }

    private func handleGeneratedError(_ error: LanguageModelSession.GenerationError) {
        isLoading = false

        switch error {
        case .exceededContextWindowSize(let context):
            // Create new session with condensed history if possible
            session = newSession(previousSession: session)
            presentGeneratedError(error, context: context)

        case .assetsUnavailable(let context):
            presentGeneratedError(error, context: context)

        case .guardrailViolation(let context):
            presentGeneratedError(error, context: context)

        case .unsupportedGuide(let context):
            presentGeneratedError(error, context: context)

        case .unsupportedLanguageOrLocale(let context):
            presentGeneratedError(error, context: context)

        case .decodingFailure(let context):
            presentGeneratedError(error, context: context)

        case .rateLimited(let context):
            presentGeneratedError(error, context: context)

        default:
            errorMessage = "Failed to respond: \(error.localizedDescription)"
            showError = true
        }
    }

    private func presentGeneratedError(
        _ error: LanguageModelSession.GenerationError,
        context: LanguageModelSession.GenerationError.Context
    ) {
        var message = "Failed to respond: \(error.errorDescription)"

        if let failureReason = error.failureReason {
            message += "\nReason: \(failureReason)"
        }

        if let recoverySuggestion = error.recoverySuggestion {
            message += "\nSuggestion: \(recoverySuggestion)"
        }

        errorMessage = message
        showError = true

        // Log detailed context for debugging
        print("Generation error context: \(context)")
    }

    private func newSession(previousSession: LanguageModelSession) -> LanguageModelSession {
        // For context window exceeded errors, create a new session without history
        // This is the recommended approach from the Apple documentation
        return LanguageModelSession()
    }
}
#Preview {
    ContentView()
}
