import SwiftUI

struct WatchHomeView: View {
    @State private var showSuccess = false
    @State private var pulseScale: CGFloat = 1.0
    
    let brandOrange = Color(red: 0.95, green: 0.57, blue: 0.29)
    
    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                // Background Circle (Success state indicator)
                Circle()
                    .fill(showSuccess ? Color.green.opacity(0.2) : Color.white.opacity(0.05))
                    .frame(width: 130, height: 130)
                
                // The Logo Button
                Button(action: {
                    triggerLog()
                }) {
                    Group {
                        if showSuccess {
                            Image(systemName: "checkmark")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.green)
                                .transition(.scale.combined(with: .opacity))
                        } else {
                            Image("Embera")
                                .resizable()
                                .renderingMode(.original)
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                        }
                    }
                }
                .buttonStyle(.plain)
                // watchOS 11+ Hand Gesture Shortcut
                .handGestureShortcut(.primaryAction)
                // This creates a clean target for the system to 'glow' without breaking the view hierarchy
                .accessibilityRepresentation {
                    Button("Log Flush") {
                        triggerLog()
                    }
                }
                .scaleEffect(showSuccess ? 1.1 : pulseScale)
                .onTapGesture(count: 2) {
                    triggerLog()
                }
            }
            
            Text(showSuccess ? "Logged!" : "Tap to log hot flush")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(showSuccess ? .green : .secondary)
                .padding(.top, 8)
            
            Spacer()
        }
    }
    
    private func triggerLog() {
        if showSuccess { return }
        
        // 1. ADD THIS LINE: This physically saves the data to the App Group
        DataManager.shared.logFlush()
        
        #if os(watchOS)
        WKInterfaceDevice.current().play(.success)
        #endif
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            showSuccess = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showSuccess = false
            }
        }
    }
}

#Preview {
    WatchHomeView()
}
