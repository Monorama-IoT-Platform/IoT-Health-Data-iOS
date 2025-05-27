enum AgreementType: Identifiable {
    case privacyPolicy, termsOfService, healthData, locationData

    var id: Int { hashValue }

    var title: String {
        switch self {
        case .privacyPolicy: return "Privacy Policy"
        case .termsOfService: return "Terms of Service"
        case .healthData: return "Health Data Consent"
        case .locationData: return "Location Data Terms"
        }
    }

    var content: String {
        switch self {
        case .privacyPolicy: return "여기에 Privacy Policy 자세한 내용을 작성하세요..."
        case .termsOfService: return "여기에 Terms of Service 자세한 내용을 작성하세요..."
        case .healthData: return "여기에 Health Data Consent 자세한 내용을 작성하세요..."
        case .locationData: return "여기에 Location Data Terms 자세한 내용을 작성하세요..."
        }
    }
}