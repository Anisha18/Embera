import SwiftUI
import Charts

// Data model for the graph
struct FlushData: Identifiable {
    let id = UUID()
    let day: Int
    let count: Int
}

struct InsightsView: View {
    @Environment(\.colorScheme) var colorScheme
    
    // Theme Colors
    let backgroundWhite = Color(red: 0.98, green: 0.97, blue: 0.95)
    let accentTerracotta = Color(red: 0.82, green: 0.44, blue: 0.33)
    let chartLight = Color(red: 0.97, green: 0.91, blue: 0.89)
    let buttonGrey = Color(red: 0.88, green: 0.85, blue: 0.82)
    
    // Logic to use adaptive asset "EmberaText"
    private var mainTextColor: Color {
        Color("EmberaText")
    }

    // Mock data based on your screenshot's bars
    let sampleData: [FlushData] = [
        FlushData(day: 2, count: 1),
        FlushData(day: 8, count: 4),
        FlushData(day: 12, count: 5),
        FlushData(day: 14, count: 4),
        FlushData(day: 20, count: 2),
        FlushData(day: 22, count: 1),
        FlushData(day: 25, count: 2)
    ]

    var body: some View {
        ZStack {
            // Adaptive Background
            (colorScheme == .dark ? Color.black : backgroundWhite)
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 25) {
                    
                    // HEADER
                    HStack {
                        Text("Monthly Insights")
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

                    // MONTH SELECTOR
                    Text("April")
                        .font(.headline)
                        .foregroundColor(accentTerracotta)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(accentTerracotta.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)

                    // MAIN CHART CARD
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading) {
                            Text("MONTHLY FLUSHES")
                                .font(.caption)
                                .bold()
                                .foregroundColor(.secondary)
                            Text("16")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(mainTextColor)
                        }
                        
                        Divider()
                        
                        Chart {
                            ForEach(sampleData) { item in
                                BarMark(
                                    x: .value("Day", item.day),
                                    y: .value("Count", item.count),
                                    width: .fixed(12)
                                )
                                .foregroundStyle(item.count >= 5 ? accentTerracotta : chartLight)
                                .cornerRadius(4)
                            }
                        }
                        .frame(height: 180)
                        .chartXScale(domain: 1...30)
                        .chartYAxis {
                            AxisMarks(values: [0, 2, 4])
                        }
                        .chartXAxis {
                            AxisMarks(values: [1, 5, 15, 30])
                        }

                        Text("ⓘ Tap a bar for insights per date")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        
                        Divider()

                        // SPECIFIC DAY DETAILS
                        VStack(alignment: .leading, spacing: 12) {
                            Text("SATURDAY 11 APRIL")
                                .font(.caption)
                                .bold()
                                .foregroundColor(.secondary)
                            
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("6")
                                    .font(.headline)
                                    .foregroundColor(mainTextColor)
                                Text("hot flushes")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            HStack {
                                TagView(icon: "cup.and.saucer.fill", text: "5 Coffees", textColor: mainTextColor)
                                TagView(icon: "fork.knife", text: "Spicy food", textColor: mainTextColor)
                                TagView(icon: "brain.head.profile", text: "Stressed", textColor: mainTextColor)
                            }
                            
                            Label("Busiest flush day — coffee, spicy food, and stress all logged.", systemImage: "clipboard")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 5)
                        }
                    }
                    .padding(20)
                    .background(colorScheme == .dark ? Color(white: 0.15) : .white)
                    .cornerRadius(25)
                    .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.03), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)

                    // LEARN MORE SECTION
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Learn more")
                            .font(.title2)
                            .bold()
                            .foregroundColor(mainTextColor)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ArticleCard(
                                    title: "Many women do it alone",
                                    source: "39% of Australian women never discussed menopause with a doctor...",
                                    image: "article1",
                                    url: "https://www.jeanhailes.org.au",
                                    textColor: mainTextColor
                                )
                                ArticleCard(
                                    title: "Flushes last longer than you think",
                                    source: "3 in 4 Australian women experience hot flushes and night sweats...",
                                    image: "article2",
                                    url: "https://www.jeanhailes.org.au",
                                    textColor: mainTextColor
                                )
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer(minLength: 120)
                }
            }
        }
    }
}

// MARK: - Subviews

struct TagView: View {
    let icon: String
    let text: String
    let textColor: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.caption2)
            Text(text).font(.caption).bold()
        }
        .foregroundColor(textColor)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.gray.opacity(0.12))
        .cornerRadius(10)
    }
}

struct ArticleCard: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let source: String
    let image: String
    let url: String
    let textColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topTrailing) {
                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 260, height: 150)
                    .background(Color.gray.opacity(0.2))
                    .clipped()
                    .cornerRadius(15)
                
                Link(destination: URL(string: url)!) {
                    Image(systemName: "arrow.up.right.circle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.white)
                        .background(Circle().fill(Color.black.opacity(0.2)))
                        .padding(10)
                }
            }
            
            Text(title)
                .font(.headline)
                .foregroundColor(textColor)
                .lineLimit(2)
            
            Text(source)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            Spacer()
        }
        .frame(width: 260, height: 280)
        .padding(12)
        .background(colorScheme == .dark ? Color(white: 0.12) : .white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

#Preview {
    InsightsView()
}
