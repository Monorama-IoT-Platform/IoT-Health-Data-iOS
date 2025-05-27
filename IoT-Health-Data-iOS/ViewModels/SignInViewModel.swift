import Foundation
import Combine

@MainActor
class SignInViewModel: ObservableObject {
    private let authService = AuthService()
    private let tokenManager = TokenManager.shared
    private let appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

    @Published var isLoading = false
    @Published var errorMessage: String?

    func signInWithApple(token: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let jwt = try await authService.loginWithApple(identityToken: token)

            try? tokenManager.saveJwtToken(jwt)
            appState.updateUserRole()
        } catch {
            errorMessage = "로그인 실패: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
