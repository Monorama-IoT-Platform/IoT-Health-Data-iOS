import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            if !appState.isSignedIn {
                // 로그인 안 된 상태 → 로그인 화면
                SignInView(appState: appState)
            } else {
                switch appState.userRole {
                case .guest:
                    // 로그인은 했지만 게스트 → 약관 동의 화면
                    TermsView(appState: appState)
                case .hdUser, .bothUser:
                    MainView()
                default:
                    // 기타 예외 상황은 로그인 화면
                    SignInView(appState: appState)
                }
            }
        }
        .task {
            await appState.initialize()
        }
    }
}
