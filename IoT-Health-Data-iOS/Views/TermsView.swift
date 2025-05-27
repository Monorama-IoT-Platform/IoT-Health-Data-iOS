import SwiftUI

enum AgreementType: Identifiable {
    case privacyPolicy, termsOfService, healthData, locationData

    var id: Int { hashValue }

    var title: String {
        switch self {
        case .privacyPolicy: return "Privacy Policy"
        case .termsOfService: return "Terms of Service"
        case .healthData: return "Health Data Consent"
        case .locationData: return "Location Data Terms"
        }
    }

    var content: String {
        switch self {
        case .privacyPolicy: return "여기에 Privacy Policy 자세한 내용을 작성하세요..."
        case .termsOfService: return "여기에 Terms of Service 자세한 내용을 작성하세요..."
        case .healthData: return "여기에 Health Data Consent 자세한 내용을 작성하세요..."
        case .locationData: return "여기에 Location Data Terms 자세한 내용을 작성하세요..."
        }
    }
}

struct TermsView: View {
    
    @ObservedObject var appState: AppState
    
    @State private var agreePrivacyPolicy = false
    @State private var agreeTermsOfService = false
    @State private var agreeConsentOfHealthData = false
    @State private var agreeLocationDataTermsOfService = false

    @State private var selectedSheet: AgreementType?
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    enum NavigationTarget: Hashable {
        case personalInfoInput(
            agreePrivacyPolicy: Bool,
            agreeTermsOfService: Bool,
            agreeConsentOfHealthData: Bool,
            agreeLocationDataTermsOfService: Bool)
    }
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(spacing: 30) {
                    Spacer().frame(height: 40)

                    Text("Input Personal Health Information")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .padding(.top, 20)

                    VStack(alignment: .leading, spacing: 24) {
                        agreementToggle(title: "Privacy Policy", isOn: $agreePrivacyPolicy, type: .privacyPolicy)
                        agreementToggle(title: "Terms of Service", isOn: $agreeTermsOfService, type: .termsOfService)
                        agreementToggle(title: "Consent of Health Data", isOn: $agreeConsentOfHealthData, type: .healthData)
                        agreementToggle(title: "Location Data Terms of Service", isOn: $agreeLocationDataTermsOfService, type: .locationData)
                    }
                    .padding(.horizontal, 30)

                    Button(action: {
                        if allRequiredAgreed {
                            navigationPath.append(
                                NavigationTarget.personalInfoInput(
                                    agreePrivacyPolicy: agreePrivacyPolicy,
                                    agreeTermsOfService: agreeTermsOfService,
                                    agreeConsentOfHealthData: agreeConsentOfHealthData,
                                    agreeLocationDataTermsOfService: agreeLocationDataTermsOfService)
                            )
                        } else {
                            errorMessage = "필수 약관에 모두 동의해주세요."
                            showErrorAlert = true
                        }
                    }) {
                        Text("Next")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(allRequiredAgreed ? Color.blue : Color.gray)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 30)
                    .disabled(!allRequiredAgreed)

                    Spacer()
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .alert("알림", isPresented: $showErrorAlert) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .sheet(item: $selectedSheet) { sheet in
                VStack(spacing: 20) {
                    Text(sheet.title)
                        .font(.headline)
                        .padding(.top)

                    ScrollView {
                        Text(sheet.content)
                            .padding()
                    }

                    Button("Close") {
                        selectedSheet = nil
                    }
                    .padding()
                }
                .presentationDetents([.large])
            }
            .navigationDestination(for: NavigationTarget.self) { target in
                switch target {
                case let .personalInfoInput(privacy, terms, health, location):
                    PersonalInfoInputView(
                        appState: appState,
                        agreePrivacyPolicy: privacy,
                        agreeTermsOfService: terms,
                        agreeConsentOfHealthData: health,
                        agreeLocationDataTermsOfService: location
                    )
                }
            }
        }
    }

    var allRequiredAgreed: Bool {
        agreePrivacyPolicy &&
        agreeTermsOfService &&
        agreeConsentOfHealthData &&
        agreeLocationDataTermsOfService
    }

    @ViewBuilder
    private func agreementToggle(title: String, isOn: Binding<Bool>, type: AgreementType) -> some View {
        Toggle(isOn: isOn) {
            HStack {
                Text("*")
                    .foregroundColor(.red)
                    .bold()
                Text(title)
                Spacer()
                Button(action: {
                    selectedSheet = type
                }) {
                    Text("view")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .toggleStyle(SwitchToggleStyle(tint: .blue))
    }
}
