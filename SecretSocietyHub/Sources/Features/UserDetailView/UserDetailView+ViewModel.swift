import Foundation
import Combine

final class UserDetailViewModel: ObservableObject {
    let user: User
    @Published var isFavorite: Bool

    private let onToggleFavorite: () -> Void

    private let isoFormatter: ISO8601DateFormatter
    private let birthdateFormatter: DateFormatter

    init(user: User, isFavorite: Bool, onToggleFavorite: @escaping () -> Void) {
        self.user = user
        self.isFavorite = isFavorite
        self.onToggleFavorite = onToggleFavorite

        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        iso.timeZone = TimeZone(secondsFromGMT: 0)
        self.isoFormatter = iso

        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        df.locale = Locale.current
        self.birthdateFormatter = df
    }

    // MARK: - Display helpers

    var formattedTimezone: String {
        "UTC \(user.location.timezone.offset) (\(user.location.timezone.description))"
    }

    var formattedBirthdateWithAge: String {
        if let date = isoFormatter.date(from: user.dob.date) {
            let formatted = birthdateFormatter.string(from: date)
            return "\(formatted) (\(user.dob.age) years)"
        } else {
            return "\(user.dob.date) (\(user.dob.age) years)"
        }
    }

    // MARK: - URLs for actions

    func callURL() -> URL? {
        let digits = user.phone.filter(\.isNumber)
        guard !digits.isEmpty else { return nil }
        return URL(string: "tel://\(digits)")
    }

    func mapsURL() -> URL? {
        let lat = user.location.coordinates.latitude.trimmingCharacters(in: .whitespacesAndNewlines)
        let lon = user.location.coordinates.longitude.trimmingCharacters(in: .whitespacesAndNewlines)
        let coordString = "\(lat),\(lon)"

        var components = URLComponents(string: "https://maps.apple.com")
        components?.queryItems = [
            URLQueryItem(name: "ll", value: coordString),
            URLQueryItem(name: "q", value: coordString)
        ]

        return components?.url
    }

    // MARK: - Favorite

    func toggleFavorite() {
        isFavorite.toggle()
        onToggleFavorite()
    }
}
