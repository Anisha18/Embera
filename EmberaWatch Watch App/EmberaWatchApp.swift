//
//  EmberaWatchApp.swift
//  EmberaWatch Watch App
//
//  Created by Anisha Dsouza on 22/4/2026.
//

import SwiftUI

// Watch app entry point. It starts DataManager so watch taps can be saved locally
// and synced back to the iPhone through WatchConnectivity.
@main
struct EmberaWatch_Watch_AppApp: App {
    init() {
        _ = DataManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            WatchHomeView()
        }
    }
}
