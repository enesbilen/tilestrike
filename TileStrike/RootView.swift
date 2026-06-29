import SwiftUI

private enum AppScreen {
    case menu, game, scores
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
                    onScores: { go(to: .scores) }
                )
                .transition(.opacity)

            case .game:
                ContentView(game: game, onReturnToMenu: { go(to: .menu) })
                    .transition(.opacity)

            case .scores:
                ScoreHistoryView(onDismiss: { go(to: .menu) })
                    .transition(.opacity)
            }
        }
        .task {
            GameFeedback.warmUp()
        }
    }

    private func go(to next: AppScreen) {
        withAnimation(.easeInOut(duration: 0.26)) {
            screen = next
        }
    }
}
