import SwiftUI

struct ScoreHeaderView: View {
    let score: Int
    let bestScore: Int
    let bestScorePulse: Bool
    let theme: GameTheme
    let onMenu: () -> Void
    let onReset: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Button(action: onMenu) {
                Image(systemName: "house")
                    .font(.system(size: 16, weight: .bold))
                    .frame(width: 40, height: 40)
                    .foregroundStyle(.white.opacity(0.75))
                    .background(.white.opacity(0.10), in: Circle())
            }
            .accessibilityLabel("Ana menüye dön")

            Text("TileStrike")
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(score)")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(theme.accent)
                Text("Rekor \(bestScore)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(bestScorePulse ? theme.accent : .white.opacity(0.62))
                    .scaleEffect(bestScorePulse ? 1.13 : 1)
                    .shadow(color: theme.accent.opacity(bestScorePulse ? 0.70 : 0), radius: 10)
            }

            Button(action: onReset) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 17, weight: .bold))
                    .frame(width: 40, height: 40)
                    .foregroundStyle(.white)
                    .background(.white.opacity(0.10), in: Circle())
            }
            .accessibilityLabel("Oyunu yeniden başlat")
        }
    }
}

struct GameOverOverlayView: View {
    let score: Int
    let bestScore: Int
    let isNewRecord: Bool
    let theme: GameTheme
    let onPlayAgain: () -> Void
    let onMenu: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.46)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                VStack(spacing: 8) {
                    Text(isNewRecord ? "Yeni Rekor!" : "Oyun Bitti")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundStyle(isNewRecord ? theme.accent : .white)

                    Text("Skor \(score)")
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white.opacity(0.90))

                    Text("Rekor \(bestScore)")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white.opacity(0.64))
                }

                VStack(spacing: 10) {
                    Button(action: onPlayAgain) {
                        Label("Tekrar Oyna", systemImage: "play.fill")
                            .font(.headline.weight(.heavy))
                            .foregroundStyle(theme.buttonText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(
                                LinearGradient(
                                    colors: theme.buttonGradient,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                in: RoundedRectangle(cornerRadius: 16)
                            )
                    }
                    .accessibilityLabel("Tekrar oyna")

                    Button(action: onMenu) {
                        Label("Ana Menü", systemImage: "house")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.white.opacity(0.75))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(.white.opacity(0.09), in: RoundedRectangle(cornerRadius: 14))
                            .overlay {
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(.white.opacity(0.14), lineWidth: 1)
                            }
                    }
                    .accessibilityLabel("Ana menüye dön")
                }
            }
            .padding(22)
            .frame(maxWidth: 330)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(.white.opacity(0.18), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.30), radius: 28, y: 16)
            .padding(.horizontal, 28)
        }
    }
}

struct GameBoardView: View {
    let board: [[Color?]]
    let rows: Int
    let columns: Int
    let layout: BoardLayout
    let previewCells: Set<GridPoint>
    let invalidPreviewCells: Set<GridPoint>
    let lineClearCells: Set<GridPoint>
    let previewColor: Color?
    let theme: GameTheme
    @AppStorage(AppSettings.blockStyleKey) private var selectedBlockStyle = BlockStyle.classic.rawValue

    private var blockStyle: BlockStyle {
        BlockStyle.current(rawValue: selectedBlockStyle)
    }

    var body: some View {
        VStack(spacing: layout.spacing) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: layout.spacing) {
                    ForEach(0..<columns, id: \.self) { col in
                        let point = GridPoint(row: row, col: col)
                        let isClearing = lineClearCells.contains(point)
                        cellView(at: point)
                            .overlay {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.white.opacity(previewCells.contains(point) ? 0.8 : 0.08), lineWidth: 1)
                            }
                            .overlay {
                                if isClearing {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white.opacity(0.72))
                                        .transition(.opacity)
                                }
                            }
                            .frame(width: layout.blockSide, height: layout.blockSide)
                            .scaleEffect(isClearing ? 1.08 : (previewCells.contains(point) ? 0.94 : 1))
                            .animation(.easeOut(duration: 0.18), value: lineClearCells)
                            .animation(.spring(response: 0.22, dampingFraction: 0.72), value: previewCells)
                    }
                }
            }
        }
        .padding(layout.padding)
        .frame(width: layout.size.width, height: layout.size.height)
        .background(Color.white.opacity(theme.panelOpacity), in: RoundedRectangle(cornerRadius: 22))
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .stroke(.white.opacity(0.14), lineWidth: 1)
        }
    }

    @ViewBuilder
    private func cellView(at point: GridPoint) -> some View {
        let color = cellColor(at: point)

        if shouldUseBlockStyle(at: point) {
            BlockSurfaceView(
                color: color,
                style: blockStyle,
                cornerRadius: 8,
                side: layout.blockSide
            )
        } else {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: layout.blockSide, height: layout.blockSide)
        }
    }

    private func cellColor(at point: GridPoint) -> Color {
        if invalidPreviewCells.contains(point) {
            return Color(red: 1.0, green: 0.20, blue: 0.18).opacity(0.55)
        }

        if previewCells.contains(point), let previewColor {
            return previewColor.opacity(0.68)
        }

        guard board.indices.contains(point.row), board[point.row].indices.contains(point.col) else {
            return theme.emptyCell
        }

        return board[point.row][point.col] ?? theme.emptyCell
    }

    private func shouldUseBlockStyle(at point: GridPoint) -> Bool {
        if invalidPreviewCells.contains(point) {
            return false
        }

        if previewCells.contains(point) {
            return true
        }

        guard board.indices.contains(point.row), board[point.row].indices.contains(point.col) else {
            return false
        }

        return board[point.row][point.col] != nil
    }
}

struct PieceTrayView: View {
    let choices: [BlockPiece]
    let activePieceID: UUID?
    let slotCount: Int
    let slotSize: CGSize
    let slotSpacing: CGFloat
    let horizontalPadding: CGFloat
    let theme: GameTheme
    let onDragChanged: (BlockPiece, DragGesture.Value) -> Void
    let onDragEnded: (BlockPiece, DragGesture.Value) -> Void

    var body: some View {
        HStack(spacing: slotSpacing) {
            ForEach(choices) { piece in
                PieceSlotView(piece: piece, isActive: activePieceID == piece.id, size: slotSize)
                    .gesture(
                        DragGesture(minimumDistance: 4, coordinateSpace: .global)
                            .onChanged { onDragChanged(piece, $0) }
                            .onEnded { onDragEnded(piece, $0) }
                    )
            }

            ForEach(0..<max(0, slotCount - choices.count), id: \.self) { _ in
                EmptyPieceSlotView(size: slotSize)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(horizontalPadding)
        .background(.white.opacity(theme.panelOpacity), in: RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(.white.opacity(0.13), lineWidth: 1)
        }
    }
}

private struct EmptyPieceSlotView: View {
    let size: CGSize

    var body: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(.black.opacity(0.08))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(.white.opacity(0.05), lineWidth: 1)
            }
            .frame(width: size.width, height: size.height)
    }
}
