enum BloodType {
    case A_PLUS
    case A_MINUS
    case B_PLUS
    case B_MINUS
    case O_PLUS
    case O_MINUS
    case AB_PLUS
    case AB_MINUS
    case UNKNOWN

    init(from bloodType: String) {
        switch bloodType {
        case "A+":
            self = .A_PLUS
        case "A-":
            self = .A_MINUS
        case "B+":
            self = .B_PLUS
        case "B-":
            self = .B_MINUS
        case "O+":
            self = .O_PLUS
        case "O-":
            self = .O_MINUS
        case "AB+":
            self = .AB_PLUS
        case "AB-":
            self = .A_MINUS
        case "Unknown":
            self = .UNKNOWN
        default:
            self = .UNKNOWN
        }
    }
}