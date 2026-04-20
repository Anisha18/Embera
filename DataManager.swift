//
//  DataManager.swift
//  EmberaWatch
//
//  Created by Anisha Dsouza on 22/4/2026.
//

import Foundation

struct DataManager {
    static let shared = DataManager()
    // Use your App Group ID here
    private let suite = UserDefaults(suiteName: "group.com.anishadsouza.Embera")
    
    func logFlush() {
        let now = Date()
        var history = suite?.array(forKey: "flushHistory") as? [Date] ?? []
        history.append(now)
        suite?.set(history, forKey: "flushHistory")
        print("Flush logged at: \(now)")
    }
}
