import Foundation
import SwiftUI

final class GameModel: ObservableObject {
    @Published private var boardState: BoardState
    @Published var choices: [BlockPiece] = []
    @Published var score = 0
    @Published var combo = 0
    @Published var bestScore = UserDefaults.standard.integer(forKey: "bestScore")
    @Published var message = "Blok seç, karelere yerleştir"
    @Published var previewCells = Set<GridPoint>()
    @Published var invalidPreviewCells = Set<GridPoint>()
    @Published var lineClearCells = Set<GridPoint>()
    @Published private(set) var isGameOver = false

    private let choiceCount = GameRules.choiceCount
    private var bombSpawnState = GameRules.BombSpawnState()
    private var lineClearAnimationID = UUID()

    var isInProgress: Bool {
        !isGameOver && score > 0
    }

    var board: [[Color?]] {
        boardState.cells
    }

    var boardRows: Int {
        boardState.rows
    }

    var boardColumns: Int {
        boardState.columns
    }

    init() {
        boardState = BoardState(
            rows: GameLayout.fallbackBoardLayout.rows,
            columns: GameLayout.fallbackBoardLayout.columns
        )
        choices = randomChoices()
    }

    func reset() {
        boardState = BoardState(rows: boardRows, columns: boardColumns)
        score = 0
        combo = 0
        bombSpawnState.reset()
        choices = randomChoices()
        isGameOver = false
        message = "Yeni oyun başladı"
        clearLineClearHighlight()
        clearPreview()
    }

    func clearPreview() {
        previewCells.removeAll()
        invalidPreviewCells.removeAll()
    }

    func updateBoardDimensions(rows: Int, columns: Int) {
        guard rows > 0, columns > 0 else { return }
        guard rows != boardRows || columns != boardColumns else { return }

        let wasGameOver = isGameOver
        let resizeResult = boardState.resizedPreservingContent(rows: rows, columns: columns)
        boardState = resizeResult.state
        if resizeResult.droppedCells > 0 {
            message = "Pano ekrana uyarlandı"
        }
        clearLineClearHighlight()
        refreshGameOverState()
        if wasGameOver && !isGameOver {
            message = "Pano büyüdü, hamle açıldı"
        }
        clearPreview()
    }

    func updatePreview(piece: BlockPiece, origin: GridPoint?) {
        guard !isGameOver else {
            clearPreview()
            return
        }

        guard let origin else {
            clearPreview()
            return
        }

        let cells = piece.cells(at: origin)
        if canPlace(piece, at: origin) {
            previewCells = Set(cells)
            invalidPreviewCells.removeAll()
        } else {
            previewCells.removeAll()
            invalidPreviewCells = Set(cells.filter { boardState.contains($0) })
        }
    }

    func place(_ piece: BlockPiece, at origin: GridPoint) {
        guard !isGameOver else {
            clearPreview()
            return
        }

        guard choices.contains(where: { $0.id == piece.id }) else {
            clearPreview()
            return
        }

        guard canPlace(piece, at: origin) else {
            message = "Buraya sığmıyor"
            combo = 0
            return
        }

        boardState.place(piece, at: origin)

        if piece.isBomb {
            boardState.clearAround(origin)
            message = "Bomba çevresini temizledi"
        }

        score += GameRules.placementScore(for: piece, boardRows: boardRows, boardColumns: boardColumns)
        updateBestScore()
        clearCompletedLinesIfNeeded()
        choices.removeAll { $0.id == piece.id }

        var nextChoicesArePlayable = false
        if choices.isEmpty {
            choices = randomChoices()
            nextChoicesArePlayable = ensurePlayableChoices()
            message = nextChoicesArePlayable ? "Kurtarıcı tekli parça geldi" : "Yeni 4 parça geldi"
        }

        if nextChoicesArePlayable {
            updateGameOverState(hasAvailableMove: true)
        } else {
            refreshGameOverState()
        }

        if isGameOver {
            message = "Hamle kalmadı. Skorun \(score)"
            updateBestScore()
            ScoreHistory.shared.record(score: score)
        }

        clearPreview()
    }

    func canPlace(_ piece: BlockPiece, at origin: GridPoint) -> Bool {
        boardState.canPlace(piece, at: origin)
    }

    private func clearCompletedLinesIfNeeded() {
        let clearResult = boardState.clearCompletedLines()
        guard clearResult.count > 0 else {
            combo = 0
            return
        }

        showLineClearHighlight(clearResult.cells)
        combo += 1
        score += GameRules.lineClearScore(
            clearedLines: clearResult.count,
            combo: combo,
            boardRows: boardRows,
            boardColumns: boardColumns
        )
        updateBestScore()
        message = combo > 1 ? "Kombo x\(combo)! \(clearResult.count) çizgi patladı" : "\(clearResult.count) çizgi patladı"
    }

    private func updateBestScore() {
        guard score > bestScore else { return }

        bestScore = score
        UserDefaults.standard.set(bestScore, forKey: "bestScore")
    }

    private func hasAnyMove() -> Bool {
        for piece in choices {
            for row in 0..<boardRows {
                for col in 0..<boardColumns where canPlace(piece, at: GridPoint(row: row, col: col)) {
                    return true
                }
            }
        }
        return false
    }

    private func ensurePlayableChoices() -> Bool {
        guard !hasAnyMove() else { return false }

        if boardState.firstEmptyCell() != nil, !choices.isEmpty {
            choices[0] = PieceLibrary.singleRescuePiece()
            return true
        }

        return false
    }

    private func refreshGameOverState() {
        updateGameOverState(hasAvailableMove: hasAnyMove())
    }

    private func updateGameOverState(hasAvailableMove: Bool) {
        isGameOver = !hasAvailableMove
    }

    private func randomChoices() -> [BlockPiece] {
        PieceLibrary.randomChoices(
            count: choiceCount,
            score: score,
            bombSpawnState: &bombSpawnState
        )
    }

    private func showLineClearHighlight(_ cells: Set<GridPoint>) {
        let animationID = UUID()
        lineClearAnimationID = animationID
        lineClearCells = cells

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.34) { [weak self] in
            guard self?.lineClearAnimationID == animationID else { return }
            self?.lineClearCells.removeAll()
        }
    }

    private func clearLineClearHighlight() {
        lineClearAnimationID = UUID()
        lineClearCells.removeAll()
    }
}
