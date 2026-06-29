import SwiftUI

struct GridPoint: Hashable {
    let row: Int
    let col: Int

    func translated(by origin: GridPoint) -> GridPoint {
        GridPoint(row: origin.row + row, col: origin.col + col)
    }
}

struct BlockPiece: Identifiable {
    let id = UUID()
    let cells: [GridPoint]
    let color: Color
    let name: String
    let isBomb: Bool

    var width: Int {
        (cells.map(\.col).max() ?? 0) + 1
    }

    var height: Int {
        (cells.map(\.row).max() ?? 0) + 1
    }

    func cells(at origin: GridPoint) -> [GridPoint] {
        cells.map { $0.translated(by: origin) }
    }
}

struct LineClearResult {
    let count: Int
    let cells: Set<GridPoint>

    static let empty = LineClearResult(count: 0, cells: [])
}

struct BoardState {
    let rows: Int
    let columns: Int
    private(set) var cells: [[Color?]]

    init(rows: Int, columns: Int) {
        self.rows = max(1, rows)
        self.columns = max(1, columns)
        cells = Array(repeating: Array(repeating: nil, count: self.columns), count: self.rows)
    }

    var occupiedPoints: [GridPoint] {
        var points: [GridPoint] = []

        for row in 0..<rows {
            for col in 0..<columns where cells[row][col] != nil {
                points.append(GridPoint(row: row, col: col))
            }
        }

        return points
    }

    func resizedPreservingContent(rows newRows: Int, columns newColumns: Int) -> (state: BoardState, droppedCells: Int) {
        var next = BoardState(rows: newRows, columns: newColumns)
        let occupied = occupiedPoints

        guard !occupied.isEmpty else {
            return (next, 0)
        }

        let minRow = occupied.map(\.row).min() ?? 0
        let maxRow = occupied.map(\.row).max() ?? 0
        let minCol = occupied.map(\.col).min() ?? 0
        let maxCol = occupied.map(\.col).max() ?? 0
        let occupiedHeight = maxRow - minRow + 1
        let occupiedWidth = maxCol - minCol + 1

        // Keep the occupied shape inside the resized board whenever it can fit.
        let rowOffset = occupiedHeight <= next.rows ? clamped(-minRow, min: -minRow, max: next.rows - 1 - maxRow) : 0
        let colOffset = occupiedWidth <= next.columns ? clamped(-minCol, min: -minCol, max: next.columns - 1 - maxCol) : 0
        var droppedCells = 0

        for point in occupied {
            let movedPoint = GridPoint(row: point.row + rowOffset, col: point.col + colOffset)
            if next.contains(movedPoint) {
                next.cells[movedPoint.row][movedPoint.col] = cells[point.row][point.col]
            } else {
                droppedCells += 1
            }
        }

        return (next, droppedCells)
    }

    func contains(_ point: GridPoint) -> Bool {
        point.row >= 0 && point.row < rows && point.col >= 0 && point.col < columns
    }

    func color(at point: GridPoint) -> Color? {
        guard contains(point) else { return nil }
        return cells[point.row][point.col]
    }

    func canPlace(_ piece: BlockPiece, at origin: GridPoint) -> Bool {
        piece.cells(at: origin).allSatisfy { point in
            contains(point) && cells[point.row][point.col] == nil
        }
    }

    mutating func place(_ piece: BlockPiece, at origin: GridPoint) {
        for point in piece.cells(at: origin) where contains(point) {
            cells[point.row][point.col] = piece.color
        }
    }

    mutating func clearAround(_ origin: GridPoint) {
        let rowRange = max(0, origin.row - 1)...min(rows - 1, origin.row + 1)
        let colRange = max(0, origin.col - 1)...min(columns - 1, origin.col + 1)

        for row in rowRange {
            for col in colRange {
                cells[row][col] = nil
            }
        }
    }

    mutating func clearCompletedLines() -> LineClearResult {
        let rowsToClear = (0..<rows).filter { row in
            cells[row].allSatisfy { $0 != nil }
        }

        let colsToClear = (0..<columns).filter { col in
            (0..<rows).allSatisfy { row in cells[row][col] != nil }
        }

        guard !rowsToClear.isEmpty || !colsToClear.isEmpty else {
            return .empty
        }

        var clearedCells = Set<GridPoint>()

        for row in rowsToClear {
            for col in 0..<columns {
                clearedCells.insert(GridPoint(row: row, col: col))
                cells[row][col] = nil
            }
        }

        for col in colsToClear {
            for row in 0..<rows {
                clearedCells.insert(GridPoint(row: row, col: col))
                cells[row][col] = nil
            }
        }

        return LineClearResult(count: rowsToClear.count + colsToClear.count, cells: clearedCells)
    }

    func firstEmptyCell() -> GridPoint? {
        for row in 0..<rows {
            for col in 0..<columns where cells[row][col] == nil {
                return GridPoint(row: row, col: col)
            }
        }

        return nil
    }

    private func clamped(_ value: Int, min lowerBound: Int, max upperBound: Int) -> Int {
        Swift.min(Swift.max(value, lowerBound), upperBound)
    }
}
