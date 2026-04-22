import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0
    
    // Detects if the system is in Light or Dark mode
    @Environment(\.colorScheme) var colorScheme

    // Logic to use adaptive asset "EmberaText"
    private var mainTextColor: Color {
        Color("EmberaText")
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // --- MAIN CONTENT SWITCHER ---
            Group {
                if selectedTab == 0 {
                    HomeView()
                } else {
                    // Replaced placeholder text with your actual InsightsView
                    InsightsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // Ensure the background is consistent across the entire app
            .background(colorScheme == .dark ? Color.black : Color(red: 0.98, green: 0.97, blue: 0.95))

            // --- CUSTOM FLOATING TAB BAR ---
            HStack(spacing: 0) {
                // Home Tab
                Button(action: {
                    withAnimation(.spring()) { selectedTab = 0 }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "house.fill")
                        if selectedTab == 0 {
                            Text("Home")
                                .fontWeight(.medium)
                                .transition(.opacity.combined(with: .move(edge: .leading)))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(selectedTab == 0 ? Capsule().fill(colorScheme == .dark ? Color(white: 0.2) : Color(white: 0.9)) : Capsule().fill(Color.clear))
                    .foregroundColor(selectedTab == 0 ? mainTextColor : .secondary)
                }
                .padding(4)

                // Insights Tab
                Button(action: {
                    withAnimation(.spring()) { selectedTab = 1 }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "waveform.path")
                        if selectedTab == 1 {
                            Text("Insights")
                                .fontWeight(.medium)
                                .transition(.opacity.combined(with: .move(edge: .leading)))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(selectedTab == 1 ? Capsule().fill(colorScheme == .dark ? Color(white: 0.2) : Color(white: 0.9)) : Capsule().fill(Color.clear))
                    .foregroundColor(selectedTab == 1 ? mainTextColor : .secondary)
                }
                .padding(4)
            }
            .frame(width: 240, height: 60)
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
