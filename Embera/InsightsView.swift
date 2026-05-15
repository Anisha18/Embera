import SwiftUI
import Charts

// One chartable flush record for a specific day.
struct FlushData: Identifiable {
    let id = UUID()
    let day: Int
    let count: Int
    let date: String
    let triggers: [TriggerItem]

    var dateLabel: String {
        let components = date.split(separator: " ")
        guard components.count >= 4 else { return "\(day)" }
        return "\(components[1]) \(components[3].capitalized)"
    }
}

// A possible trigger attached to a flush record.
struct TriggerItem: Identifiable {
    let id = UUID()
    let icon: String
    let text: String
}

// Educational article metadata shown in the "Learn more" carousel.
struct Article: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let attribution: String
    let image: String
    let url: String
}

// Monthly insights screen with date filters, a bar chart, trigger details, and article links.
struct InsightsView: View {
    @Environment(\.colorScheme) var colorScheme
    
    // Theme Colors
    let backgroundWhite = Color(red: 0.98, green: 0.97, blue: 0.95)
    let accentTerracotta = Color(red: 0.82, green: 0.44, blue: 0.33)
    let chartLight = Color(red: 0.97, green: 0.91, blue: 0.89)
    let tagBg = Color(red: 0.88, green: 0.85, blue: 0.82).opacity(0.4)
    let mutedText = Color.secondary
    let symbolColor = Color(red: 0.82, green: 0.44, blue: 0.33)
    
    private var mainTextColor: Color { Color("EmberaText") }
    private var pageBackground: Color {
        colorScheme == .dark ? Color.black : backgroundWhite
    }

    private let calendar = Calendar.current
    private let currentDate = Date()
    
    // Selection state drives both the chart filter and the trigger detail area.
    @State private var selectedMonth: String
    @State private var selectedYear: String
    @State private var selectedEntry: FlushData?
    
    let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    
    // Placeholder/sample data used to populate the chart before real historical storage is added.
    let sampleData: [FlushData] = [
        // APRIL 2026
        FlushData(day: 2, count: 1, date: "THURSDAY 2 APR 2026", triggers: [TriggerItem(icon: "cup.and.saucer.fill", text: "1 Coffee")]),
        FlushData(day: 8, count: 4, date: "WEDNESDAY 8 APR 2026", triggers: [TriggerItem(icon: "brain.head.profile", text: "Stressed")]),
        FlushData(day: 12, count: 5, date: "SATURDAY 12 APR 2026", triggers: [TriggerItem(icon: "cup.and.saucer.fill", text: "5 Coffees"), TriggerItem(icon: "fork.knife", text: "Spicy food")]),
        FlushData(day: 25, count: 2, date: "FRIDAY 25 APR 2026", triggers: [TriggerItem(icon: "sun.max.fill", text: "Hot Weather")]),

        // APRIL 2023
        FlushData(day: 5, count: 3, date: "WEDNESDAY 5 APR 2023", triggers: [TriggerItem(icon: "wind", text: "Cold Breeze")]),
        FlushData(day: 14, count: 6, date: "FRIDAY 14 APR 2023", triggers: [TriggerItem(icon: "wineglass.fill", text: "Alcohol"), TriggerItem(icon: "moon.stars.fill", text: "Late Night")]),
        FlushData(day: 22, count: 2, date: "SATURDAY 22 APR 2023", triggers: [TriggerItem(icon: "figure.run", text: "Exercise")]),

        // FEBRUARY 2023
        FlushData(day: 10, count: 2, date: "FRIDAY 10 FEB 2023", triggers: [TriggerItem(icon: "cup.and.saucer.fill", text: "2 Coffees")]),
        FlushData(day: 14, count: 8, date: "TUESDAY 14 FEB 2023", triggers: [TriggerItem(icon: "heart.fill", text: "Emotional Stress"), TriggerItem(icon: "fork.knife", text: "Heavy Meal")]),
        FlushData(day: 25, count: 2, date: "FRIDAY 25 FEB 2023", triggers: [TriggerItem(icon: "sun.max.fill", text: "Hot Weather")]),
        FlushData(day: 28, count: 4, date: "TUESDAY 28 FEB 2023", triggers: [TriggerItem(icon: "thermometer.sun.fill", text: "Heating On")])
    ]

    // Only entries matching the selected month and year are shown in the chart.
    private var filteredData: [FlushData] {
        sampleData.filter { data in
            data.date.contains(selectedMonth.uppercased()) && data.date.contains(selectedYear)
        }.sorted(by: { $0.day < $1.day })
    }

    // Used for the large monthly total at the top of the chart card.
    private var totalMonthlyFlushes: Int {
        filteredData.reduce(0) { $0 + $1.count }
    }

    // Defaults the filters to the user's current month and year.
    init() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        let now = Date()
        _selectedMonth = State(initialValue: formatter.string(from: now))
        _selectedYear = State(initialValue: String(Calendar.current.component(.year, from: now)))
    }
    
    private var currentYear: String { String(calendar.component(.year, from: currentDate)) }
    private var years: [String] { Array(2020...calendar.component(.year, from: currentDate)).map { String($0) }.reversed() }
    
    // Keeps sparse months readable while allowing dense months to scroll horizontally.
    private var chartContentWidth: CGFloat {
        max(UIScreen.main.bounds.width - 80, CGFloat(filteredData.count) * 60)
    }
    
    // Resolves a tapped chart x-value back to its data entry.
    private func nearestEntry(for day: Int) -> FlushData? {
        filteredData.first { $0.day == day }
    }
    
    // Expands the selected month label while keeping unselected month chips compact.
    private func displayTitle(for month: String) -> String {
        if month == selectedMonth {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            if let date = formatter.date(from: month) {
                formatter.dateFormat = "MMMM"
                return formatter.string(from: date)
            }
        }
        return month
    }

    // Curated educational links shown below the chart.
    let learnMoreArticles: [Article] = [
        Article(title: "Many women do it alone", description: "The survey reports that 39% of Australian women manage menopause symptoms without treatment or support.", attribution: "Jean Hailes for Women's Health", image: "article1", url: "https://www.jeanhailes.org.au/health-a-z/menopause/menopause-management"),
        Article(title: "Flushes last longer than you think", description: "Jean Hailes reports that 3 in 4 Australian women experience hot flushes and night sweats during menopause.", attribution: "Jean Hailes for Women's Health", image: "article2", url: "https://www.jeanhailes.org.au/health-a-z/menopause/hot-flushes-night-sweats"),
        Article(title: "She thought it was her job", description: "Rebecca blamed workplace stress until a panic attack sent her to hospital at 46. Her story reframed what was really happening.", attribution: "Rebecca via Embera", image: "article3", url: "https://embera.io/blogs/stories/rebeccas-story")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                
                // Header row with the screen title and profile image.
                HStack {
                    DoubleSidedText(text: "Monthly Insights", color: mainTextColor)
                    Spacer()
                    Image("ProfileIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 45, height: 45)
                        .clipShape(Circle())
                }
                .padding(.horizontal)

                // Year menu and horizontally scrolling month chips filter the chart.
                VStack(spacing: 12) {
                    HStack {
                        Menu {
                            ForEach(years, id: \.self) { year in
                                Button(year) {
                                    selectedYear = year
                                    selectedEntry = nil // Reset selection when year changes
                                }
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Text(selectedYear)
                                    .font(.subheadline.bold())
                                Image(systemName: "chevron.down")
                                    .font(.caption.bold())
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(accentTerracotta)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        Spacer()
                    }
                    .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(months, id: \.self) { month in
                                SelectionChip(title: displayTitle(for: month), isSelected: selectedMonth == month, activeColor: accentTerracotta, inactiveTextColor: mutedText) {
                                    selectedMonth = month
                                    selectedEntry = nil // Reset selection when month changes
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // Main chart card containing the monthly total, bars, and selected-day details.
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("MONTHLY FLUSHES")
                            .font(.caption).bold().foregroundColor(mutedText)
                        
                        HStack(spacing: 4) {
                            Image("Embera")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 48, height: 48)
                            
                            Text("\(totalMonthlyFlushes)")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(accentTerracotta)
                        }
                    }
                    Divider()
                    
                    if filteredData.isEmpty {
                        VStack {
                            Spacer()
                            Text("No data for \(selectedMonth) \(selectedYear)")
                                .font(.subheadline)
                                .foregroundColor(mutedText)
                            Spacer()
                        }
                        .frame(height: 250)
                        .frame(maxWidth: .infinity)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            Chart {
                                ForEach(filteredData) { item in
                                    BarMark(
                                        x: .value("Day", "\(item.day)"),
                                        y: .value("Count", item.count),
                                        width: .fixed(30)
                                    )
                                    .foregroundStyle(selectedEntry?.day == item.day ? accentTerracotta : chartLight)
                                    .cornerRadius(6)
                                }
                            }
                            .frame(width: chartContentWidth, height: 220)
                            .chartYAxis {
                                AxisMarks(position: .leading) { value in
                                    AxisValueLabel {
                                        if let count = value.as(Int.self) {
                                            Text("\(count)").font(.caption2).foregroundColor(mutedText)
                                        }
                                    }
                                }
                            }
                            .chartXAxis {
                                AxisMarks { value in
                                    AxisValueLabel {
                                        if let dayString = value.as(String.self) {
                                            Text(dayString).font(.system(size: 12, weight: .bold)).foregroundColor(mutedText)
                                        }
                                    }
                                }
                            }
                            .chartOverlay { proxy in
                                GeometryReader { geometry in
                                    Rectangle().fill(.clear).contentShape(Rectangle())
                                        .gesture(DragGesture(minimumDistance: 0).onEnded { value in
                                            guard let plotFrame = proxy.plotFrame.map({ geometry[$0] }) else { return }
                                            let relativeX = value.location.x - plotFrame.minX
                                            if let dayString: String = proxy.value(atX: relativeX), let dayInt = Int(dayString) {
                                                selectedEntry = nearestEntry(for: dayInt)
                                            }
                                        })
                                }
                            }
                        }
                        .frame(height: 250)
                    }

                    HStack {
                        Spacer()
                        Label("Tap a bar for insights per date", systemImage: "info.circle")
                            .font(.system(size: 14))
                            .foregroundColor(mutedText)
                        Spacer()
                    }

                    Divider()

                    // Shows triggers for the tapped bar, or an instruction before a bar is selected.
                    if let entry = selectedEntry {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(entry.date)
                                .font(.caption).bold().foregroundColor(mutedText)
                            
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("\(entry.count)").font(.headline).foregroundColor(mainTextColor)
                                Text("hot flushes").font(.subheadline).foregroundColor(mutedText)
                            }

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(entry.triggers) { trigger in
                                        TagView(icon: trigger.icon, text: trigger.text, bgColor: tagBg, iconColor: symbolColor, textColor: mainTextColor)
                                    }
                                }
                            }
                        }
                    } else {
                        Text("Select a bar above to view triggers")
                            .font(.caption)
                            .foregroundColor(mutedText)
                    }
                }
                .padding(20)
                .background(colorScheme == .dark ? Color(white: 0.12) : Color.white)
                .cornerRadius(25)
                .shadow(color: .black.opacity(0.03), radius: 10, x: 0, y: 5)
                .padding(.horizontal)

                // Article carousel with external links for deeper reading.
                VStack(alignment: .leading, spacing: 15) {
                    Text("Learn more")
                        .font(.title2).bold()
                        .foregroundColor(mainTextColor)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(learnMoreArticles) { article in
                                ArticleCard(title: article.title, description: article.description, attribution: article.attribution, image: article.image, url: article.url, textColor: mainTextColor, sourceColor: mutedText)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                Spacer(minLength: 120)
            }
        }
        .background(pageBackground)
    }
}

// MARK: - Subviews & Helpers

// Thin wrapper around the page title so styling stays consistent if reused later.
struct DoubleSidedText: View {
    let text: String
    let color: Color
    var body: some View {
        Text(text).font(.system(size: 34, weight: .bold)).foregroundColor(color)
    }
}

// Pill-shaped filter control used for month selection.
struct SelectionChip: View {
    let title: String
    let isSelected: Bool
    let activeColor: Color
    let inactiveTextColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline).bold()
                .padding(.horizontal, 18)
                .padding(.vertical, 8)
                .background(isSelected ? activeColor : Color.clear)
                .foregroundColor(isSelected ? .white : inactiveTextColor)
                .background(Capsule().stroke(isSelected ? Color.clear : inactiveTextColor.opacity(0.35), lineWidth: 1))
                .clipShape(Capsule())
        }
    }
}

// Compact trigger label with an icon and text.
struct TagView: View {
    let icon: String
    let text: String
    let bgColor: Color
    let iconColor: Color
    let textColor: Color
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.caption2).foregroundColor(iconColor)
            Text(text).font(.caption).bold().foregroundColor(textColor)
        }
        .padding(.horizontal, 10).padding(.vertical, 6)
        .background(bgColor).cornerRadius(10)
    }
}

// Horizontal article card with an image, summary, source, and outbound link button.
struct ArticleCard: View {
    let title: String
    let description: String
    let attribution: String
    let image: String
    let url: String
    let textColor: Color
    let sourceColor: Color
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topTrailing) {
                Image(image).resizable().aspectRatio(contentMode: .fill).frame(width: 260, height: 150).background(Color.gray.opacity(0.2)).clipped().cornerRadius(15)
                if let validURL = URL(string: url) {
                    Link(destination: validURL) {
                        Image(systemName: "arrow.up.right.circle.fill").resizable().frame(width: 32, height: 32).foregroundColor(.white).background(Circle().fill(Color.black.opacity(0.2))).padding(10)
                    }
                }
            }
            Text(title).font(.headline).foregroundColor(textColor).lineLimit(2)
            Text(description).font(.caption).foregroundColor(sourceColor).lineLimit(3)
            Text("Source: \(attribution)").font(.caption.bold()).foregroundColor(textColor.opacity(0.8)).lineLimit(2)
            Spacer()
        }
        .frame(width: 260, height: 300)
        .padding(12)
        .background(colorScheme == .dark ? Color(white: 0.15) : Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.02), radius: 5)
    }
}

#Preview {
    InsightsView()
}
