import SwiftUI
import SwiftData

@main struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                SwiftUIView1()
            }
            // The place where finished drawings are saved
            .modelContainer(for: SavedDrawing.self)
        }
    }
}
