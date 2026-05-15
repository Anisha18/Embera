import SwiftUI

// Simple wrapper that keeps WatchHomeView available under a generic content-view name.
struct WatchContentView: View {
    var body: some View {
        WatchHomeView()
    }
}
#Preview {
    WatchContentView()
}
