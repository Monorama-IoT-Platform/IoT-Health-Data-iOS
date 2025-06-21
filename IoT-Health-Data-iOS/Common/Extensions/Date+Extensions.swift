import Foundation

extension Date {
    func toYYYYMMdd() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul") // 서버 시간대 바꾸면 바꾸기
        return formatter.string(from: self)
    }
    
    func toYYYYMMddHHmmSS() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul") // 서버 시간대 바꾸면 바꾸기
        return formatter.string(from: self)
    }
}
