import Foundation

struct Endpoint {
    
    let path: String
    let method: HTTPMethod
    let queryItems: [URLQueryItem]?

    var url: URL? {
        var components = URLComponents(string: APIConstants.baseURL)
        components?.path += path
        components?.queryItems = queryItems
        return components?.url
    }
}
