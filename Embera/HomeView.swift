import SwiftUI

struct HomeView: View {
    @State private var isAnimating = false
    @State private var flushCount: Int = DataManager.shared.getTodayCount()
    
    // Detects if the system is in Light or Dark mode
    @Environment(\.colorScheme) var colorScheme
    
    // Theme Colors
    let backgroundWhite = Color(red: 0.98, green: 0.97, blue: 0.95)
    let cardBeige = Color(red: 0.96, green: 0.92, blue: 0.89)
    let cardRose = Color(red: 0.97, green: 0.91, blue: 0.89)
    let accentTerracotta = Color(red: 0.82, green: 0.44, blue: 0.33)
    let buttonGrey = Color(red: 0.88, green: 0.85, blue: 0.82)
    
    // Logic to use your adaptive asset "EmberaText"
    private var mainTextColor: Color {
        Color("EmberaText")
    }

    private var isNightTime: Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 20 || hour < 8
    }

    var body: some View {
        ZStack {
            // Adaptive Background: switches to black in Dark Mode
            (colorScheme == .dark ? Color.black : backgroundWhite)
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Text("Today's Outlook")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(mainTextColor)
                        Spacer()
                        Circle()
                            .fill(buttonGrey)
                            .frame(width: 40, height: 40)
                            .overlay(Image(systemName: "person.fill").foregroundColor(.gray))
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)

                    // Hot Flush Forecast Card
                    VStack(alignment: .leading, spacing: isNightTime ? 15 : 25) {
                        HStack {
                            Image(systemName: "thermometer.medium")
                                .foregroundColor(accentTerracotta)
                            Text("Hot Flush Forecast")
                                .font(.headline)
                                .foregroundColor(mainTextColor)
                        }
                        
                        VStack(spacing: 12) {
                            ZStack(alignment: .trailing) {
                                Capsule()
                                    .fill(LinearGradient(
                                        colors: [accentTerracotta.opacity(0.3), accentTerracotta],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                                    .frame(height: isNightTime ? 8 : 12)
                                
                                Image("Embera")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: isNightTime ? 75 : 100, height: isNightTime ? 75 : 100)
                                    .scaleEffect(isAnimating ? (isNightTime ? 1.12 : 1.2) : 1.0)
                                    .shadow(color: .orange.opacity(isAnimating ? (isNightTime ? 0.7 : 0.9) : 0.2),
                                            radius: isAnimating ? (isNightTime ? 15 : 25) : 5)
                                    .offset(x: -5, y: isNightTime ? -32 : -45)
                            }
                            
                            HStack {
                                Text("Low").font(.subheadline).foregroundColor(.secondary)
                                Spacer()
                                Text("Moderate").font(.subheadline).foregroundColor(.secondary)
                                Spacer()
                                Text("High").font(.headline).foregroundColor(accentTerracotta)
                            }
                        }
                    }
                    .padding(.vertical, isNightTime ? 25 : 45)
                    .padding(.horizontal)
                    // Shifts card color to dark gray in Dark Mode
                    .background(colorScheme == .dark ? Color(white: 0.15) : cardBeige)
                    .cornerRadius(28)
                    .padding(.horizontal)

                    // Nighttime Reflection Card
                    if isNightTime {
                        VStack(spacing: 20) {
                            HStack {
                                Image(systemName: "moon.stars.fill")
                                    .foregroundColor(.yellow)
                                Text("Good Evening, Laura!")
                                    .font(.headline)
                                    .foregroundColor(mainTextColor)
                            }
                            
                            Text("You had \(flushCount) hot flushes today.\nLet's pause to reflect")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                                .lineSpacing(4)
                            
                            HStack(spacing: 15) {
                                Button("Later") {}
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(buttonGrey)
                                    .foregroundColor(.black)
                                    .cornerRadius(25)
                                
                                Button("Reflect") {}
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(accentTerracotta)
                                    .foregroundColor(.white)
                                    .font(.headline)
                                    .cornerRadius(25)
                            }
                        }
                        .padding(25)
                        .background(colorScheme == .dark ? Color(white: 0.12) : cardRose)
                        .cornerRadius(28)
                        .padding(.horizontal)
                    }

                    // Tips Card
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.yellow)
                            Text("Be prepared")
                                .font(.headline)
                                .foregroundColor(mainTextColor)
                        }
                        
                        TipRow(icon: "waterbottle.fill", title: "Keep cold water close", subtitle: "Split throughout the morning", textColor: mainTextColor)
                        Divider()
                        TipRow(icon: "tshirt.fill", title: "Wear extra layer of clothes", subtitle: "Easy to remove in public", textColor: mainTextColor)
                        Divider()
                        TipRow(icon: "wind", title: "Try 4-6 breathing technique", subtitle: "4 in, 6 out", textColor: mainTextColor)
                    }
                    .padding(25)
                    .background(colorScheme == .dark ? Color(white: 0.1) : .white)
                    .cornerRadius(28)
                    .padding(.horizontal)
                    
                    Spacer(minLength: 120)
                }
            }
        }
        .onAppear {
            flushCount = DataManager.shared.getTodayCount()
            withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("FlushLogged"))) { _ in
            // This tells the phone: "Hey, the watch just logged something, refresh the number!"
            flushCount = DataManager.shared.getTodayCount()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            // This ensures the phone checks the "Shared Vault" every time you open the app
            flushCount = DataManager.shared.getTodayCount()
        }
    }
}

struct TipRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let textColor: Color
    
    var body: some View {
        HStack(alignment: .center, spacing: 15) {
            ZStack {
                Circle().fill(Color.blue.opacity(0.1)).frame(width: 40, height: 40)
                Image(systemName: icon).foregroundColor(.blue)
            }
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(textColor)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    HomeView()
}
