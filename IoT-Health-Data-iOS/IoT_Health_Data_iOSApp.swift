import SwiftUI

@main
struct IoT_Health_Data_iOSApp: App {
    @StateObject private var appState = AppState()
    private let tokenManager = TokenManager.shared
    
//    init() {
//        do {
//            try tokenManager.deleteAccessToken()
//            try tokenManager.deleteRefreshToken()
//            print("자동 로그아웃: 토큰 삭제 완료")
//        } catch {
//            print("토큰 삭제 실패: \(error)")
//        }
//    }
    
    var body: some Scene {
        
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .onAppear {appState.updateUserRole()}
        }
        
    }
}
