import Foundation
import Combine
import SwiftData
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var users: [User] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let userService: UserService

    init(userService: UserService) {
        self.userService = userService
    }

    #if DEBUG
    /// Convenience initializer for previews and development.
    convenience init() {
        self.init(userService: MockUserService())
    }
    #endif

    func loadUsers(token: String?, favorites: [FavoriteMember]) async {
        guard let token, !token.isEmpty else {
            errorMessage = UserServiceError.unauthorized.description
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            var fetched = try await userService.fetchUsers(token: token)

            let favoriteIDs = Set(favorites.map(\.id))

            fetched = fetched.map { user in
                var copy = user
                copy.isFavorite = favoriteIDs.contains(user.id)
                return copy
            }

            self.users = fetched
            applySorting()
        } catch {
            if let userError = error as? UserServiceError {
                self.errorMessage = userError.description
            } else {
                self.errorMessage = error.localizedDescription
            }
        }

        isLoading = false
    }

    func syncFavorites(with favorites: [FavoriteMember]) {
        let favoriteIDs = Set(favorites.map(\.id))

        users = users.map { user in
            var copy = user
            copy.isFavorite = favoriteIDs.contains(user.id)
            return copy
        }

        applySorting()
    }

    func toggleFavorite(
        for user: User,
        modelContext: ModelContext,
        currentFavorites: [FavoriteMember]
    ) {
        withAnimation {
            if let fav = currentFavorites.first(where: { $0.id == user.id }) {
                modelContext.delete(fav)
            } else {
                let fav = FavoriteMember(id: user.id, fullName: user.fullName)
                modelContext.insert(fav)
            }

            if let index = users.firstIndex(where: { $0.id == user.id }) {
                users[index].isFavorite.toggle()
            }

            applySorting()
        }
    }

    private func applySorting() {
        users.sort { lhs, rhs in
            if lhs.isFavorite != rhs.isFavorite {
                return lhs.isFavorite && !rhs.isFavorite
            }

            return lhs.fullName
                .localizedCaseInsensitiveCompare(rhs.fullName) == .orderedAscending
        }
    }
}
