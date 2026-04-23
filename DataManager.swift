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
    
    // MARK: - Helper for 8 AM Cycle
    private func getLast8AMAnchor() -> Date {
        let calendar = Calendar.current
        let now = Date()
        var anchor = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: now)!
        
        // If it's currently before 8 AM, the cycle started at 8 AM yesterday
        if calendar.component(.hour, from: now) < 8 {
            anchor = calendar.date(byAdding: .day, value: -1, to: anchor)!
        }
        return anchor
    }
    
    // MARK: - Flush Logic
    func getTodayCount() -> Int {
        let history = suite?.array(forKey: Keys.flushHistory) as? [Date] ?? []
        let anchor = getLast8AMAnchor()
        return history.filter { $0 >= anchor }.count
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
            WCSession.default.sendMessage(payload, replyHandler: nil)
        } else {
            WCSession.default.transferUserInfo(payload)
        }
    }
    
    private func saveFlush(date: Date, eventID: String) {
        guard !hasProcessed(eventID: eventID) else { return }
        var history = suite?.array(forKey: Keys.flushHistory) as? [Date] ?? []
        history.append(date)
        suite?.set(history, forKey: Keys.flushHistory)
        markProcessed(eventID: eventID)
        NotificationCenter.default.post(name: NSNotification.Name("FlushLogged"), object: nil)
    }
    
    // MARK: - Reflection Logic
    func saveReflection(_ data: ReflectionData) {
        if let encoded = try? JSONEncoder().encode(data) {
            suite?.set(encoded, forKey: Keys.lastReflection)
            NotificationCenter.default.post(name: NSNotification.Name("ReflectionLogged"), object: nil)
        }
    }
    
    func hasReflectedToday() -> Bool {
        // If no flushes occurred in this 8am-8am cycle, no reflection needed
        if getTodayCount() == 0 { return true }
        
        guard let data = suite?.data(forKey: Keys.lastReflection),
              let decoded = try? JSONDecoder().decode(ReflectionData.self, from: data) else {
            return false
        }
        
        let anchor = getLast8AMAnchor()
        // If the saved reflection happened after the last 8 AM, it counts for this cycle
        return decoded.date >= anchor
    }
    
    // MARK: - Watch Connectivity Boilerplate
    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    private func hasProcessed(eventID: String) -> Bool {
        let processed = suite?.stringArray(forKey: Keys.processedFlushEventIDs) ?? []
        return processed.contains(eventID)
    }
    
    private func markProcessed(eventID: String) {
        var processed = suite?.stringArray(forKey: Keys.processedFlushEventIDs) ?? []
        processed.append(eventID)
        suite?.set(Array(processed.suffix(200)), forKey: Keys.processedFlushEventIDs)
    }
    
    func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {}
#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) { session.activate() }
#endif
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) { handleIncomingPayload(message) }
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) { handleIncomingPayload(userInfo) }
    
    private func handleIncomingPayload(_ payload: [String: Any]) {
        guard let id = payload[Keys.flushEventID] as? String,
              let ts = payload[Keys.flushTimestamp] as? TimeInterval else { return }
        DispatchQueue.main.async { self.saveFlush(date: Date(timeIntervalSince1970: ts), eventID: id) }
    }
}
