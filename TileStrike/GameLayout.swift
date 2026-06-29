import CoreGraphics

struct BoardLayout: Equatable {
    let rows: Int
    let columns: Int
    let cellStride: CGFloat
    let blockSide: CGFloat
    let spacing: CGFloat
    let padding: CGFloat

    var size: CGSize {
        CGSize(
            width: CGFloat(columns) * cellStride + padding * 2 - spacing,
            height: CGFloat(rows) * cellStride + padding * 2 - spacing
        )
    }

    var area: Int {
        rows * columns
    }
}

enum PiecePresentation {
    case tray(slotSize: CGSize)
    case floating(boardLayout: BoardLayout)
}

enum GameLayout {
    static let boardPadding: CGFloat = 8
    static let boardSpacing: CGFloat = 4
    static let trayHorizontalPadding: CGFloat = 12
    static let traySlotSpacing: CGFloat = 10
    static let dragLift: CGFloat = 54
    static let fallbackBoardLayout = BoardLayout(
        rows: 11,
        columns: 8,
        cellStride: 43,
        blockSide: 39,
        spacing: boardSpacing,
        padding: boardPadding
    )

    private static let horizontalScreenPadding: CGFloat = 28
    private static let topReservedHeight: CGFloat = 205
    private static let trayReservedSpacing: CGFloat = 46
    private static let preferredBoardStride: CGFloat = 43
    private static let minColumns = 7
    private static let maxColumns = 11
    private static let minRows = 8
    private static let maxRows = 16
    private static let minBoardStride: CGFloat = 30
    private static let maxBoardStride: CGFloat = 72

    static func traySlotSize(for screenWidth: CGFloat) -> CGSize {
        let availableWidth = screenWidth
            - horizontalScreenPadding
            - trayHorizontalPadding * 2
            - traySlotSpacing * CGFloat(GameRules.choiceCount - 1)
        let width = max(68, floor(availableWidth / CGFloat(GameRules.choiceCount)))
        let height = min(76, max(52, floor(width * 0.64)))
        return CGSize(width: width, height: height)
    }

    static func boardLayout(for screenSize: CGSize, traySlotSize: CGSize) -> BoardLayout {
        let availableWidth = max(
            minBoardStride * CGFloat(minColumns),
            screenSize.width - horizontalScreenPadding - boardFrameExtra
        )
        let columns = clamped(
            Int(floor(availableWidth / preferredBoardStride)),
            min: minColumns,
            max: maxColumns
        )
        let widthBasedStride = floor(availableWidth / CGFloat(columns))

        let reservedTrayHeight = traySlotSize.height + trayHorizontalPadding * 2 + trayReservedSpacing
        let availableHeight = max(
            minBoardStride * CGFloat(minRows),
            screenSize.height - topReservedHeight - reservedTrayHeight - boardFrameExtra
        )
        let rows = clamped(
            Int(floor(availableHeight / widthBasedStride)),
            min: minRows,
            max: maxRows
        )
        let heightBasedStride = floor(availableHeight / CGFloat(rows))
        let stride = min(maxBoardStride, max(minBoardStride, min(widthBasedStride, heightBasedStride)))

        return BoardLayout(
            rows: rows,
            columns: columns,
            cellStride: stride,
            blockSide: max(1, stride - boardSpacing),
            spacing: boardSpacing,
            padding: boardPadding
        )
    }

    static func pieceLayout(for piece: BlockPiece, presentation: PiecePresentation) -> PieceLayout {
        switch presentation {
        case .tray(let slotSize):
            let contentSize = CGSize(width: slotSize.width * 0.78, height: slotSize.height * 0.76)
            let spacing = max(3, min(slotSize.width, slotSize.height) * 0.045)
            return PieceLayout(piece: piece, maxSize: contentSize, spacing: spacing)

        case .floating(let boardLayout):
            let spacing = boardLayout.spacing
            let side = min(34, max(22, floor(boardLayout.blockSide * 0.78)))
            return PieceLayout(piece: piece, cellSide: side, spacing: spacing)
        }
    }

    static func boardPoint(from location: CGPoint, boardFrame: CGRect, layout: BoardLayout) -> GridPoint? {
        guard boardFrame.width > 0, boardFrame.height > 0, boardFrame.contains(location) else {
            return nil
        }

        let localX = location.x - boardFrame.minX - layout.padding
        let localY = location.y - boardFrame.minY - layout.padding

        guard localX >= 0, localY >= 0 else {
            return nil
        }

        let col = Int(localX / layout.cellStride)
        let row = Int(localY / layout.cellStride)

        guard row >= 0, row < layout.rows, col >= 0, col < layout.columns else {
            return nil
        }

        return GridPoint(row: row, col: col)
    }

    private static var boardFrameExtra: CGFloat {
        boardPadding * 2 - boardSpacing
    }

    private static func clamped(_ value: Int, min lowerBound: Int, max upperBound: Int) -> Int {
        Swift.min(Swift.max(value, lowerBound), upperBound)
    }
}
