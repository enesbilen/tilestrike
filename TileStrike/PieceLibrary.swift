import SwiftUI

enum PieceLibrary {
    static let palette: [Color] = [
        Color(red: 0.20, green: 0.78, blue: 0.70),
        Color(red: 0.97, green: 0.42, blue: 0.38),
        Color(red: 1.00, green: 0.75, blue: 0.30),
        Color(red: 0.40, green: 0.58, blue: 0.98),
        Color(red: 0.66, green: 0.50, blue: 0.98),
        Color(red: 0.47, green: 0.83, blue: 0.42)
    ]

    private static let templates: [[GridPoint]] = [
        [GridPoint(row: 0, col: 0)],
        [GridPoint(row: 0, col: 0), GridPoint(row: 0, col: 1)],
        [GridPoint(row: 0, col: 0), GridPoint(row: 1, col: 0)],
        [GridPoint(row: 0, col: 0), GridPoint(row: 0, col: 1), GridPoint(row: 0, col: 2)],
        [GridPoint(row: 0, col: 0), GridPoint(row: 1, col: 0), GridPoint(row: 2, col: 0)],
        [GridPoint(row: 0, col: 0), GridPoint(row: 0, col: 1), GridPoint(row: 1, col: 0), GridPoint(row: 1, col: 1)],
        [GridPoint(row: 0, col: 0), GridPoint(row: 1, col: 0), GridPoint(row: 1, col: 1)],
        [GridPoint(row: 0, col: 1), GridPoint(row: 1, col: 0), GridPoint(row: 1, col: 1)],
        [GridPoint(row: 0, col: 0), GridPoint(row: 0, col: 1), GridPoint(row: 0, col: 2), GridPoint(row: 1, col: 1)],
        [GridPoint(row: 0, col: 0), GridPoint(row: 1, col: 0), GridPoint(row: 2, col: 0), GridPoint(row: 2, col: 1)]
    ]

    static func randomChoices(
        count: Int,
        score: Int,
        bombSpawnState: inout GameRules.BombSpawnState
    ) -> [BlockPiece] {
        guard count > 0 else { return [] }

        let shuffledPalette = palette.shuffled()
        let bombIndex = GameRules.shouldSpawnBomb(score: score, state: &bombSpawnState)
            ? Int.random(in: 0..<count)
            : nil
        var colorIndex = 0

        return (0..<count).map { index in
            if index == bombIndex {
                return bomb()
            }

            let color = shuffledPalette[colorIndex % shuffledPalette.count]
            colorIndex += 1

            return BlockPiece(
                cells: templates.randomElement() ?? templates[0],
                color: color,
                name: "Parça",
                isBomb: false
            )
        }
    }

    static func singleRescuePiece() -> BlockPiece {
        BlockPiece(
            cells: [GridPoint(row: 0, col: 0)],
            color: palette.randomElement() ?? Color(red: 0.20, green: 0.78, blue: 0.70),
            name: "Tekli",
            isBomb: false
        )
    }

    private static func bomb() -> BlockPiece {
        BlockPiece(
            cells: [GridPoint(row: 0, col: 0)],
            color: Color(red: 0.10, green: 0.10, blue: 0.12),
            name: "Bomba",
            isBomb: true
        )
    }
}
