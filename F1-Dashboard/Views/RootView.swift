import SwiftUI

struct RootView: View {
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            ContentView()
                .opacity(showSplash ? 0 : 1)
            
            if showSplash {
                SplashView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.45), value: showSplash)
        .task {
            try? await Task.sleep(nanoseconds: 2_600_000_000)
            showSplash = false
        }
    }
}

#Preview {
    RootView()
}
