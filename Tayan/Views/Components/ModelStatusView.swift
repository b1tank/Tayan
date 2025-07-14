//
//  ModelStatusView.swift
//  Tayan
//
//  Created by Zhichao Li on 7/13/25.
//

import SwiftUI

struct ModelStatusView: View {
    let isAvailable: Bool
    let statusMessage: String
    let statusColor: String
    let onRefresh: () -> Void

    var body: some View {
        HStack {
            Button(action: onRefresh) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(colorFromString(statusColor))
                        .frame(width: 8, height: 8)

                    Text(statusMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Image(systemName: "arrow.clockwise")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()
        }
    }

    private func colorFromString(_ colorString: String) -> Color {
        switch colorString {
        case "green":
            return .green
        case "red":
            return .red
        default:
            return .gray
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ModelStatusView(
            isAvailable: true,
            statusMessage: "Model Available",
            statusColor: "green",
            onRefresh: {}
        )

        ModelStatusView(
            isAvailable: false,
            statusMessage: "Model Unavailable: Not connected",
            statusColor: "red",
            onRefresh: {}
        )
    }
    .padding()
}
