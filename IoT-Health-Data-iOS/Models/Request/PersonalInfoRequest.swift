import Foundation

struct PersonalInfoRequest: Codable {
    let name: String
    let dateOfBirth: String // "yyyy-MM-dd"
    let gender: Gender
    let bloodType: BloodType
    let height: String
    let weight: String
    let email: String
    let nationalCode: NationalCode
    let phoneNumber: String
}
