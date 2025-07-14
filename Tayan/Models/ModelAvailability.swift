//
//  ModelAvailability.swift
//  Tayan
//
//  Created by Zhichao Li on 7/13/25.
//

import Foundation
import FoundationModels

struct ModelAvailability {
    let isAvailable: Bool
    let statusMessage: String
    let statusColor: String  // We'll use string here and convert to Color in the view

    init() {
        switch SystemLanguageModel.default.availability {
        case .available:
            self.isAvailable = true
            self.statusMessage = "Model Available"
            self.statusColor = "green"
        case .unavailable(let reason):
            self.isAvailable = false
            self.statusMessage = "Model Unavailable: \(reason)"
            self.statusColor = "red"
        }
    }
}
