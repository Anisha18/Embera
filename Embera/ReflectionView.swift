import SwiftUI

struct ReflectionView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
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
                    
                    ReflectionSection(title: "DRINKS", titleColor: mainTextColor) {
                        ToggleRow(icon: "cup.and.saucer.fill", label: "Coffee cups", textColor: mainTextColor) {
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
                        ToggleRow(icon: "wineglass.fill", label: "Had alcohol?", textColor: mainTextColor) {
                            YesNoToggle(isOn: $hadAlcohol)
                        }
                    }
                    
                    ReflectionSection(title: "FOOD & LIFESTYLE", titleColor: mainTextColor) {
                        ToggleRow(icon: "flame.fill", label: "Spicy food?", textColor: mainTextColor) {
                            YesNoToggle(isOn: $hadSpicyFood)
                        }
                        Divider().padding(.horizontal)
                        ToggleRow(icon: "wind", label: "Smoked?", textColor: mainTextColor) {
                            YesNoToggle(isOn: $smoked)
                        }
                    }
                    
                    ReflectionSection(title: "WELLBEING", titleColor: mainTextColor) {
                        ToggleRow(icon: "moon.stars.fill", label: "Night sweat?", textColor: mainTextColor) {
                            YesNoToggle(isOn: $nightSweat)
                        }
                        Divider().padding(.horizontal)
                        ToggleRow(icon: "brain.head.profile", label: "Stressed?", textColor: mainTextColor) {
                            YesNoToggle(isOn: $stressed)
                        }
                    }
                    
                    Button(action: {
                        // SAVE LOGIC: Bundle the state into the struct and save
                        let newReflection = ReflectionData(
                            date: Date(),
                            coffeeCups: coffeeCups,
                            hadAlcohol: hadAlcohol,
                            hadSpicyFood: hadSpicyFood,
                            smoked: smoked,
                            nightSweat: nightSweat,
                            stressed: stressed
                        )
                        DataManager.shared.saveReflection(newReflection)
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

struct ReflectionSection<Content: View>: View {
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
            .background(Color.gray.opacity(0.05))
            .cornerRadius(15)
        }
    }
}

struct ToggleRow<Control: View>: View {
    let icon: String
    let label: String
    let textColor: Color
    let subtitle: String?
    let control: Control

    init(icon: String, label: String, textColor: Color, subtitle: String? = nil, @ViewBuilder control: () -> Control) {
        self.icon = icon
        self.label = label
        self.textColor = textColor
        self.subtitle = subtitle
        self.control = control()
    }

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 25)
            
            VStack(alignment: .leading) {
                Text(label)
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(textColor)
                if let sub = subtitle {
                    Text(sub).font(.caption2).foregroundColor(.gray)
                }
            }
            Spacer()
            control
        }
        .padding()
    }
}

struct YesNoToggle: View {
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            Button("Yes") { isOn = true }
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(isOn ? Color.white : Color.clear)
                .foregroundColor(isOn ? .black : .gray)
                .cornerRadius(8)
                .shadow(radius: isOn ? 2 : 0)
            
            Button("No") { isOn = false }
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(!isOn ? Color(red: 0.6, green: 0.75, blue: 0.7) : Color.clear)
                .foregroundColor(!isOn ? .white : .gray)
                .cornerRadius(8)
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding(2)
    }
}

#Preview {
    ReflectionView()
}
