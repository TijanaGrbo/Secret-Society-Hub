import SwiftUI
import SwiftData

struct UserDetailView: View {
    @StateObject private var viewModel: UserDetailViewModel
    @Environment(\.openURL) private var openURL

    init(user: User, onToggleFavorite: @escaping () -> Void) {
        _viewModel = StateObject(
            wrappedValue: UserDetailViewModel(
                user: user,
                isFavorite: user.isFavorite,
                onToggleFavorite: onToggleFavorite
            )
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                AvatarView(
                    url: viewModel.user.detailsAvatarImage,
                    size: 120
                )
                .padding(.top, 24)

                Text(viewModel.user.fullName)
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(viewModel.user.cityAndCountry)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                UserActionButtonStack(
                    isFavorite: viewModel.isFavorite,
                    onCall: {
                        if let url = viewModel.callURL() { openURL(url) }
                    },
                    onLocation: {
                        if let url = viewModel.mapsURL() { openURL(url) }
                    },
                    onFavorite: {
                        viewModel.toggleFavorite()
                    }
                )
                .padding(.top, 8)

                Divider()
                    .padding(.vertical, 16)

                detailsSection
                
            }
            .padding(.horizontal)
        }
        .navigationTitle("Contact")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Details

    // TODO: Refactor detailsSection and detailRow
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            detailRow(title: "Email", value: viewModel.user.email)
            detailRow(title: "Phone", value: viewModel.user.phone)
            detailRow(
                title: "Address",
                value: "\(viewModel.user.location.street.name) \(viewModel.user.location.street.number), \(viewModel.user.location.city)"
            )
            detailRow(
                title: "Date of birth",
                value: viewModel.formattedBirthdateWithAge
            )
            detailRow(
                title: "Timezone",
                value: viewModel.formattedTimezone
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func detailRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.body)
        }
    }
}
