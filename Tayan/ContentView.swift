//
//  ContentView.swift
//  Tayan
//
//  Created by Zhichao Li on 7/13/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WebAppGeneratorViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack {
                    Image(systemName: "globe.badge.chevron.backward")
                        .imageScale(.large)
                        .foregroundStyle(.blue)
                        .font(.system(size: 40))
                    Text("Web App Generator")
                        .font(.title2)
                        .fontWeight(.semibold)
                }

                // Input Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Describe your web app:")
                        .font(.headline)

                    TextField(
                        "e.g., 'Create a simple HTML page with a header and a button'",
                        text: $viewModel.userInput,
                        axis: .vertical
                    )
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...6)
                }

                // Generate Button
                Button(action: viewModel.generateWebApp) {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "wand.and.stars")
                        }
                        Text(viewModel.isLoading ? "Generating..." : "Generate Web App")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        viewModel.canGenerate
                            ? Color.blue : Color.gray
                    )
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(!viewModel.canGenerate)

                // Generated Content Section
                if viewModel.hasGeneratedContent {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Generated Web App:")
                                .font(.headline)

                            Spacer()

                            Button("Clear") {
                                viewModel.clearGeneration()
                            }
                            .foregroundColor(.blue)
                        }

                        WebView(htmlContent: viewModel.generatedHTML)
                            .frame(maxHeight: 300)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                }

                Spacer()

                // Model Status
                ModelStatusView(
                    isAvailable: viewModel.modelAvailability.isAvailable,
                    statusMessage: viewModel.modelAvailability.statusMessage,
                    statusColor: viewModel.modelAvailability.statusColor,
                    onRefresh: viewModel.refreshModelStatus
                )
            }
            .padding()
            .navigationTitle("Tayan")
            .navigationBarTitleDisplayMode(.inline)
            .alert(
                viewModel.currentError?.title ?? "Error",
                isPresented: $viewModel.showError
            ) {
                Button("OK") {
                    viewModel.showError = false
                }
            } message: {
                if let error = viewModel.currentError {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(error.message)
                        if let suggestion = error.recoverySuggestion {
                            Text(suggestion)
                                .font(.caption)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
