enum BloodType: String, Codable {
    case A_PLUS
    case A_MINUS
    case B_PLUS
    case B_MINUS
    case O_PLUS
    case O_MINUS
    case AB_PLUS
    case AB_MINUS
    case UNKNOWN

    static func from(_ bloodType: String) -> BloodType {
        switch bloodType {
        case "A+":
            return .A_PLUS
        case "A-":
            return .A_MINUS
        case "B+":
            return .B_PLUS
        case "B-":
            return .B_MINUS
        case "O+":
            return .O_PLUS
        case "O-":
            return .O_MINUS
        case "AB+":
            return .AB_PLUS
        case "AB-":
            return .A_MINUS
        case "Unknown":
            return .UNKNOWN
        default:
            return .UNKNOWN
        }
    }
}
