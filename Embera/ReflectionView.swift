import SwiftUI

// Modal form shown at night so the user can record possible triggers for the current cycle.
struct ReflectionView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    // Form state is converted into ReflectionData when the user taps "Log Reflection".
    @State private var coffeeCups = 0
    @State private var hadAlcohol = false
    @State private var hadSpicyFood = false
    @State private var smoked = false
    @State private var nightSweat = false
    @State private var stressed = false
    
    let accentTerracotta = Color(red: 0.82, green: 0.44, blue: 0.33)
    
    private var mainTextColor: Color {
        Color("EmberaText")
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    
                    // Drink-related inputs: coffee count plus an alcohol yes/no toggle.
                    ReflectionSection(title: "DRINKS", titleColor: mainTextColor) {
                        ToggleRow(icon: "cup.and.saucer.fill", isSystemIcon: true, iconColor: Color(red: 0.45, green: 0.35, blue: 0.25), label: "Coffees cups", textColor: mainTextColor) {
                            HStack(spacing: 15) {
                                Button(action: { if coffeeCups > 0 { coffeeCups -= 1 } }) {
                                    Image(systemName: "minus").foregroundColor(accentTerracotta)
                                }
                                Text("\(coffeeCups)").bold().foregroundColor(mainTextColor)
                                Button(action: { coffeeCups += 1 }) {
                                    Image(systemName: "plus").foregroundColor(accentTerracotta)
                                }
                            }
                            .padding(.horizontal, 10)
                        }
                        Divider().padding(.horizontal)
                        ToggleRow(icon: "wineglass.fill", isSystemIcon: true, iconColor: Color(red: 0.8, green: 0.2, blue: 0.2), label: "Had alcohol?", textColor: mainTextColor) {
                            YesNoToggle(isOn: $hadAlcohol)
                        }
                    }
                    
                    // Food and lifestyle questions that may correlate with symptoms.
                    ReflectionSection(title: "FOOD & LIFESTYLE", titleColor: mainTextColor) {
                        ToggleRow(icon: "fork.knife.circle.fill", isSystemIcon: true, iconColor: Color(red: 0.85, green: 0.25, blue: 0.25), label: "Had spicy food?", textColor: mainTextColor) {
                            YesNoToggle(isOn: $hadSpicyFood)
                        }
                        Divider().padding(.horizontal)
                        ToggleRow(icon: "cigarette", isSystemIcon: false, iconColor: Color(red: 0.45, green: 0.35, blue: 0.25), label: "Did you smoke today?", textColor: mainTextColor) {
                            YesNoToggle(isOn: $smoked)
                        }
                    }
                    
                    // Tracks symptoms from the previous night.
                    ReflectionSection(title: "LAST NIGHT", titleColor: mainTextColor) {
                        ToggleRow(icon: "drop.fill", isSystemIcon: true, iconColor: Color(red: 0.4, green: 0.7, blue: 0.85), label: "Night sweat?", textColor: mainTextColor, subtitle: "The night before") {
                            YesNoToggle(isOn: $nightSweat)
                        }
                    }

                    // Captures emotional context before the flush occurred.
                    ReflectionSection(title: "WELLBEING", titleColor: mainTextColor) {
                        ToggleRow(icon: "brain.head.profile", isSystemIcon: true, iconColor: Color(red: 0.85, green: 0.45, blue: 0.55), label: "Stressed before flush?", textColor: mainTextColor, subtitle: "Before it happened") {
                            YesNoToggle(isOn: $stressed)
                        }
                    }
                    
                    // Save the completed reflection to shared storage and close the sheet.
                    Button(action: {
                        let data = ReflectionData(
                            date: Date(),
                            coffeeCups: coffeeCups,
                            hadAlcohol: hadAlcohol,
                            hadSpicyFood: hadSpicyFood,
                            smoked: smoked,
                            nightSweat: nightSweat,
                            stressed: stressed
                        )
                        DataManager.shared.saveReflection(data)
                        dismiss()
                    }) {
                        Text("Log Reflection")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(accentTerracotta)
                            .cornerRadius(15)
                    }
                    .padding(.top, 10)
                }
                .padding()
            }
            // Background consistent with HomeView
            .background(colorScheme == .dark ? Color.black : Color(red: 0.98, green: 0.97, blue: 0.95))
            .navigationTitle("Daily Reflection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(accentTerracotta)
                }
            }
        }
    }
}

// MARK: - Reusable UI Components

// Groups related reflection rows under a small section title and card background.
struct ReflectionSection<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let titleColor: Color
    let content: Content
    
    init(title: String, titleColor: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.titleColor = titleColor
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.caption)
                .bold()
                .foregroundColor(titleColor.opacity(0.6))
                .padding(.leading, 5)
            
            VStack(spacing: 0) {
                content
            }
            // Card color updated for Dark Mode visibility
            .background(colorScheme == .dark ? Color(white: 0.12) : Color.white)
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
        }
    }
}

// Generic form row that supports either SF Symbols or an asset image plus a custom control.
struct ToggleRow<Control: View>: View {
    let icon: String
    let isSystemIcon: Bool
    let iconColor: Color
    let label: String
    let textColor: Color
    let subtitle: String?
    let control: Control

    init(icon: String, isSystemIcon: Bool = true, iconColor: Color = .gray, label: String, textColor: Color, subtitle: String? = nil, @ViewBuilder control: () -> Control) {
        self.icon = icon
        self.isSystemIcon = isSystemIcon
        self.iconColor = iconColor
        self.label = label
        self.textColor = textColor
        self.subtitle = subtitle
        self.control = control()
    }

    var body: some View {
        HStack {
            if isSystemIcon {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 20))
                    .frame(width: 30)
            } else {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(iconColor)
                    .frame(width: 30)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(textColor) // This uses EmberaText
                if let sub = subtitle {
                    Text(sub).font(.caption2).foregroundColor(.secondary)
                }
            }
            Spacer()
            control
        }
        .padding()
    }
}

// Two-segment yes/no control styled to match the reflection card design.
struct YesNoToggle: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            Button("Yes") { isOn = true }
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                // Adapted for Dark Mode
                .background(isOn ? (colorScheme == .dark ? Color(white: 0.3) : Color.white) : Color.clear)
                .foregroundColor(isOn ? (colorScheme == .dark ? .white : .black) : .gray)
                .cornerRadius(8)
                .shadow(color: .black.opacity(isOn ? 0.1 : 0), radius: 2)
            
            Button("No") { isOn = false }
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(!isOn ? Color(red: 0.6, green: 0.75, blue: 0.7) : Color.clear)
                .foregroundColor(!isOn ? .white : .gray)
                .cornerRadius(8)
        }
        .padding(3)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    ReflectionView()
}
