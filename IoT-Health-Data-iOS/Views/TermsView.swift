import SwiftUI

struct TermsView: View {
    @StateObject private var viewModel: BothUserViewModel
    @ObservedObject var appState: AppState
    
    @State private var agreePrivacyPolicy = false
    @State private var agreeTermsOfService = false
    @State private var agreeConsentOfHealthData = false
    @State private var agreeLocationDataTermsOfService = false

    @State private var selectedSheet: AgreementType?
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    @State private var navigationPath = NavigationPath()

    enum NavigationTarget: Hashable {
        case personalInfoInput(
            agreePrivacyPolicy: Bool,
            agreeTermsOfService: Bool,
            agreeConsentOfHealthData: Bool,
            agreeLocationDataTermsOfService: Bool)
    }
    
    init(appState: AppState) {
        self.appState = appState
        _viewModel = StateObject(wrappedValue: BothUserViewModel(appState: appState))
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(spacing: 30) {
                    Spacer().frame(height: 40)

                    Text("Agreement Required")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .padding(.top, 20)
                    
                    Spacer()

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Agreement to Terms")
                            .font(.headline)
                            .padding(.bottom, 8)
                        
                        agreementToggle(title: "Privacy Policy", isOn: $agreePrivacyPolicy, type: .privacyPolicy)
                        agreementToggle(title: "Terms of Service", isOn: $agreeTermsOfService, type: .termsOfService)
                        agreementToggle(title: "Consent of Health Data", isOn: $agreeConsentOfHealthData, type: .healthData)
                        agreementToggle(title: "Location Data Terms of Service", isOn: $agreeLocationDataTermsOfService, type: .locationData)
                    }
                    .padding(.horizontal)
                    
                    HStack(spacing: 16) {
                        Button("Reset") {
                            agreePrivacyPolicy = false
                            agreeTermsOfService = false
                            agreeConsentOfHealthData = false
                            agreeLocationDataTermsOfService = false
                        }
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Color(.systemGray5))
                        .cornerRadius(10)

                        Button(action: {
                            if allRequiredAgreed {
                                if appState.userRole == .GUEST {
                                    navigationPath.append(
                                        NavigationTarget.personalInfoInput(
                                            agreePrivacyPolicy: agreePrivacyPolicy,
                                            agreeTermsOfService: agreeTermsOfService,
                                            agreeConsentOfHealthData: agreeConsentOfHealthData,
                                            agreeLocationDataTermsOfService: agreeLocationDataTermsOfService)
                                    )
                                } else if appState.userRole == .AQD_USER {
                                    Task {
                                        await viewModel.updateToBothUser()
                                    }
                                }
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
                        .disabled(!allRequiredAgreed)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

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
                    .fontWeight(.medium)
                
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
