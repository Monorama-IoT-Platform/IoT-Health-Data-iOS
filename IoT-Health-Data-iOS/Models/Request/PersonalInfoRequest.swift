import Foundation

struct PersonalInfoRequest: Codable {
    let name: String
    let dateOfBirth: String // "yyyy-MM-dd"
    let gender: String
    let bloodType: String
    let height: String
    let weight: String
    let email: String
    let nationalCode: String
    let phoneNumber: String
}
