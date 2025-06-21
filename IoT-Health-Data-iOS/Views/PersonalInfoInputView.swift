import SwiftUI

struct PersonalInfoInputView: View {

    @StateObject var viewModel: PersonalInfoViewModel
    @ObservedObject var appState: AppState

    let agreePrivacyPolicy: Bool
    let agreeTermsOfService: Bool
    let agreeConsentOfHealthData: Bool
    let agreeLocationDataTermsOfService: Bool

    let genders = ["Male", "Female", "Other"]
    let bloodTypes = ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-", "Unknown"]
    let countryCodes = ["+82", "+1"]
    let emailDomains = ["@gmail.com", "@icloud.com"]

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

    var body: some View {
        VStack {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .padding(.top, 20)

            Form {
                Section(header: Text("Personal Information")) {
                    HStack {
                        Text("*").foregroundColor(.red)
                        TextField("Name", text: $viewModel.name)
                            .keyboardType(.default)
                    }

                    HStack {
                        Text("*").foregroundColor(.red)
                        DatePicker("Birth Date", selection: $viewModel.birthDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                    }

                    HStack {
                        Text("*").foregroundColor(.red)
                        Picker("Gender", selection: $viewModel.gender) {
                            ForEach(genders, id: \.self) { Text($0) }
                        }
                    }

                    HStack {
                        Text("*").foregroundColor(.red)
                        Picker("Blood Type", selection: $viewModel.bloodType) {
                            ForEach(bloodTypes, id: \.self) { Text($0) }
                        }
                    }

                    HStack {
                        Text("*").foregroundColor(.red)
                        TextField("Height (cm)", text: $viewModel.height)
                            .keyboardType(.decimalPad)
                    }

                    HStack {
                        Text("*").foregroundColor(.red)
                        TextField("Weight (kg)", text: $viewModel.weight)
                            .keyboardType(.decimalPad)
                    }

                    HStack {
                        Text("*").foregroundColor(.red)
                        TextField("Email ID", text: $viewModel.emailId)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)

                        Picker("", selection: $viewModel.emailDomain) {
                            ForEach(emailDomains, id: \.self) { Text($0) }
                        }
                        .frame(width: 170)
                    }

                    HStack {
                        Text("*").foregroundColor(.red)
                        Picker("", selection: $viewModel.nationalCode) {
                            ForEach(countryCodes, id: \.self) { Text($0) }
                        }
                        .frame(width: 80)

                        TextField("Phone Number", text: $viewModel.phoneNumber)
                            .keyboardType(.phonePad)
                    }
                }

                HStack(spacing: 20) {
                    Button("Reset") {
                        resetFields()
                    }
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray5))
                    .listRowBackground(Color.clear)
                    .cornerRadius(10)
                    .buttonStyle(.plain)

                    Button("Register") {
                        Task {
                            await viewModel.register()
                        }
                    }
                    .disabled(!viewModel.allRequiredFilled)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.allRequiredFilled ? Color.blue : Color.gray)
                    .listRowBackground(Color.clear)
                    .cornerRadius(10)
                    .buttonStyle(.plain)
                }
                .padding()
            }
        }
        .scrollContentBackground(.hidden) 
        .background(Color.white)
        
        .onAppear {
            UITableView.appearance().backgroundColor = .white
            UITableViewCell.appearance().backgroundColor = .white
            UITableView.appearance().backgroundView = nil
            // 기본값 설정
            if viewModel.gender.isEmpty {
                viewModel.gender = genders.first!
            }
            if viewModel.bloodType.isEmpty {
                viewModel.bloodType = bloodTypes.last!
            }
        }
        .navigationTitle("Input Personal Information")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func resetFields() {
        viewModel.name = ""
        viewModel.birthDate = Date()
        viewModel.gender = genders.first ?? "Male"
        viewModel.bloodType = bloodTypes.last ?? "Unknown"
        viewModel.height = ""
        viewModel.weight = ""
        viewModel.emailId = ""
        viewModel.emailDomain = emailDomains.first ?? "@gmail.com"
        viewModel.nationalCode = countryCodes.first ?? "+82"
        viewModel.phoneNumber = ""
    }
}
