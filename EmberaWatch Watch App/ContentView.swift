//
//  ContentView.swift
//  EmberaWatch Watch App
//
//  Created by Anisha Dsouza on 22/4/2026.
//

import SwiftUI

// Default starter view retained for previews or future watch experiments.
// The active watch app currently launches WatchHomeView instead.
struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
