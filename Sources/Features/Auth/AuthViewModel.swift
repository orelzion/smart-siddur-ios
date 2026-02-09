import Foundation
import Observation
import Auth

/// View model managing authentication state and operations.
@MainActor
@Observable
final class AuthViewModel {
    var isLoading = false
    var error: String?

    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    // MARK: - Auth Actions

    /// Sign in with Apple using identity token from ASAuthorization credential.
    func signInWithApple(idToken: String, fullName: String?) {
        performAuth {
            try await self.authRepository.signInWithApple(idToken: idToken, fullName: fullName)
        }
    }

    /// Sign in with Google via GIDSignIn SDK.
    func signInWithGoogle() {
        performAuth {
            try await self.authRepository.signInWithGoogle()
        }
    }

    /// Sign in anonymously (no credentials required).
    func signInAnonymously() {
        performAuth {
            try await self.authRepository.signInAnonymously()
        }
    }

    /// Sign out current user.
    func signOut() {
        performAuth {
            try await self.authRepository.signOut()
        }
    }

    // MARK: - Helpers

    /// The current user's display name, derived from Supabase user metadata.
    var displayName: String? {
        guard let user = authRepository.currentSession?.user else { return nil }
        // Check user_metadata for full_name (set during Apple sign-in)
        if let fullName = user.userMetadata["full_name"]?.stringValue, !fullName.isEmpty {
            return fullName
        }
        // Fall back to email
        return user.email
    }

    /// The current user's email.
    var userEmail: String? {
        authRepository.currentSession?.user.email
    }

    /// Whether the current session is anonymous.
    var isAnonymous: Bool {
        authRepository.currentSession?.user.isAnonymous ?? false
    }

    private func performAuth(_ action: @escaping @Sendable () async throws -> Void) {
        isLoading = true
        error = nil
        Task {
            do {
                try await action()
            } catch {
                self.error = error.localizedDescription
            }
            self.isLoading = false
        }
    }
}

// MARK: - AnyJSON String Helper

extension AnyJSON {
    var stringValue: String? {
        switch self {
        case .string(let value):
            return value
        default:
            return nil
        }
    }
}
