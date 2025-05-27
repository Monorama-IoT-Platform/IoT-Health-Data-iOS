enum NationalCode: String, Codable {
    case US
    case KR
    case UNKNOWN

    static func from(_ nationalCode: String) -> NationalCode {
        switch nationalCode {
        case "+1":
            return .US
        case "+82":
            return .KR
        default:
            return .UNKNOWN
        }
    }
}
