//
//  ModelStatusTest.swift
//  Tayan Playground
//
//  Created by Zhichao Li on 7/13/25.
//
//  Swift Playground to test FoundationModels availability and basic functionality

import FoundationModels
import Playgrounds
import SwiftUI

#Playground {
    print("🔍 FoundationModels Status Check")
    print(String(repeating: "=", count: 40))

    // Check model availability
    let model = SystemLanguageModel.default

    switch model.availability {
    case .available:
        print("✅ FoundationModels is AVAILABLE")
        print("🎯 Ready for HTML generation!")

        // Test basic functionality
        print("\n🧪 Testing Basic Generation...")

        let session = LanguageModelSession()

        let testPrompts = [
            "Say hello in HTML format",
            "Create a simple button with inline CSS",
            "Generate a basic webpage structure",
        ]

        for (index, prompt) in testPrompts.enumerated() {
            print("\n📝 Test \(index + 1): \(prompt)")

            do {
                let response = try await session.respond(to: prompt)
                print("✅ Response (\(response.content.count) chars): \(String(response.content.prefix(100)))...")
            } catch {
                print("❌ Failed: \(error.localizedDescription)")
            }
        }

    case .unavailable(let reason):
        print("❌ FoundationModels is UNAVAILABLE")
        print("📋 Reason: \(reason)")
        print("💡 Possible solutions:")
        print("   • Check internet connection")
        print("   • Verify iOS version compatibility")
        print("   • Wait for model download to complete")
        print("   • Check device storage space")
    }

    // Test supported languages
    print("\n🌍 Supported Languages:")
    let supportedLanguages = model.supportedLanguages
    if supportedLanguages.isEmpty {
        print("   📝 Language info not available")
    } else {
        for language in supportedLanguages.prefix(5) {
            print("   🔤 \(language.languageCode?.identifier ?? "Unknown")")
        }
        if supportedLanguages.count > 5 {
            print("   ... and \(supportedLanguages.count - 5) more")
        }
    }

    print("\n🎯 Model Status Summary:")
    print("   Available: \(model.availability == .available ? "✅" : "❌")")
    print("   Languages: \(supportedLanguages.count)")
    print("   Ready for Tayan: \(model.availability == .available ? "🚀" : "⏳")")
}
