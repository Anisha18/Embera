import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            // Main Content Switcher
            Group {
                if selectedTab == 0 {
                    HomeView()
                } else {
                    // Placeholder for your InsightsView
                    Text("Insights View")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }

            // --- CUSTOM FLOATING TAB BAR ---
            HStack(spacing: 0) {
                // Home Tab
                Button(action: { selectedTab = 0 }) {
                    HStack(spacing: 8) {
                        Image(systemName: "house.fill")
                        if selectedTab == 0 {
                            Text("Home").fontWeight(.medium)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(selectedTab == 0 ? Capsule().fill(Color(white: 0.9)) : Capsule().fill(Color.clear))
                    .foregroundColor(selectedTab == 0 ? .blue : .secondary)
                }
                .padding(4)

                // Insights Tab
                Button(action: { selectedTab = 1 }) {
                    HStack(spacing: 8) {
                        Image(systemName: "waveform.path")
                        if selectedTab == 1 {
                            Text("Insights").fontWeight(.medium)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(selectedTab == 1 ? Capsule().fill(Color(white: 0.9)) : Capsule().fill(Color.clear))
                    .foregroundColor(selectedTab == 1 ? .blue : .secondary)
                }
                .padding(4)
            }
            .frame(width: 240, height: 60)
            .background(Color(white: 0.98))
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            .padding(.bottom, 30)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}
