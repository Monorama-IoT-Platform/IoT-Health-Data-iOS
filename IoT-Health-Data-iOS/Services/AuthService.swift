import Foundation

struct AuthService {
    func loginWithApple(identityToken: String) async throws -> JwtResponse {
        let endpoint = Endpoint(
            path: "/api/v1/auth/login/apple",
            method: .POST,
            queryItems: nil
        )
        
        let body = try JSONSerialization.data(withJSONObject: ["identityToken": identityToken])
        
        // APIResponse<AuthResponse> 타입으로 요청
        let wrapper = try await APIClient.shared.request(endpoint, responseType: APIResponse<JwtResponse>.self, body: body)
        
        // 성공 여부 및 data 유무 체크 후 반환
        if wrapper.success, let jwt = wrapper.data {
            return jwt
        } else {
            // 에러 메시지 처리 (error가 nil일 수도 있으니 기본 메시지 지정)
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: wrapper.error ?? "Unknown error"])
        }
    }
    
    // 리프레시 토큰으로 액세스 토큰 갱신 API 호출
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
