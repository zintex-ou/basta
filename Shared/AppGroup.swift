import Foundation

/// Single source of truth for the App Group shared by the app and all extensions.
enum AppGroup {
    static let id = "group.com.zintex.basta"
    static let storeName = "basta.main"          // ManagedSettingsStore name

    static var defaults: UserDefaults {
        UserDefaults(suiteName: id) ?? .standard
    }

    enum Key {
        static let modes = "basta.modes.v1"
        static let activeModeIDs = "basta.activeModeIDs.v1"
        static let strictUntil = "basta.strictUntil.v1"
        static let onboardingDone = "basta.onboardingDone.v1"
        static let language = "basta.language.v1"
    }
}
