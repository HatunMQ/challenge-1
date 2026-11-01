import SwiftUI
import SwiftData

@main struct MyApp: App {
    // The welcome page shows every time the app opens; Start goes to Home
    @State private var showWelcome = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showWelcome {
                    WelcomeView(onStart: { showWelcome = false })
                        .transition(.opacity)
                } else {
                    NavigationStack {
                        HomeView()
                    }
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.4), value: showWelcome)
            // The place where finished drawings are saved
            .modelContainer(for: SavedDrawing.self)
        }
    }
}
#Preview {
    WelcomeView()
}
