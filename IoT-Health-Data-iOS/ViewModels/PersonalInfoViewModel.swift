import Foundation
import SwiftUI

@MainActor
class PersonalInfoViewModel: ObservableObject {
    private let personalInfoService = PersonalInfoService()
    private let tokenManager = TokenManager()
    private let appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }
    
    // 사용자 입력 상태
    @Published var name = ""
    @Published var birthDate = Date()
    @Published var gender = "Male"
    @Published var bloodType = "A+"
    @Published var height = ""
    @Published var weight = ""
    @Published var emailId = ""
    @Published var emailDomain = "@gmail.com"
    @Published var nationalCode = "+82"
    @Published var phoneNumber = ""

    // 로딩 및 에러 상태
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isSignedIn = false
    @Published var userRole: UserRole = .unknown

    var getEmail: String {
        emailId + emailDomain
    }

    var allRequiredFilled: Bool {
        !name.isEmpty &&
        !height.isEmpty &&
        !weight.isEmpty &&
        !emailId.isEmpty &&
        !phoneNumber.isEmpty
    }

    func register() async {
        isLoading = true
        errorMessage = nil
        print(birthDate)

        let info = PersonalInfoRequest(
            name: name,
            dateOfBirth: birthDate.toYYYYMMdd(),
            gender: gender,
            bloodType: bloodType,
            height: height,
            weight: weight,
            email: getEmail,
            nationalCode: nationalCode,
            phoneNumber: phoneNumber
        )

        do {
            let jwt = try await personalInfoService.regist(personalInfo: info)
            
            try? tokenManager.saveJwtToken(jwt)
            appState.updateUserRole()
            
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
    
    
}
