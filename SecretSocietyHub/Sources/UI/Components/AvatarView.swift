import SwiftUI

struct AvatarView: View {
    let url: URL?
    let size: CGFloat

    var body: some View {
        Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: size, height: size)

                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: size, height: size)
                            .clipShape(Circle())

                    case .failure:
                        fallbackImage

                    @unknown default:
                        fallbackImage
                    }
                }
            } else {
                fallbackImage
            }
        }
    }

    private var fallbackImage: some View {
        Image(systemName: "person.crop.circle.fill")
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .foregroundStyle(.gray.opacity(0.5))
    }
}

#Preview("Image") {
    AvatarView(
        url: URL(string: "https://randomuser.me/api/portraits/thumb/men/21.jpg"),
        size: 44
    )
}

#Preview("Image is nil") {
    AvatarView(
        url: nil,
        size: 44
    )
}
