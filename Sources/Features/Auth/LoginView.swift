import SwiftUI
import AuthenticationServices
import GoogleSignInSwift

/// Full-screen login view with Apple, Google, and Anonymous auth options.
struct LoginView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: AuthViewModel?
    @State private var showError = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [.blue.opacity(0.1), .white],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // App logo and title
                VStack(spacing: 12) {
                    Image(systemName: "book.fill")
                        .font(.system(size: 72))
                        .foregroundStyle(.blue)

                    Text("SmartSiddur")
                        .font(.largeTitle.bold())

                    Text("Your personal siddur")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Auth buttons
                VStack(spacing: 16) {
                    // Sign in with Apple
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.email, .fullName]
                    } onCompletion: { result in
                        handleAppleSignIn(result)
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)
                    .cornerRadius(12)

                    // Sign in with Google
                    Button {
                        viewModel?.signInWithGoogle()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "g.circle.fill")
                                .font(.title2)
                            Text("Sign in with Google")
                                .font(.body.weight(.medium))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(.systemBackground))
                        .foregroundStyle(.primary)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.separator), lineWidth: 1)
                        )
                    }

                    // Anonymous / Continue without account
                    Button {
                        viewModel?.signInAnonymously()
                    } label: {
                        Text("Continue without account")
                            .font(.subheadline)
                            .foregroundStyle(.blue)
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 32)
                .disabled(viewModel?.isLoading ?? false)

                Spacer()
                    .frame(height: 40)
            }

            // Loading overlay
            if viewModel?.isLoading ?? false {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = AuthViewModel(authRepository: container.authRepository)
            }
        }
        .alert("Sign-In Error", isPresented: $showError) {
            Button("OK") {
                viewModel?.error = nil
            }
        } message: {
            Text(viewModel?.error ?? "An unknown error occurred")
        }
        .onChange(of: viewModel?.error) { _, newValue in
            showError = newValue != nil
        }
    }

    // MARK: - Apple Sign-In Handler

    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                viewModel?.error = "Invalid Apple credential type"
                showError = true
                return
            }

            guard let identityTokenData = credential.identityToken,
                  let idToken = String(data: identityTokenData, encoding: .utf8) else {
                viewModel?.error = "Apple Sign-In did not return an identity token"
                showError = true
                return
            }

            let fullName = credential.fullName.flatMap { name in
                PersonNameComponentsFormatter.localizedString(from: name, style: .default)
            }
            let cleanedName = fullName?.isEmpty == true ? nil : fullName

            viewModel?.signInWithApple(idToken: idToken, fullName: cleanedName)

        case .failure(let error):
            // ASAuthorizationError.canceled is expected when user dismisses
            if (error as? ASAuthorizationError)?.code == .canceled {
                return
            }
            viewModel?.error = error.localizedDescription
            showError = true
        }
    }
}
