import SwiftUI

struct SplashView: View {
    @State private var pulse = false
    @State private var logoScale: CGFloat = 0.6
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            RadialGradient(
                colors: [Color.f1Red.opacity(0.35), Color.clear],
                center: .center,
                startRadius: 20,
                endRadius: pulse ? 220 : 160
            )
            .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulse)
            
            VStack(spacing: 28) {
                Image("f1-logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .scaleEffect(logoScale)
                    .opacity(opacity)
                    .shadow(color: .f1Red.opacity(0.55), radius: pulse ? 28 : 12)
                
                Text("F1 DASHBOARD")
                    .font(AppFont.orbitron(22, weight: .heavy))
                    .foregroundStyle(.white)
                    .tracking(2.5)
                    .opacity(opacity)
            }
        }
        .onAppear {
            pulse = true
            withAnimation(.spring(response: 0.85, dampingFraction: 0.72)) {
                logoScale = 1.0
                opacity = 1.0
            }
        }
    }
}
