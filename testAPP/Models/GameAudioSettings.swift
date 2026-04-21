//  testAPP
//
//  Created by moooove on 21.04.2026.
//

import Foundation

enum GameAudioSettings {
    private static let soundEnabledKey = "game_sound_enabled"

    static var isSoundEnabled: Bool {
        get {
            if UserDefaults.standard.object(forKey: soundEnabledKey) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: soundEnabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: soundEnabledKey)
        }
    }
}
