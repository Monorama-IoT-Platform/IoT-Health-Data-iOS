import Foundation
import Combine

@MainActor
class BothUserViewModel: ObservableObject {
    private let bothUserService = BothUserService()
    private let tokenManager = TokenManager.shared
    private let appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

    @Published var isLoading = false
    @Published var errorMessage: String?

    func updateToBothUser() async {
        isLoading = true
        errorMessage = nil

        do {
            let jwt = try await bothUserService.updateToBothUser()

            try? tokenManager.saveJwtToken(jwt)
            appState.updateUserRole()
            
        } catch {
            errorMessage = "로그인 실패: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
