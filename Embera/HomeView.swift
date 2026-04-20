import SwiftUI

struct HomeView: View {
    @State private var isAnimating = false
    
    // Theme Colors based on your template
    let backgroundWhite = Color(red: 0.98, green: 0.97, blue: 0.95)
    let cardBeige = Color(red: 0.96, green: 0.92, blue: 0.89)
    let cardRose = Color(red: 0.97, green: 0.91, blue: 0.89)
    let accentTerracotta = Color(red: 0.82, green: 0.44, blue: 0.33)
    let buttonGrey = Color(red: 0.88, green: 0.85, blue: 0.82)
    
    private var isNightTime: Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 20 || hour < 8
    }

    var body: some View {
        ZStack {
            backgroundWhite.ignoresSafeArea() // Matches the soft background
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Text("Today's Outlook")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(Color(white: 0.1))
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
                                
                                // --- ANIMATED BURNING LOGO ---
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
                    .background(cardBeige)
                    .cornerRadius(28) // Softer corners from template
                    .padding(.horizontal)

                    // Nighttime Only: Reflection Card
                    if isNightTime {
                        VStack(spacing: 20) {
                            HStack {
                                Image(systemName: "moon.stars.fill")
                                    .foregroundColor(.yellow)
                                Text("Good Evening, Laura!")
                                    .font(.headline)
                            }
                            
                            Text("You had 2 hot flushes today.\nLet's pause to reflect")
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
                        .background(cardRose)
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
                            Spacer()
                            Text("See all").foregroundColor(.teal)
                        }
                        
                        TipRow(icon: "waterbottle.fill", title: "Keep cold water close", subtitle: "Split throughout the morning")
                        Divider() // Cleaner look from the screenshot
                        TipRow(icon: "tshirt.fill", title: "Wear extra layer of clothes", subtitle: "Easy to remove in public")
                        Divider()
                        TipRow(icon: "wind", title: "Try 4-6 breathing technique", subtitle: "4 in, 6 out")
                    }
                    .padding(25)
                    .background(.white) // Tips cards are typically white in this style
                    .cornerRadius(28)
                    .padding(.horizontal)
                    
                    Spacer(minLength: 120)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

struct TipRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 15) {
            ZStack {
                Circle().fill(Color.blue.opacity(0.1)).frame(width: 40, height: 40)
                Image(systemName: icon).foregroundColor(.blue)
            }
            VStack(alignment: .leading) {
                Text(title).font(.subheadline).bold()
                Text(subtitle).font(.caption).foregroundColor(.secondary)
            }
        }
    }
}
