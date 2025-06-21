import SwiftUI

extension View {
    func toast(
        isShowing: Binding<Bool>,
        message: String,
        type: ToastType = .info,
        duration: TimeInterval = 2.0
    ) -> some View {
        self.modifier(ToastModifier(
            isShowing: isShowing,
            message: message,
            type: type,
            duration: duration
        ))
    }
}
