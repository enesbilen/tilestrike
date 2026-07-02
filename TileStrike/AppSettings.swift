import Foundation

enum AppSettings {
    static let soundEnabledKey = "soundEnabled"
    static let hapticsEnabledKey = "hapticsEnabled"
    static let themeKey = "gameTheme"
    static let gameModeKey = "gameMode"
    static let blockStyleKey = "blockStyle"

    static var isSoundEnabled: Bool {
        bool(forKey: soundEnabledKey, defaultValue: true)
    }

    static var isHapticsEnabled: Bool {
        bool(forKey: hapticsEnabledKey, defaultValue: true)
    }

    static var currentTheme: GameTheme {
        let rawTheme = UserDefaults.standard.string(forKey: themeKey) ?? GameTheme.ember.rawValue
        return GameTheme.current(rawValue: rawTheme)
    }

    static var currentGameMode: GameMode {
        let rawMode = UserDefaults.standard.string(forKey: gameModeKey) ?? GameMode.classic.rawValue
        return GameMode.current(rawValue: rawMode)
    }

    static var currentBlockStyle: BlockStyle {
        let rawStyle = UserDefaults.standard.string(forKey: blockStyleKey) ?? BlockStyle.classic.rawValue
        return BlockStyle.current(rawValue: rawStyle)
    }

    private static func bool(forKey key: String, defaultValue: Bool) -> Bool {
        guard UserDefaults.standard.object(forKey: key) != nil else {
            return defaultValue
        }

        return UserDefaults.standard.bool(forKey: key)
    }
}
