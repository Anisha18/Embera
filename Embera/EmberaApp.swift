//
//  EmberaApp.swift
//  Embera
//
//  Created by Anisha Dsouza on 17/4/2026.
//

import SwiftUI

// iPhone app entry point. It starts the shared data manager before showing the UI
// so WatchConnectivity can receive messages as soon as the app launches.
@main
struct EmberaApp: App {
    init() {
        // This wakes up the WCSession listener
        _ = DataManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
