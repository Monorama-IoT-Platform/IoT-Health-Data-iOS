struct ProjectSimpleResponse: Identifiable, Codable, Hashable  {
    let projectId: Int64
    let projectTitle: String
    
    let termsOfPolicy: String
    let privacyPolicy: String
    let healthDataConsent: String
    let localDataTermsOfService: String
    let airDataConsent: String
    var id: Int64 { projectId }
}
