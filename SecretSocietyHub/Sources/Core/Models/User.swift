import Foundation

struct UsersResponse: Codable {
    let data: [User]
}

struct User: Codable, Identifiable, Equatable {
    /// Uses the email as a stable unique identifier.
    /// The API does not provide a dedicated ID field.
    var id: String { email }

    let name: Name
    let location: Location
    let email: String
    let dob: DOB
    let phone: String
    let picture: Picture

    /// Ideally, this field *should* exist in the backend response:
    /// - It would keep favorite status consistent across devices
    /// - It would eliminate the need for local persistence and syncing
    /// - It would simplify the ViewModel and reduce client-side logic
    ///
    /// Intentionally excluded from Codable via `CodingKeys`.
    var isFavorite: Bool = false

    var fullName: String {
        "\(name.first) \(name.last)"
    }

    var cityAndCountry: String {
        "\(location.city), \(location.country)"
    }

    var rowAvatarImage: URL {
        picture.medium
    }

    var detailsAvatarImage: URL {
        picture.large
    }

    enum CodingKeys: String, CodingKey {
        case name, location, email, dob, phone, picture
    }

    static func ==(lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}

struct Name: Codable {
    let title: String
    let first: String
    let last: String
}

/// The API is inconsistent: `postcode` may be an Int or a String.
/// `FlexiblePostcode` normalizes this into a single String.
struct Location: Codable {
    let street: Street
    let city: String
    let state: String
    let country: String
    let postcode: String
    let coordinates: Coordinates
    let timezone: Timezone

    /// Custom initializer required because `postcode`
    /// cannot be decoded reliably using standard Codable.
    init(from decoder: Decoder) throws {
        let raw = try RawLocation(from: decoder)

        street = raw.street
        city = raw.city
        state = raw.state
        country = raw.country
        coordinates = raw.coordinates
        timezone = raw.timezone
        postcode = raw.postcode.value
    }

    private struct RawLocation: Decodable {
        let street: Street
        let city: String
        let state: String
        let country: String
        let postcode: FlexiblePostcode
        let coordinates: Coordinates
        let timezone: Timezone
    }
}

struct Street: Codable {
    let number: Int
    let name: String
}

struct Coordinates: Codable {
    let latitude: String
    let longitude: String
}

struct Timezone: Codable {
    let offset: String
    let description: String
}

struct DOB: Codable {
    let date: String
    let age: Int
}

struct Picture: Codable {
    let large: URL
    let medium: URL
    let thumbnail: URL
}

/// Flexible decoder for `postcode`, which may be either
/// Int (e.g. `21000`) or String (e.g. `"21000"`).
/// Always exposes a normalized string value.
struct FlexiblePostcode: Decodable {
    let value: String

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let intValue = try? container.decode(Int.self) {
            value = String(intValue)
        } else {
            value = try container.decode(String.self)
        }
    }
}
