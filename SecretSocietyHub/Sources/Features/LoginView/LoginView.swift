import SwiftUI

struct LoginView: View {
    @EnvironmentObject var session: SessionStore

    @StateObject private var viewModel = LoginViewModel()

    // TODO: Clean up hardcoded values across the entire project
    // TODO: Test login failure cases, trim whitespaces, and add basic input validation
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Secret Society Hub")
                        .font(.largeTitle.bold())
                    Text("Identify yourself, initiate handshake.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 12)

                VStack(spacing: 16) {
                    TextField("Username", text: $viewModel.username)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 26, style: .continuous)
                                .fill(Color(.secondarySystemBackground))
                        )

                    SecureField("Password", text: $viewModel.password)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 26, style: .continuous)
                                .fill(Color(.secondarySystemBackground))
                        )
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button {
                    Task {
                        if let token = await viewModel.login() {
                            session.setToken(token)
                        }
                    }
                } label: {
                    ZStack {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Login")
                                .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .disabled(!viewModel.canSubmit)
                .opacity(viewModel.canSubmit ? 1 : 0.6)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
        }
    }
}

#Preview {
    let session = SessionStore()
    return LoginView()
        .environmentObject(session)
}
