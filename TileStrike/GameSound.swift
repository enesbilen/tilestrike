import AVFoundation

final class GameSound {
    static let shared = GameSound()

    enum Effect: String, CaseIterable {
        case place
        case invalid
        case lineClear = "line_clear"
        case combo
        case bomb
        case record
        case gameOver = "game_over"
    }

    private var players: [Effect: AVAudioPlayer] = [:]

    private init() {
        configureAudioSession()
        preload()
    }

    func play(_ effect: Effect) {
        guard let player = players[effect] else { return }

        player.currentTime = 0
        player.play()
    }

    private func preload() {
        for effect in Effect.allCases {
            guard let url = Bundle.main.url(
                forResource: effect.rawValue,
                withExtension: "wav",
                subdirectory: "Sounds"
            ) else { continue }

            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                players[effect] = player
            } catch {
                continue
            }
        }
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            return
        }
    }
}
