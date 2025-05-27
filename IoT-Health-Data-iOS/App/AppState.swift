import Foundation

@MainActor
class AppState: ObservableObject {
    @Published var userRole: UserRole = .unknown
    @Published var isSignedIn: Bool = false

    private let tokenManager = TokenManager()
    private let authService = AuthService()

    func initialize() async {
        if let accessToken = tokenManager.readAccessToken() {
            print(accessToken)
            if tokenManager.isTokenExpired(accessToken) {
                if let refreshToken = tokenManager.readRefreshToken() {
                    do {
                        let newJwt = try await authService.refresh(refreshToken: refreshToken)
                        try tokenManager.saveJwtToken(newJwt)
                        updateUserRole()
                    } catch {
                        logout()
                    }
                } else {
                    logout()
                }
            } else {
                updateUserRole()
            }
        } else {
            userRole = .guest
            isSignedIn = false
        }
    }

    func updateUserRole() {
        let role = tokenManager.getUserRole()
        userRole = role
        isSignedIn = (role != .unknown) // ✅ guest도 로그인한 상태로 간주
    }

    func logout() {
        try? tokenManager.deleteAccessToken()
        try? tokenManager.deleteRefreshToken()
        userRole = .guest
        isSignedIn = false
    }


}
