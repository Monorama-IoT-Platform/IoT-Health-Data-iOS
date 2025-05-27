import SwiftUI

struct PersonalInfoInputView: View {
    
    @StateObject var viewModel: PersonalInfoViewModel
    @ObservedObject var appState: AppState

    let agreePrivacyPolicy: Bool
    let agreeTermsOfService: Bool
    let agreeConsentOfHealthData: Bool
    let agreeLocationDataTermsOfService: Bool
    
    init(
        appState: AppState,
        agreePrivacyPolicy: Bool,
        agreeTermsOfService: Bool,
        agreeConsentOfHealthData: Bool,
        agreeLocationDataTermsOfService: Bool
    ) {
        self.appState = appState
        self.agreePrivacyPolicy = agreePrivacyPolicy
        self.agreeTermsOfService = agreeTermsOfService
        self.agreeConsentOfHealthData = agreeConsentOfHealthData
        self.agreeLocationDataTermsOfService = agreeLocationDataTermsOfService

        _viewModel = StateObject(wrappedValue: PersonalInfoViewModel(appState: appState))
    }
    
    let genders = ["Male", "Female", "Other"]
    let bloodTypes = ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-", "Unknown"]
    let countryCodes = ["+82", "+1"]
    let emailDomains = ["@gmail.com", "@icloud.com"]

    var body: some View {
        Form {
            Section(header: Text("Personal Information")) {
                HStack {
                    Text("*")
                        .foregroundColor(.red)
                    TextField("name", text: $viewModel.name)
                        .keyboardType(.default)
                }

                HStack {
                    Text("*")
                        .foregroundColor(.red)
                    DatePicker("Birth Date", selection: $viewModel.birthDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                }

                HStack {
                    Text("*")
                        .foregroundColor(.red)
                    Picker("Gender", selection: $viewModel.gender) {
                        ForEach(genders, id: \.self) { Text($0) }
                    }
                }

                HStack {
                    Text("*")
                        .foregroundColor(.red)
                    Picker("Blood Type", selection: $viewModel.bloodType) {
                        ForEach(bloodTypes, id: \.self) { Text($0) }
                    }
                }

                HStack {
                    Text("*")
                        .foregroundColor(.red)
                    TextField("Height (cm)", text: $viewModel.height)
                        .keyboardType(.decimalPad)
                }

                HStack {
                    Text("*")
                        .foregroundColor(.red)
                    TextField("Weight (kg)", text: $viewModel.weight)
                        .keyboardType(.decimalPad)
                }

                HStack {
                    Text("*")
                        .foregroundColor(.red)

                    TextField("Email ID", text: $viewModel.emailId)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)

                    Picker("", selection: $viewModel.emailDomain) {
                        ForEach(emailDomains, id: \.self, content: Text.init)
                    }
                    .pickerStyle(.menu)
                    .frame(width: 170)
                }

                HStack {
                    Text("*")
                        .foregroundColor(.red)
                    Picker("", selection: $viewModel.nationalCode) {
                        ForEach(countryCodes, id: \.self, content: Text.init)
                    }
                    .frame(width: 80)
                    .pickerStyle(.menu)

                    TextField("Phone Number", text: $viewModel.phoneNumber)
                        .keyboardType(.phonePad)
                }
            }

            Section {
                Button("Register") {
                    Task {
                           await viewModel.register()
                       }
                }
                .disabled(!viewModel.allRequiredFilled)
                .foregroundColor(viewModel.allRequiredFilled ? .blue : .gray)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationTitle("Input Personal Information")
        .navigationBarTitleDisplayMode(.inline)
    }
}
