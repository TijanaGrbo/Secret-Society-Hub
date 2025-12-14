import SwiftUI
import SwiftData

@main
struct SecretSocietyHubApp: App {
    @StateObject private var session = SessionStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(session)
        }
        .modelContainer(for: FavoriteMember.self)
    }
}
