import Foundation

enum GameRules {
    static let choiceCount = 4
    static let placementPointsPerCell = 8
    static let lineClearBasePoints = 120

    private static let minimumBatchesBetweenBombs = 2
    private static let firstBombFreeBatches = 1
    private static let bombPityStartBatch = 6
    private static let bombPityBonusPermille = 14
    private static let maximumBombChancePermille = 130
    private static let minimumBoardScoreScale = 0.80
    private static let maximumBoardScoreScale = 1.20

    struct BombSpawnState {
        fileprivate var generatedBatches = 0
        fileprivate var batchesSinceBomb = minimumBatchesBetweenBombs

        mutating func reset() {
            generatedBatches = 0
            batchesSinceBomb = GameRules.minimumBatchesBetweenBombs
        }
    }

    static func shouldSpawnBomb(score: Int, mode: GameMode, state: inout BombSpawnState) -> Bool {
        let chance = bombChancePermille(score: score, mode: mode, state: state)
        let shouldSpawn = chance > 0 && Int.random(in: 0..<1000) < chance

        state.generatedBatches += 1
        state.batchesSinceBomb = shouldSpawn ? 0 : state.batchesSinceBomb + 1
        return shouldSpawn
    }

    static func placementScore(for piece: BlockPiece, boardRows: Int, boardColumns: Int) -> Int {
        scaledScore(piece.cells.count * placementPointsPerCell, boardRows: boardRows, boardColumns: boardColumns)
    }

    static func lineClearScore(clearedLines: Int, combo: Int, boardRows: Int, boardColumns: Int) -> Int {
        lineClearScore(clearedLines: clearedLines, combo: combo, mode: .classic, boardRows: boardRows, boardColumns: boardColumns)
    }

    static func lineClearScore(clearedLines: Int, combo: Int, mode: GameMode, boardRows: Int, boardColumns: Int) -> Int {
        let multiplier: Double = mode == .bombRush ? 1.25 : 1.0
        let baseScore = Double(clearedLines * lineClearBasePoints * combo) * multiplier
        return scaledScore(Int(baseScore.rounded()), boardRows: boardRows, boardColumns: boardColumns)
    }

    private static func scaledScore(_ baseScore: Int, boardRows: Int, boardColumns: Int) -> Int {
        let boardArea = max(1, boardRows * boardColumns)
        let rawScale = Double(GameLayout.fallbackBoardLayout.area) / Double(boardArea)
        let scale = min(maximumBoardScoreScale, max(minimumBoardScoreScale, rawScale))
        return max(1, Int((Double(baseScore) * scale).rounded()))
    }

    private static func bombChancePermille(score: Int, mode: GameMode, state: BombSpawnState) -> Int {
        if mode == .bombRush {
            guard state.batchesSinceBomb >= 1 else { return 0 }

            let baseChance: Int
            switch score {
            case 0..<600:
                baseChance = 300
            case 600..<2_000:
                baseChance = 260
            case 2_000..<6_000:
                baseChance = 210
            default:
                baseChance = 170
            }

            let pityBonus = max(0, state.batchesSinceBomb - 3) * 22
            return min(420, baseChance + pityBonus)
        }

        guard state.generatedBatches >= firstBombFreeBatches else { return 0 }
        guard state.batchesSinceBomb >= minimumBatchesBetweenBombs else { return 0 }

        let baseChance: Int
        switch score {
        case 0..<600:
            baseChance = 120
        case 600..<2_000:
            baseChance = 90
        case 2_000..<6_000:
            baseChance = 60
        default:
            baseChance = 40
        }

        let pityBatches = max(0, state.batchesSinceBomb - bombPityStartBatch)
        let pityBonus = pityBatches * bombPityBonusPermille
        return min(maximumBombChancePermille, baseChance + pityBonus)
    }
}
