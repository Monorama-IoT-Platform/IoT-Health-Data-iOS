import Foundation

struct AuthService {
    
    func loginWithApple(identityToken: String) async throws -> JwtResponse {
        let endpoint = Endpoint(
            path: "/api/v1/auth/login/apple",
            method: .POST,
            queryItems: nil
        )
        
        let body = try JSONSerialization.data(withJSONObject: ["identityToken": identityToken])
        
        let wrapper = try await APIClient.shared.request(
            endpoint,
            responseType: APIResponse<JwtResponse>.self,
            body: body)
    
        if wrapper.success, let jwt = wrapper.data {
            return jwt
        } else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: wrapper.error ?? "Unknown error"])
        }
    }
    
    func refresh(refreshToken: String) async throws -> JwtResponse {
        let endpoint = Endpoint(
            path: "/api/v1/auth/token/refresh",
            method: .POST,
            queryItems: nil
        )
        
        let body = try JSONSerialization.data(withJSONObject: ["refreshToken": refreshToken])
            
        let response = try await APIClient.shared.request(
            endpoint,
            responseType: APIResponse<JwtResponse>.self,
            body: body
        )
            
        if response.success, let jwt = response.data {
            return jwt
        } else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: response.error ?? "Unknown error"])
        }
    }
}
