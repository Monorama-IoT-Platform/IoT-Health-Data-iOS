enum Gender: String, Codable {
    case MALE
    case FEMALE
    case OTHER
    case UNKNOWN
    
    var id: String { self.rawValue }

    static func from(_ gender: String) -> Gender {
        switch gender {
        case "Male":
            return .MALE
        case "Female":
            return .FEMALE
        case "Other":
            return .OTHER
        default:
            return .UNKNOWN
        }
    }
}
