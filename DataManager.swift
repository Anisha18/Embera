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
    
    // Ensure this string matches your App Group in the screenshot exactly
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
        let count = history.filter { calendar.isDateInToday($0) }.count
        return count
    }
    
    private func saveFlush(date: Date, eventID: String) {
        guard hasProcessed(eventID: eventID) == false else { return }
        
        var history = suite?.array(forKey: Keys.flushHistory) as? [Date] ?? []
        history.append(date)
        suite?.set(history, forKey: Keys.flushHistory)
        markProcessed(eventID: eventID)
        
        print("Saved to UserDefaults. New total count: \(history.count)")
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
        else {
            return
        }
        
        let date = Date(timeIntervalSince1970: timestamp)
        DispatchQueue.main.async {
            self.saveFlush(date: date, eventID: eventID)
        }
    }
    
    func saveReflection(_ data: ReflectionData) {
        if let encoded = try? JSONEncoder().encode(data) {
            suite?.set(encoded, forKey: Keys.lastReflection)
            // Notify the app to refresh the HomeView UI immediately
            NotificationCenter.default.post(name: NSNotification.Name("ReflectionLogged"), object: nil)
        }
    }
    
    func hasReflectedToday() -> Bool {
        guard let data = suite?.data(forKey: Keys.lastReflection),
              let decoded = try? JSONDecoder().decode(ReflectionData.self, from: data) else {
            return false
        }
        // Returns true only if the saved reflection was created today
        return Calendar.current.isDateInToday(decoded.date)
    }
    
    // Required Delegate Methods
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
