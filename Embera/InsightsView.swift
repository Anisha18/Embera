import SwiftUI

struct InsightsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        Text("Insights")
                            .font(.largeTitle.bold())
                        Spacer()
                        Text("< April 2026 >")
                            .font(.caption.bold())
                            .padding(8)
                            .background(Capsule().fill(.white))
                    }
                    .padding(.horizontal)

                    // Stats Grid
                    HStack(spacing: 16) {
                        StatCard(title: "FLUSHES LOGGED", value: "18", unit: "this month", color: .orange)
                        StatCard(title: "AVG SEVERITY", value: "2.4", unit: "out of 5", color: .orange)
                    }
                    .padding(.horizontal)

                    // Peak Window Chart
                    VStack(alignment: .leading, spacing: 16) {
                        Text("MOST COMMON TIME").font(.caption.bold()).foregroundColor(.secondary)
                        HStack(alignment: .bottom, spacing: 8) {
                            ForEach([30, 50, 40, 90, 80, 45, 20], id: \.self) { height in
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(height > 70 ? Color.orange : Color.orange.opacity(0.3))
                                    .frame(height: CGFloat(height))
                            }
                        }
                        Text("Peak window: 2–4pm").font(.caption.bold()).foregroundColor(.orange)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.white)
                    .cornerRadius(24)
                    .padding(.horizontal)

                    // Triggers
                    VStack(alignment: .leading, spacing: 12) {
                        Text("TOP TRIGGERS REPORTED").font(.caption.bold()).foregroundColor(.secondary)
                        TriggerRow(label: "Coffee", percentage: 0.72)
                        TriggerRow(label: "Stress", percentage: 0.58)
                        TriggerRow(label: "Spicy", percentage: 0.34)
                    }
                    .padding()
                    .background(.white)
                    .cornerRadius(24)
                    .padding(.horizontal)
                }
            }
            .background(Color(red: 0.98, green: 0.94, blue: 0.92).ignoresSafeArea())
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.caption2.bold()).foregroundColor(.secondary)
            Text(value).font(.title.bold()).foregroundColor(color)
            Text(unit).font(.caption2)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .cornerRadius(20)
    }
}

struct TriggerRow: View {
    let label: String
    let percentage: CGFloat
    
    var body: some View {
        HStack {
            Text(label).frame(width: 60, alignment: .leading)
            GeometryReader { geo in
                Capsule()
                    .fill(Color.orange.opacity(0.1))
                    .overlay(
                        Capsule()
                            .fill(Color.orange)
                            .frame(width: geo.size.width * percentage),
                        alignment: .leading
                    )
            }
            .frame(height: 8)
            Text("\(Int(percentage * 100))%").font(.caption2)
        }
    }
}

#Preview {
    InsightsView()
}
