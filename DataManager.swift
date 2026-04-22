//
//  DataManager.swift
//  EmberaWatch
//
//  Created by Anisha Dsouza on 22/4/2026.
//

import Foundation

struct DataManager {
    static let shared = DataManager()
    private let suite = UserDefaults(suiteName: "group.com.anishadsouza.Embera")
    
    func logFlush() {
        let now = Date()
        var history = suite?.array(forKey: "flushHistory") as? [Date] ?? []
        history.append(now)
        suite?.set(history, forKey: "flushHistory")
        
        // This "broadcasts" a message that the data changed
        NotificationCenter.default.post(name: NSNotification.Name("FlushLogged"), object: nil)
        
        print("Flush logged at: \(now)")
    }

    // NEW: Get the total count for today
    func getTodayCount() -> Int {
        let history = suite?.array(forKey: "flushHistory") as? [Date] ?? []
        let calendar = Calendar.current
        return history.filter { calendar.isDateInToday($0) }.count
    }
}
