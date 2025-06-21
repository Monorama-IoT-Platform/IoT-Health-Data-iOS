import Foundation

@MainActor
class AppState: ObservableObject {
    @Published var userRole: UserRole = .UNKNOWN
    @Published var isSignedIn: Bool = false
    
    @Published var registeredProjectId: Int64?

    private let tokenManager = TokenManager.shared
    private let authService = AuthService()

    func initialize() async {
        
        if let accessToken = tokenManager.readAccessToken() {
            
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

        if let savedId = UserDefaults.standard.object(forKey: "registeredProjectId") as? Int64 {
            self.registeredProjectId = savedId
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
        
        // userRole = .UNKNOWN
        // ✅ 로그아웃 시 프로젝트 ID 초기화
         registeredProjectId = nil
         UserDefaults.standard.removeObject(forKey: "registeredProjectId")
    }
}
