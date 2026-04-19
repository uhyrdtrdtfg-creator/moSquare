import SwiftUI

@main
struct MoSquareApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .preferredColorScheme(.light)
                .tint(Theme.accent)
        }
    }
}
