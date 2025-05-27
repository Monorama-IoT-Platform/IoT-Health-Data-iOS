import Foundation

struct PersonalInfoService {
    func regist(personalInfo: PersonalInfoRequest) async throws -> JwtResponse {
        let endpoint = Endpoint(
            path: "/api/v1/auth/register/health-data",
            method: .PATCH,
            queryItems: nil
        )

        let body = try APIClient.shared.encodeBody(personalInfo)

        let wrapper = try await APIClient.shared.request(
            endpoint,
            responseType: APIResponse<JwtResponse>.self,
            body: body
        )

        if wrapper.success, let jwt = wrapper.data {
            return jwt
        } else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: wrapper.error ?? "Unknown error"])
        }
    }
}
