import SwiftUI

/// Home view displaying user info and sign-out button.
/// Proves auth is working and shows authenticated state.
struct HomeView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: AuthViewModel?

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue)

            if let viewModel {
                if viewModel.isAnonymous {
                    Text("Anonymous User")
                        .font(.title2.bold())
                    Text("You are using the app without an account")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                } else {
                    Text(viewModel.displayName ?? "User")
                        .font(.title2.bold())
                    if let email = viewModel.userEmail {
                        Text(email)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            Button(role: .destructive) {
                viewModel?.signOut()
            } label: {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Sign Out")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 24)
        }
        .onAppear {
            if viewModel == nil {
                viewModel = AuthViewModel(authRepository: container.authRepository)
            }
        }
    }
}
