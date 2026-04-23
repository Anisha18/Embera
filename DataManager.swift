import Foundation
import WatchConnectivity

struct ReflectionData: Codable {
    let date: Date
    let coffeeCups: Int
    let hadAlcohol: Bool
    let hadSpicyFood: Bool
    let smoked: Bool
    let nightSweat: Bool
    let stressed: Bool
}

class DataManager: NSObject, WCSessionDelegate {
    static let shared = DataManager()
    
    private enum Keys {
        static let flushHistory = "flushHistory"
        static let processedFlushEventIDs = "processedFlushEventIDs"
        static let flushEventID = "flushEventID"
        static let flushTimestamp = "flushTimestamp"
        static let lastReflection = "lastReflection"
    }
    
    private let suite = UserDefaults(suiteName: "group.com.anishadsouza.Embera")
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func logFlush() {
        let eventID = UUID().uuidString
        let now = Date()
        saveFlush(date: now, eventID: eventID)
        
        let payload: [String: Any] = [
            Keys.flushEventID: eventID,
            Keys.flushTimestamp: now.timeIntervalSince1970
        ]
        
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(payload, replyHandler: nil) { error in
                print("WatchConnectivity Error: \(error.localizedDescription)")
            }
        } else {
            WCSession.default.transferUserInfo(payload)
        }
    }
    
    func getTodayCount() -> Int {
        let history = suite?.array(forKey: Keys.flushHistory) as? [Date] ?? []
        let calendar = Calendar.current
        return history.filter { calendar.isDateInToday($0) }.count
    }
    
    private func saveFlush(date: Date, eventID: String) {
        guard hasProcessed(eventID: eventID) == false else { return }
        
        var history = suite?.array(forKey: Keys.flushHistory) as? [Date] ?? []
        history.append(date)
        suite?.set(history, forKey: Keys.flushHistory)
        markProcessed(eventID: eventID)
        
        NotificationCenter.default.post(name: NSNotification.Name("FlushLogged"), object: nil)
    }
    
    private func hasProcessed(eventID: String) -> Bool {
        let processedEventIDs = suite?.stringArray(forKey: Keys.processedFlushEventIDs) ?? []
        return processedEventIDs.contains(eventID)
    }
    
    private func markProcessed(eventID: String) {
        var processedEventIDs = suite?.stringArray(forKey: Keys.processedFlushEventIDs) ?? []
        processedEventIDs.append(eventID)
        suite?.set(Array(processedEventIDs.suffix(200)), forKey: Keys.processedFlushEventIDs)
    }
    
    private func handleIncomingPayload(_ payload: [String: Any]) {
        guard
            let eventID = payload[Keys.flushEventID] as? String,
            let timestamp = payload[Keys.flushTimestamp] as? TimeInterval
        else { return }
        
        let date = Date(timeIntervalSince1970: timestamp)
        DispatchQueue.main.async {
            self.saveFlush(date: date, eventID: eventID)
        }
    }
    
    func saveReflection(_ data: ReflectionData) {
        if let encoded = try? JSONEncoder().encode(data) {
            suite?.set(encoded, forKey: Keys.lastReflection)
            NotificationCenter.default.post(name: NSNotification.Name("ReflectionLogged"), object: nil)
        }
    }
    
    func hasReflectedToday() -> Bool {
        // If there were no flushes today, we don't need a reflection.
        if getTodayCount() == 0 {
            return true
        }
        
        guard let data = suite?.data(forKey: Keys.lastReflection),
              let decoded = try? JSONDecoder().decode(ReflectionData.self, from: data) else {
            return false
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.component(.hour, from: now) < 8 {
            return calendar.isDateInToday(decoded.date) || calendar.isDateInYesterday(decoded.date)
        }
        
        return calendar.isDateInToday(decoded.date)
    }
    
    func clearOldHistory() {
        let history = suite?.array(forKey: Keys.flushHistory) as? [Date] ?? []
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let filteredHistory = history.filter { $0 > thirtyDaysAgo }
        suite?.set(filteredHistory, forKey: Keys.flushHistory)
    }
    
    // WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) { session.activate() }
#endif
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        handleIncomingPayload(message)
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        handleIncomingPayload(userInfo)
    }
}
