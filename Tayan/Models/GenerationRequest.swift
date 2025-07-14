//
//  GenerationRequest.swift
//  Tayan
//
//  Created by Zhichao Li on 7/13/25.
//

import Foundation

struct GenerationRequest {
    let prompt: String
    let type: GenerationType

    enum GenerationType {
        case html
        case htmlWithCSS
        case fullWebApp
    }
}

struct GenerationResponse {
    let content: String
    let metadata: GenerationMetadata
}

struct GenerationMetadata {
    let timestamp: Date
    let requestType: GenerationRequest.GenerationType
    let title: String?

    init(requestType: GenerationRequest.GenerationType, title: String? = nil) {
        self.timestamp = Date()
        self.requestType = requestType
        self.title = title
    }
}
