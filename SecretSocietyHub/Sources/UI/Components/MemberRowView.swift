import SwiftUI

struct MemberRowView: View {
    let user: User
    let onToggleFavorite: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            AvatarView(
                url: user.rowAvatarImage,
                size: 44
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(user.fullName)
                    .font(.body)
                Text(user.cityAndCountry)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: onToggleFavorite) {
                Image(systemName: user.isFavorite ? "star.fill" : "star")
                    .foregroundStyle(user.isFavorite ? .yellow : .gray)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}
