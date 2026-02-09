import Foundation
import Auth
import Supabase
import GoogleSignIn
import UIKit

// MARK: - Custom Auth Error

enum SmartSiddurAuthError: LocalizedError {
    case missingRootViewController
    case missingGoogleIdToken
    case missingAppleIdToken

    var errorDescription: String? {
        switch self {
        case .missingRootViewController:
            "Unable to find root view controller for Google Sign-In"
        case .missingGoogleIdToken:
            "Google Sign-In did not return an ID token"
        case .missingAppleIdToken:
            "Apple Sign-In did not return an identity token"
        }
    }
}

// MARK: - Protocol

/// Protocol defining authentication operations.
protocol AuthRepositoryProtocol: Sendable {
    /// Sign in with Apple using identity token from ASAuthorization.
    func signInWithApple(idToken: String, fullName: String?) async throws
    /// Sign in with Google using GIDSignIn SDK flow.
    @MainActor func signInWithGoogle() async throws
    /// Create an anonymous session (no credentials required).
    func signInAnonymously() async throws
    /// Sign out the current user.
    func signOut() async throws
    /// Returns the current session if one exists (may be expired).
    var currentSession: Session? { get }
    /// Async stream of auth state changes.
    var authStateChanges: AsyncStream<(event: AuthChangeEvent, session: Session?)> { get }
}

// MARK: - Implementation

/// Concrete implementation wrapping Supabase Auth + Google Sign-In SDK.
final class AuthRepository: AuthRepositoryProtocol, @unchecked Sendable {
    private let supabase: SupabaseClient

    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }

    var currentSession: Session? {
        supabase.auth.currentSession
    }

    var authStateChanges: AsyncStream<(event: AuthChangeEvent, session: Session?)> {
        supabase.auth.authStateChanges
    }

    func signInWithApple(idToken: String, fullName: String?) async throws {
        try await supabase.auth.signInWithIdToken(
            credentials: .init(
                provider: .apple,
                idToken: idToken
            )
        )

        // fullName is only provided on first sign-in (account creation),
        // so only update if non-nil to avoid erasing data on subsequent logins.
        if let fullName {
            try? await supabase.auth.update(
                user: UserAttributes(
                    data: ["full_name": .string(fullName)]
                )
            )
        }
    }

    @MainActor
    func signInWithGoogle() async throws {
        guard let rootViewController = UIApplication.shared
            .connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .filter({ $0.activationState == .foregroundActive })
            .first?.keyWindow?.rootViewController
        else {
            throw SmartSiddurAuthError.missingRootViewController
        }

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)

        guard let idToken = result.user.idToken?.tokenString else {
            throw SmartSiddurAuthError.missingGoogleIdToken
        }

        try await supabase.auth.signInWithIdToken(
            credentials: OpenIDConnectCredentials(
                provider: .google,
                idToken: idToken
            )
        )
    }

    func signInAnonymously() async throws {
        try await supabase.auth.signInAnonymously()
    }

    func signOut() async throws {
        try await supabase.auth.signOut()
    }
}
