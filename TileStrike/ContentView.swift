import SwiftUI

struct ContentView: View {
    @ObservedObject var game: GameModel
    var onReturnToMenu: () -> Void = {}

    private func returnToMenu() {
        bestScorePulseTask?.cancel()
        bestScorePulseTask = nil
        bestScorePulse = false
        didCelebrateRecord = false
        showGameOverOverlay = false
        game.clearPreview()
        onReturnToMenu()
    }

    @State private var draggingPiece: BlockPiece?
    @State private var dragLocation: CGPoint = .zero
    @State private var boardFrame: CGRect = .zero
    @State private var boardLayout = GameLayout.fallbackBoardLayout
    @State private var bestScorePulse = false
    @State private var gameOverWasRecord = false
    @State private var didCelebrateRecord = false
    @State private var showGameOverOverlay = false
    @State private var bestScorePulseTask: Task<Void, Never>?

    var body: some View {
        GeometryReader { proxy in
            let traySlotSize = GameLayout.traySlotSize(for: proxy.size.width)
            let currentBoardLayout = GameLayout.boardLayout(for: proxy.size, traySlotSize: traySlotSize)

            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.07, green: 0.09, blue: 0.12),
                        Color(red: 0.12, green: 0.16, blue: 0.17)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 18) {
                    ScoreHeaderView(
                        score: game.score,
                        bestScore: game.bestScore,
                        bestScorePulse: bestScorePulse,
                        onMenu: returnToMenu,
                        onReset: resetGame
                    )
                        .padding(.horizontal, 18)
                        .padding(.top, 10)

                    Text(game.message)
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.86))
                        .frame(maxWidth: .infinity)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                        .padding(.horizontal, 18)

                    GameBoardView(
                        board: game.board,
                        rows: game.boardRows,
                        columns: game.boardColumns,
                        layout: boardLayout,
                        previewCells: game.previewCells,
                        invalidPreviewCells: game.invalidPreviewCells,
                        lineClearCells: game.lineClearCells,
                        previewColor: draggingPiece?.color
                    )
                        .coordinateSpace(name: "board")
                        .background(
                            GeometryReader { boardProxy in
                                Color.clear
                                    .onAppear {
                                        boardFrame = boardProxy.frame(in: .global)
                                    }
                                    .onChange(of: boardProxy.frame(in: .global)) { _, newFrame in
                                        boardFrame = newFrame
                                    }
                            }
                        )

                    Spacer(minLength: 4)

                    PieceTrayView(
                        choices: game.choices,
                        activePieceID: draggingPiece?.id,
                        slotCount: GameRules.choiceCount,
                        slotSize: traySlotSize,
                        slotSpacing: GameLayout.traySlotSpacing,
                        horizontalPadding: GameLayout.trayHorizontalPadding,
                        onDragChanged: handleDragChanged,
                        onDragEnded: handleDragEnded
                    )
                        .padding(.horizontal, 14)
                        .padding(.bottom, 18)
                }
                .onAppear {
                    applyBoardLayout(currentBoardLayout)
                    showGameOverOverlay = game.isGameOver
                }
                .onChange(of: proxy.size) { _, newSize in
                    let nextTraySlotSize = GameLayout.traySlotSize(for: newSize.width)
                    applyBoardLayout(GameLayout.boardLayout(for: newSize, traySlotSize: nextTraySlotSize))
                }

                if let draggingPiece {
                    let layout = dragLayout(for: draggingPiece)
                    BlockPieceView(piece: draggingPiece, layout: layout, isFloating: true)
                        .position(dragCenter(for: dragLocation))
                        .allowsHitTesting(false)
                        .opacity(0.86)
                        .shadow(color: draggingPiece.color.opacity(0.55), radius: 20)
                }

                if showGameOverOverlay {
                    GameOverOverlayView(
                        score: game.score,
                        bestScore: game.bestScore,
                        isNewRecord: gameOverWasRecord,
                        onPlayAgain: resetGame,
                        onMenu: returnToMenu
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
                    .zIndex(2)
                }
            }
            .onChange(of: game.isGameOver) { _, isGameOver in
                withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
                    showGameOverOverlay = isGameOver
                }
            }
        }
    }

    private func applyBoardLayout(_ layout: BoardLayout) {
        boardLayout = layout
        game.updateBoardDimensions(rows: layout.rows, columns: layout.columns)
    }

    private func resetGame() {
        bestScorePulseTask?.cancel()
        bestScorePulseTask = nil
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            gameOverWasRecord = false
            bestScorePulse = false
            didCelebrateRecord = false
            showGameOverOverlay = false
        }
        game.reset()
    }

    private func handleDragChanged(piece: BlockPiece, value: DragGesture.Value) {
        guard !game.isGameOver else { return }

        draggingPiece = piece
        dragLocation = value.location
        game.updatePreview(piece: piece, origin: originForDrag(piece: piece, location: value.location))
    }

    private func handleDragEnded(piece: BlockPiece, value: DragGesture.Value) {
        guard !game.isGameOver else {
            draggingPiece = nil
            game.clearPreview()
            return
        }

        if let origin = originForDrag(piece: piece, location: value.location) {
            guard game.canPlace(piece, at: origin) else {
                GameFeedback.invalidMove()
                game.clearPreview()
                draggingPiece = nil
                return
            }

            let previousBestScore = game.bestScore
            let previousCombo = game.combo

            withAnimation(.spring(response: 0.32, dampingFraction: 0.78)) {
                game.place(piece, at: origin)
            }
            playFeedback(placedPiece: piece, previousBestScore: previousBestScore, previousCombo: previousCombo)
        } else {
            GameFeedback.invalidMove()
            game.clearPreview()
        }

        draggingPiece = nil
    }

    private func dragLayout(for piece: BlockPiece) -> PieceLayout {
        GameLayout.pieceLayout(for: piece, presentation: .floating(boardLayout: boardLayout))
    }

    private func dragCenter(for location: CGPoint) -> CGPoint {
        CGPoint(x: location.x, y: location.y - GameLayout.dragLift)
    }

    private func dragTopLeft(for piece: BlockPiece, location: CGPoint) -> CGPoint {
        let layout = dragLayout(for: piece)
        let center = dragCenter(for: location)
        return CGPoint(
            x: center.x - layout.size.width / 2,
            y: center.y - layout.size.height / 2
        )
    }

    private func originForDrag(piece: BlockPiece, location: CGPoint) -> GridPoint? {
        let layout = dragLayout(for: piece)
        let topLeft = dragTopLeft(for: piece, location: location)
        let firstCellCenter = CGPoint(
            x: topLeft.x + layout.cellSide / 2,
            y: topLeft.y + layout.cellSide / 2
        )
        return GameLayout.boardPoint(from: firstCellCenter, boardFrame: boardFrame, layout: boardLayout)
    }

    private func playFeedback(placedPiece: BlockPiece, previousBestScore: Int, previousCombo: Int) {
        placedPiece.isBomb ? GameFeedback.bomb() : GameFeedback.placement()

        if !didCelebrateRecord && game.bestScore > previousBestScore {
            didCelebrateRecord = true
            gameOverWasRecord = true
            pulseBestScore()
            GameFeedback.record()
        }

        if game.combo > previousCombo {
            game.combo > 1 ? GameFeedback.combo() : GameFeedback.lineClear()
        }

        if game.isGameOver {
            GameFeedback.gameOver()
        }
    }

    private func pulseBestScore() {
        bestScorePulseTask?.cancel()

        withAnimation(.spring(response: 0.28, dampingFraction: 0.52)) {
            bestScorePulse = true
        }

        bestScorePulseTask = Task {
            try? await Task.sleep(nanoseconds: 850_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                guard !Task.isCancelled else { return }
                withAnimation(.easeOut(duration: 0.24)) {
                    bestScorePulse = false
                }
                bestScorePulseTask = nil
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(game: GameModel())
    }
}
