import SwiftUI

private enum AppScreen {
    case menu, game, scores, settings
}

struct RootView: View {
    @StateObject private var game = GameModel()
    @State private var screen: AppScreen = .menu

    var body: some View {
        ZStack {
            switch screen {
            case .menu:
                MainMenuView(
                    hasActiveGame: game.isInProgress,
                    onContinue: { go(to: .game) },
                    onNewGame: { game.reset(); go(to: .game) },
                    onScores: { go(to: .scores) },
                    onSettings: { go(to: .settings) }
                )
                .transition(.opacity)

            case .game:
                ContentView(game: game, onReturnToMenu: { go(to: .menu) })
                    .transition(.opacity)

            case .scores:
                ScoreHistoryView(onDismiss: { go(to: .menu) })
                    .transition(.opacity)

            case .settings:
                SettingsView(onDismiss: { go(to: .menu) })
                    .transition(.opacity)
            }
        }
        .task {
            GameFeedback.warmUp()
            AdMobService.shared.start()
        }
    }

    private func go(to next: AppScreen) {
        withAnimation(.easeInOut(duration: 0.26)) {
            screen = next
        }
    }
}
