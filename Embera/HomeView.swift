import SwiftUI

struct HomeView: View {
    @State private var isAnimating = false
    @State private var isShowingReflection = false
    @State private var flushCount: Int = DataManager.shared.getTodayCount()
    @State private var hasReflectedToday: Bool = DataManager.shared.hasReflectedToday()
    @State private var temporarilyHideReflection = false
    
    @Environment(\.colorScheme) var colorScheme
    
    // Theme Colors
    let backgroundWhite = Color(red: 0.98, green: 0.97, blue: 0.95)
    let cardRose = Color(red: 0.97, green: 0.91, blue: 0.89)
    let accentTerracotta = Color(red: 0.82, green: 0.44, blue: 0.33)
    let buttonGrey = Color(red: 0.88, green: 0.85, blue: 0.82)
    
    let blueWater = Color(red: 0.15, green: 0.70, blue: 0.84)
    let greenTshirt = Color(red: 0.26, green: 0.82, blue: 0.72)
    let greyWind = Color(red: 0.53, green: 0.59, blue: 0.67)
    
    private var mainTextColor: Color {
        Color("EmberaText")
    }

    private var isNightTime: Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 20 || hour < 8
    }

    var body: some View {
        ZStack {
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
                            .overlay(
                                Image("ProfileIcon")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(Circle())
                            )
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
                    .background(colorScheme == .dark ? Color(white: 0.15) : .white)
                    .cornerRadius(28)
                    .padding(.horizontal)

                    // CONDITIONAL CONTENT AREA
                    if isNightTime && !hasReflectedToday && !temporarilyHideReflection {
                        // --- 1. NIGHTTIME: Reflection Card ---
                        VStack(spacing: 20) {
                            Text("Good Evening!")
                                .font(.headline)
                                .foregroundColor(mainTextColor)
                            
                            Text("You had \(flushCount) hot flushes today.\nLet's pause to reflect")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                                .lineSpacing(4)
                            
                            HStack(spacing: 15) {
                                Button("Later") {
                                    withAnimation(.spring()) { temporarilyHideReflection = true }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(colorScheme == .dark ? Color(white: 0.2) : .white)
                                .foregroundColor(mainTextColor)
                                .cornerRadius(25)
                                .overlay(RoundedRectangle(cornerRadius: 25).stroke(buttonGrey, lineWidth: 1))
                                
                                Button("Reflect") {
                                    isShowingReflection = true
                                }
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
                        .transition(.asymmetric(insertion: .opacity, removal: .move(edge: .leading)))
                        
                    } else if isNightTime && hasReflectedToday {
                        // --- 2. NIGHTTIME: Reflection Complete (Disappears in Morning) ---
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Reflection Complete")
                                    .font(.headline)
                                    .foregroundColor(mainTextColor)
                                Text("Rest well tonight.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                        }
                        .padding(25)
                        .background(colorScheme == .dark ? Color(white: 0.12) : Color.white)
                        .cornerRadius(28)
                        .padding(.horizontal)

                    } else if !isNightTime && flushCount > 0 {
                        // --- 3. DAYTIME: Action Plan (Only if flushes recorded) ---
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Daytime Progress")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(accentTerracotta)
                                .textCase(.uppercase)
                            
                            Text("Laura, you have recorded \(flushCount) hot \(flushCount == 1 ? "flush" : "flushes") today. Make sure you follow the **Action Plan**.")
                                .font(.body)
                                .foregroundColor(mainTextColor)
                                .lineSpacing(4)
                        }
                        .padding(25)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(colorScheme == .dark ? Color(white: 0.12) : Color.white)
                        .cornerRadius(28)
                        .padding(.horizontal)
                        .transition(.opacity)
                    }

                    // Tips Card
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Be prepared")
                            .font(.headline)
                            .foregroundColor(mainTextColor)
                        
                        TipRow(icon: "waterbottle.fill", iconColor: blueWater, title: "Keep cold water close", subtitle: "Split throughout the morning", textColor: mainTextColor)
                        Divider()
                        TipRow(icon: "tshirt.fill", iconColor: greenTshirt, title: "Wear extra layer of clothes", subtitle: "Easy to remove in public", textColor: mainTextColor)
                        Divider()
                        TipRow(icon: "wind", iconColor: greyWind, title: "Try 4-6 breathing technique", subtitle: "4 in, 6 out", textColor: mainTextColor)
                    }
                    .padding(25)
                    .background(colorScheme == .dark ? Color(white: 0.1) : .white)
                    .cornerRadius(28)
                    .padding(.horizontal)
                    
                    Spacer(minLength: 120)
                }
            }
        }
        .sheet(isPresented: $isShowingReflection) {
            ReflectionView()
        }
        .onAppear {
            refreshData()
            temporarilyHideReflection = false
            withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("FlushLogged"))) { _ in refreshData() }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ReflectionLogged"))) { _ in refreshData() }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in refreshData() }
    }
    
    private func refreshData() {
        flushCount = DataManager.shared.getTodayCount()
        hasReflectedToday = DataManager.shared.hasReflectedToday()
    }
}

struct TipRow: View {
    let icon: String
    let iconColor: Color // Added for color variety
    let title: String
    let subtitle: String
    let textColor: Color
    
    var body: some View {
        HStack(alignment: .center, spacing: 15) {
            ZStack {
                Circle().fill(iconColor.opacity(0.1)).frame(width: 40, height: 40)
                Image(systemName: icon).foregroundColor(iconColor)
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
