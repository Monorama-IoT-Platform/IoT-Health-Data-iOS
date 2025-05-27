import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @StateObject private var viewModel: SignInViewModel
    @ObservedObject var appState: AppState
    
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    
    init(appState: AppState) {
        self.appState = appState                   // 이 부분 꼭 추가
        _viewModel = StateObject(wrappedValue: SignInViewModel(appState: appState))
    }


    var body: some View {
        NavigationStack {
            VStack {
                Spacer().frame(height: 80)

                Text("Health Data collection")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10)

                Spacer(minLength: 0)

                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .padding(.bottom, 100)

                Spacer()

                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        switch result {
                        case .success(let authResults):
                            if let credential = authResults.credential as? ASAuthorizationAppleIDCredential,
                               let identityToken = credential.identityToken,
                               let tokenString = String(data: identityToken, encoding: .utf8) {
                                
                                Task {
                                    await viewModel.signInWithApple(token: tokenString)
                                }
                            }
                        case .failure(let error):
                            print("로그인 실패 : " + error.localizedDescription)
                            errorMessage = error.localizedDescription
                            showErrorAlert = true
                        }
                    }
                )
                .signInWithAppleButtonStyle(.black)
                .frame(width: 280, height: 45)
                .padding(.bottom, 100)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            
            
            .navigationDestination(isPresented: Binding(
                get: { appState.isSignedIn && appState.userRole == .guest },
                set: { if !$0 { appState.userRole = .unknown } }
            )) {
                TermsView(appState: appState)
            }

            .navigationDestination(isPresented: Binding(
                get: { appState.isSignedIn && (appState.userRole == .hdUser || appState.userRole == .bothUser) },
                set: { if !$0 { appState.userRole = .unknown } }
            )) {
                EmptyView() // 메인 화면
            }
            
            .alert("로그인 실패", isPresented: $showErrorAlert) {
                Button("확인", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
}
