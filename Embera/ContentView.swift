import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0
    
    // Detects if the system is in Light or Dark mode
    @Environment(\.colorScheme) var colorScheme

    // Logic to use your adaptive asset "EmberaText"
    private var mainTextColor: Color {
        Color("EmberaText")
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Main Content Switcher
            Group {
                if selectedTab == 0 {
                    HomeView()
                } else {
                    // Placeholder for your InsightsView
                    Text("Insights View")
                        .font(.title)
                        .foregroundColor(mainTextColor)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        // Ensure background fills the screen behind the text
                        .background(colorScheme == .dark ? Color.black : Color(red: 0.98, green: 0.97, blue: 0.95))
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
                    // Highlighting the capsule based on selection
                    .background(selectedTab == 0 ? Capsule().fill(colorScheme == .dark ? Color(white: 0.2) : Color(white: 0.9)) : Capsule().fill(Color.clear))
                    // Uses EmberaText for the active tab and secondary for inactive
                    .foregroundColor(selectedTab == 0 ? mainTextColor : .secondary)
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
                    .background(selectedTab == 1 ? Capsule().fill(colorScheme == .dark ? Color(white: 0.2) : Color(white: 0.9)) : Capsule().fill(Color.clear))
                    .foregroundColor(selectedTab == 1 ? mainTextColor : .secondary)
                }
                .padding(4)
            }
            .frame(width: 240, height: 60)
            // Tab bar background adjusts for Dark Mode
            .background(colorScheme == .dark ? Color(white: 0.12) : Color(white: 0.98))
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 10, x: 0, y: 5)
            .padding(.bottom, 30)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    ContentView()
}
