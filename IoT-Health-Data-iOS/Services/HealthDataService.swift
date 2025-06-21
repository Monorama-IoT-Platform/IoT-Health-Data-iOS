import Foundation

struct HealthDataService {
    func uploadHealthData(_ request: HealthDataRequest) async throws {
        let endpoint = Endpoint(
            path: "/api/v1/health-data/realtime",
            method: .POST,
            queryItems: nil
        )

        let body = try APIClient.shared.encodeBody(request)

        let wrapper = try await APIClient.shared.request(
            endpoint,
            responseType: APIResponse<EmptyResponse>.self,
            body: body
        )

        if !wrapper.success {
            throw NSError(
                domain: "",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: wrapper.error ?? "Unknown error occurred"]
            )
        }
    }
}
