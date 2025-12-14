import Foundation
import SwiftData

/// Represents a user that has been marked as a favorite within the app.
/// Stored locally using SwiftData so the favorite list persists across app launches.
///
/// This model exists because the backend doesn't provide favorite status,
/// so the client must maintain this state locally.
@Model
final class FavoriteMember {
    /// Unique identifier for the user. Matches the user's email from the API.
    /// Marked as `.unique` to ensure a user cannot be favorited more than once.
    @Attribute(.unique) var id: String

    var fullName: String

    /// Timestamp indicating when the user was added to favorites.
    /// Defaults to the current time when creating a new favorite entry.
    var createdAt: Date

    init(id: String, fullName: String, createdAt: Date = .now) {
        self.id = id
        self.fullName = fullName
        self.createdAt = createdAt
    }
}
