import Foundation

@MainActor
class AppState: ObservableObject {
    @Published var userRole: UserRole = .UNKNOWN
    @Published var isSignedIn: Bool = false

    private let tokenManager = TokenManager.shared
    private let authService = AuthService()

    func initialize() async {
        if let accessToken = tokenManager.readAccessToken() {
            print(accessToken)
            print(tokenManager.getUserRole())
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
            userRole = .GUEST
            isSignedIn = false
        }
    }

    func updateUserRole() {
        let role = tokenManager.getUserRole()
        userRole = role
        isSignedIn = (role != .UNKNOWN)
    }

    func logout() {
        try? tokenManager.deleteAccessToken()
        try? tokenManager.deleteRefreshToken()
        isSignedIn = false
    }
}
