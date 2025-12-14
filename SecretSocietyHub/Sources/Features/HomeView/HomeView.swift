import SwiftUI
import SwiftData

struct HomeView: View {
    @EnvironmentObject var session: SessionStore

    @Environment(\.modelContext) private var modelContext

    @Query(sort: [SortDescriptor(\FavoriteMember.createdAt, order: .forward)])

    private var favorites: [FavoriteMember]

    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading members...")
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Text(errorMessage)
                        Button("Retry") {
                            Task {
                                await viewModel.loadUsers(
                                    token: session.authToken,
                                    favorites: favorites
                                )
                            }
                        }
                        .padding(16)
                    }
                } else {
                    List(viewModel.users) { user in
                        NavigationLink {
                            UserDetailView(
                                user: user,
                                onToggleFavorite: {
                                    viewModel.toggleFavorite(
                                        for: user,
                                        modelContext: modelContext,
                                        currentFavorites: favorites
                                    )
                                }
                            )
                        } label: {
                            MemberRowView(
                                user: user,
                                onToggleFavorite: {
                                    viewModel.toggleFavorite(
                                        for: user,
                                        modelContext: modelContext,
                                        currentFavorites: favorites
                                    )
                                }
                            )
                        }
                    }
                }
            }
            .navigationTitle("Members")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Logout") {
                        session.setToken(nil)
                    }
                }
            }
            .task {
                await viewModel.loadUsers(
                    token: session.authToken,
                    favorites: favorites
                )
            }
            .onChange(of: favorites) { _, newValue in
                viewModel.syncFavorites(with: newValue)
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(SessionStore.preview())
        .modelContainer(for: FavoriteMember.self, inMemory: true)
}
