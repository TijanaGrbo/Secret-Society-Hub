import SwiftUI

enum UserActionButtonType {
    case call
    case location
    case favorite(isFavorite: Bool)

    var systemImageName: String {
        switch self {
        case .call:
            return "phone.fill"

        case .location:
            return "mappin.and.ellipse"

        case .favorite(let isFavorite):
            return isFavorite ? "star.fill" : "star"
        }
    }

    var tintColor: Color {
        switch self {
        case .call,
            .location:
            return .primary

        case .favorite(let isFavorite):
            return isFavorite ? .yellow : .primary
        }
    }
}

struct UserActionButton: View {
    let type: UserActionButtonType
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: type.systemImageName)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(type.tintColor)
                .frame(width: 48, height: 48)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(radius: 0, y: 0)
        }
    }
}

#Preview {
    UserActionButton(
        type: .location,
        action: {}
    )
}
