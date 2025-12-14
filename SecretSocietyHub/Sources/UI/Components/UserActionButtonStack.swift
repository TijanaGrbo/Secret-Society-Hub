import SwiftUI

struct UserActionButtonStack: View {
    let isFavorite: Bool
    let onCall: () -> Void
    let onLocation: () -> Void
    let onFavorite: () -> Void

    var body: some View {
        HStack(spacing: 40) {
            UserActionButton(type: .call, action: onCall)

            UserActionButton(type: .location, action: onLocation)

            UserActionButton(
                type: .favorite(isFavorite: isFavorite),
                action: onFavorite
            )
        }
        .padding(.top, 8)
    }
}

#Preview {
    UserActionButtonStack(
        isFavorite: true,
        onCall: {},
        onLocation: {},
        onFavorite: {},
    )
}
