import SwiftUI
import AuthenticationServices
import GoogleSignInSwift

/// Full-screen login view with Apple, Google, and Anonymous auth options.
/// Redesigned with dark/gold glassmorphism theme and spring animations.
struct LoginView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: AuthViewModel?
    @State private var showError = false
    @State private var scaleAnimation: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Background gradient - dark/gold theme
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.06, green: 0.09, blue: 0.16),  // #0f172a
                    Color(red: 0.01, green: 0.02, blue: 0.04)   // #020617
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // App logo and title with gold gradient
                VStack(spacing: 12) {
                    Image(systemName: "book.fill")
                        .font(.system(size: 72))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 1.0, blue: 1.0),
                                    Color(red: 0.85, green: 0.73, blue: 0.27)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("SmartSiddur")
                        .font(.largeTitle.bold())
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white,
                                    Color(red: 0.85, green: 0.73, blue: 0.27)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("Your personal siddur")
                        .font(.subheadline)
                        .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
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
                    .scaleEffect(scaleAnimation)
                    .onTapGesture {
                        springAnimation()
                        hapticFeedback()
                    }

                    // Sign in with Google
                    Button {
                        springAnimation()
                        hapticFeedback()
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
                        .background(Color(red: 0.11, green: 0.13, blue: 0.20))
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 0.20, green: 0.22, blue: 0.31), lineWidth: 1)
                        )
                    }

                    // Anonymous / Continue without account
                    Button {
                        springAnimation()
                        hapticFeedback()
                        viewModel?.signInAnonymously()
                    } label: {
                        Text("Continue without account")
                            .font(.subheadline)
                            .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))
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
                    .tint(Color(red: 0.85, green: 0.73, blue: 0.27))
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

    private func springAnimation() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            scaleAnimation = 0.95
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7).delay(0.1)) {
            scaleAnimation = 1.0
        }
    }

    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}
