struct ProjectSimpleResponse: Identifiable, Codable, Hashable  {
    let projectId: Int64
    let projectTitle: String
    
    var id: Int64 { projectId }
}
