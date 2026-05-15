import SwiftUI

// Primary watchOS screen for quickly logging a hot flush.
// It gives immediate visual and haptic feedback after a successful log.
struct WatchHomeView: View {
    // showSuccess temporarily swaps the logo for a checkmark; pulseScale is ready for logo pulsing.
    @State private var showSuccess = false
    @State private var pulseScale: CGFloat = 1.0
    
    let brandOrange = Color(red: 0.95, green: 0.57, blue: 0.29)
    
    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                // Background circle changes color to reinforce the success state.
                Circle()
                    .fill(showSuccess ? Color.green.opacity(0.2) : Color.white.opacity(0.05))
                    .frame(width: 130, height: 130)
                
                // Tapping the logo records a flush through the shared DataManager.
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
                // Lets the primary hand gesture trigger the same log action on supported watchOS versions.
                .handGestureShortcut(.primaryAction)
                // Provides an accessibility action without changing the visual button hierarchy.
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
    
    // Records a flush once, plays feedback, then resets the success state after a short delay.
    private func triggerLog() {
        if showSuccess { return }
        
        // Save through the shared manager so App Group storage and phone sync both happen.
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
