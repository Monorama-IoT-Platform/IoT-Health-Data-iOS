import Foundation

struct ProjectService {
    
    func getProjectList() async throws -> [ProjectSimpleResponse] {
        let endpoint = Endpoint(
            path: "/api/v1/health-data/projects",
            method: .GET,
            queryItems: nil
        )

        let body = try APIClient.shared.encodeBody(nil as EmptyRequest?)

        let wrapper = try await APIClient.shared.request(
            endpoint,
            responseType: APIResponse<ProjectListResponse>.self,
            body: body
        )

        if wrapper.success, let data = wrapper.data {
            return data.projectList
        } else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: wrapper.error ?? "Unknown error"])
        }
    }
    
    func registProject(projectId: Int64) async throws -> Bool {
        let endpoint = Endpoint(
            path: "/api/v1/health-data/projects/\(projectId)/participation",
            method: .POST,
            queryItems: nil
        )

        let body = try APIClient.shared.encodeBody(nil as EmptyRequest?)

        let wrapper = try await APIClient.shared.request(
            endpoint,
            responseType: APIResponse<EmptyResponse>.self,
            body: body
        )

        if wrapper.success {
            return true
        } else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: wrapper.error ?? "Unknown error"])
        }
    }
    
    func getProjectInfo(projectId: Int64) async throws -> InfoResponse {
        let endpoint = Endpoint(
            path: "/api/v1/health-data/projects/\(projectId)",
            method: .GET,
            queryItems: nil
        )

        let body = try APIClient.shared.encodeBody(nil as EmptyRequest?)

        let wrapper = try await APIClient.shared.request(
            endpoint,
            responseType: APIResponse<InfoResponse>.self,
            body: body
        )

        if wrapper.success, let info = wrapper.data {
            return info
        } else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: wrapper.error ?? "Unknown error"])
        }
    }
}
