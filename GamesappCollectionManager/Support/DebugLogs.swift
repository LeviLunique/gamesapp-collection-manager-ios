import Foundation

enum DebugLogs {
    static func bundleInfo() {
        let hasGooglePlist = Bundle.main.url(forResource: "GoogleService-Info", withExtension: "plist") != nil
        print("[GamesApp] GoogleService-Info.plist found in bundle: \(hasGooglePlist)")
    }
}
