import UIKit

enum GameFeedback {
    private static let impactLight = UIImpactFeedbackGenerator(style: .light)
    private static let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private static let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private static let impactRigid = UIImpactFeedbackGenerator(style: .rigid)
    private static let notification = UINotificationFeedbackGenerator()

    static func placement() {
        GameSound.shared.play(.place)
        guard AppSettings.isHapticsEnabled else { return }
        impactLight.impactOccurred()
    }

    static func lineClear() {
        GameSound.shared.play(.lineClear)
        guard AppSettings.isHapticsEnabled else { return }
        impactMedium.impactOccurred()
    }

    static func combo() {
        GameSound.shared.play(.combo)
        guard AppSettings.isHapticsEnabled else { return }
        notification.notificationOccurred(.success)
    }

    static func bomb() {
        GameSound.shared.play(.bomb)
        guard AppSettings.isHapticsEnabled else { return }
        impactHeavy.impactOccurred()
    }

    static func invalidMove() {
        GameSound.shared.play(.invalid)
        guard AppSettings.isHapticsEnabled else { return }
        impactRigid.impactOccurred()
    }

    static func gameOver() {
        GameSound.shared.play(.gameOver)
        guard AppSettings.isHapticsEnabled else { return }
        notification.notificationOccurred(.error)
    }

    static func record() {
        GameSound.shared.play(.record)
        guard AppSettings.isHapticsEnabled else { return }
        notification.notificationOccurred(.success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            guard AppSettings.isHapticsEnabled else { return }
            notification.notificationOccurred(.success)
        }
    }

    static func warmUp() {
        DispatchQueue.global(qos: .userInitiated).async {
            _ = GameSound.shared
        }
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        impactRigid.prepare()
        notification.prepare()
    }
}
