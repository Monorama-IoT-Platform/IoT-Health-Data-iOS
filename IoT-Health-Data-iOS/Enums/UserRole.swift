enum UserRole {
    case guest
    case hdUser
    case bothUser
    case unknown

    init(from roleString: String) {
        switch roleString {
        case "GUEST":
            self = .guest
        case "HD_USER":
            self = .hdUser
        case "BOTH_USER":
            self = .bothUser
        default:
            self = .unknown
        }
    }
}
