//
//  EmberaApp.swift
//  Embera
//
//  Created by Anisha Dsouza on 17/4/2026.
//

import SwiftUI

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
