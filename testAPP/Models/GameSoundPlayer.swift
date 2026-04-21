//  testAPP
//
//  Created by moooove on 21.04.2026.
//

import AVFoundation
import Foundation

final class GameSoundPlayer {
    static let shared = GameSoundPlayer()

    private var players: [String: AVAudioPlayer] = [:]

    private init() {}

    func preload(fileNames: [String]) {
        for fileName in fileNames {
            _ = player(for: fileName)
        }
    }

    func play(_ fileName: String) {
        guard GameAudioSettings.isSoundEnabled else { return }
        guard let player = player(for: fileName) else { return }

        player.currentTime = 0
        player.play()
    }

    @discardableResult
    private func player(for fileName: String) -> AVAudioPlayer? {
        if let existing = players[fileName] {
            return existing
        }

        let fileURL: URL?
        if let resourceURL = Bundle.main.url(forResource: fileName, withExtension: nil) {
            fileURL = resourceURL
        } else {
            let nsName = fileName as NSString
            fileURL = Bundle.main.url(forResource: nsName.deletingPathExtension, withExtension: nsName.pathExtension)
        }

        guard let fileURL else { return nil }

        do {
            let player = try AVAudioPlayer(contentsOf: fileURL)
            player.prepareToPlay()
            players[fileName] = player
            return player
        } catch {
            return nil
        }
    }
}
