enum UserRole {
    case GUEST
    case HD_USER
    case AQD_USER
    case BOTH_USER
    case UNKNOWN

    init(from roleString: String) {
        switch roleString {
        case "GUEST":
            self = .GUEST
        case "HD_USER":
            self = .HD_USER
        case "AQD_USER":
            self = .AQD_USER
        case "BOTH_USER":
            self = .BOTH_USER
        default:
            self = .UNKNOWN
        }
    }
}
