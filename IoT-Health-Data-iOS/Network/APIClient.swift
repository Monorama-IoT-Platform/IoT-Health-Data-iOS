import Foundation

class APIClient {
    
    private let tokenManager = TokenManager()
    static let shared = APIClient()
    

    // ✅ 공통 JSON 인코딩 메서드
    func encodeBody<T: Encodable>(_ value: T) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(value)
    }

    // ✅ 공통 JSON 디코딩 메서드 (옵션)
    private func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    func request<T: Decodable>(
        _ endpoint: Endpoint,
        responseType: T.Type,
        body: Data? = nil
    ) async throws -> T {
        guard let url = endpoint.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = tokenManager.readAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            request.httpBody = body
        }

        let (data, _) = try await URLSession.shared.data(for: request)
        return try decoder().decode(T.self, from: data)
    }
}
