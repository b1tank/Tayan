//
//  ContentView.swift
//  Tayan
//
//  Created by Zhichao Li on 7/10/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
                .font(.title)
            Button("Tap me") {
                print("Button tapped!")
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
