import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {        
        Group {
            if !appState.isSignedIn {
                SignInView(appState: appState)
            } else {
                switch appState.userRole {
                case .GUEST, .AQD_USER:
                    TermsView(appState: appState)
                case .HD_USER, .BOTH_USER:
                    MainView(appState: appState)
                default:
                    SignInView(appState: appState)
                }
            }
        }
        .task {
            await appState.initialize()
        }
    }
}
