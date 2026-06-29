import UIKit

enum GameFeedback {
    private static let impactLight = UIImpactFeedbackGenerator(style: .light)
    private static let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private static let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private static let impactRigid = UIImpactFeedbackGenerator(style: .rigid)
    private static let notification = UINotificationFeedbackGenerator()

    static func placement() {
        GameSound.shared.play(.place)
        impactLight.impactOccurred()
    }

    static func lineClear() {
        GameSound.shared.play(.lineClear)
        impactMedium.impactOccurred()
    }

    static func combo() {
        GameSound.shared.play(.combo)
        notification.notificationOccurred(.success)
    }

    static func bomb() {
        GameSound.shared.play(.bomb)
        impactHeavy.impactOccurred()
    }

    static func invalidMove() {
        GameSound.shared.play(.invalid)
        impactRigid.impactOccurred()
    }

    static func gameOver() {
        GameSound.shared.play(.gameOver)
        notification.notificationOccurred(.error)
    }

    static func record() {
        GameSound.shared.play(.record)
        notification.notificationOccurred(.success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
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
