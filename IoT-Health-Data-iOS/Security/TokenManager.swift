import KeychainAccess
import Foundation

class TokenManager {
    
    private let keychain = Keychain(service: "com.monorama.auth")
    
    // MARK: - Access Token
    func saveJwtToken(_ jwt: JwtResponse) throws {
        try keychain.set(jwt.accessToken, key: "accessToken")
        try keychain.set(jwt.refreshToken, key: "refreshToken")
    }

    // MARK: - Access Token
    
    func saveAccessToken(_ token: String) throws {
        try keychain.set(token, key: "accessToken")
    }

    func readAccessToken() -> String? {
        return try? keychain.get("accessToken")
    }

    func deleteAccessToken() throws {
        try keychain.remove("accessToken")
    }

    // MARK: - Refresh Token

    func saveRefreshToken(_ token: String) throws {
        try keychain.set(token, key: "refreshToken")
    }

    func readRefreshToken() -> String? {
        return try? keychain.get("refreshToken")
    }

    func deleteRefreshToken() throws {
        try keychain.remove("refreshToken")
    }
    
    // MARK: - 토큰 만료 검사
    func isTokenExpired(_ token: String) -> Bool {
        let segments = token.split(separator: ".")
        guard segments.count == 3 else { return true }

        let payloadSegment = segments[1]
        var base64 = String(payloadSegment)
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let paddedLength = base64.count + (4 - (base64.count % 4)) % 4
        base64 = base64.padding(toLength: paddedLength, withPad: "=", startingAt: 0)

        guard let payloadData = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any],
              let exp = json["exp"] as? TimeInterval else {
            return true
        }

        let expirationDate = Date(timeIntervalSince1970: exp)
        return expirationDate <= Date()
    }

    // MARK: - JWT Role 추출

    func getRole(from jwtToken: String) -> String? {
        let segments = jwtToken.split(separator: ".")
        guard segments.count == 3 else { return nil }

        let payloadSegment = segments[1]
        var base64 = String(payloadSegment)
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let paddedLength = base64.count + (4 - (base64.count % 4)) % 4
        base64 = base64.padding(toLength: paddedLength, withPad: "=", startingAt: 0)

        guard let payloadData = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any],
              let role = json["rol"] as? String else {
            return nil
        }

        return role
    }
    
    func getUserRole() -> UserRole {
        guard let accessToken = readAccessToken() else {
            return .unknown
        }

        guard let role = getRole(from: accessToken) else {
            return .unknown
        }

        switch role {
        case "GUEST":
            return .guest
        case "HD_USER":
            return .hdUser
        case "BOTH":
            return .bothUser
        default:
            return .unknown
        }
    }
    
    func logout() {
        do {
            try deleteAccessToken()
            try deleteRefreshToken()
            // 로그아웃 후 추가 처리 (예: 로그인 화면 이동)
        } catch {
            print("토큰 삭제 실패: \(error)")
        }
    }
}

