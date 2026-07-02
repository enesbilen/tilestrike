import SwiftUI

struct PieceLayout {
    let cellSide: CGFloat
    let spacing: CGFloat
    let size: CGSize

    init(piece: BlockPiece, maxSize: CGSize, spacing: CGFloat = 4) {
        self.spacing = spacing

        let widthUnits = CGFloat(max(piece.width, 1))
        let heightUnits = CGFloat(max(piece.height, 1))
        let horizontalGaps = CGFloat(max(piece.width - 1, 0)) * spacing
        let verticalGaps = CGFloat(max(piece.height - 1, 0)) * spacing
        let maxCellWidth = max(1, maxSize.width - horizontalGaps) / widthUnits
        let maxCellHeight = max(1, maxSize.height - verticalGaps) / heightUnits
        let fittedCell = min(maxCellWidth, maxCellHeight)

        cellSide = max(8, fittedCell)
        size = CGSize(
            width: widthUnits * cellSide + horizontalGaps,
            height: heightUnits * cellSide + verticalGaps
        )
    }

    init(piece: BlockPiece, cellSide: CGFloat, spacing: CGFloat) {
        self.cellSide = max(1, cellSide)
        self.spacing = max(0, spacing)

        let widthUnits = CGFloat(max(piece.width, 1))
        let heightUnits = CGFloat(max(piece.height, 1))
        size = CGSize(
            width: widthUnits * self.cellSide + CGFloat(max(piece.width - 1, 0)) * self.spacing,
            height: heightUnits * self.cellSide + CGFloat(max(piece.height - 1, 0)) * self.spacing
        )
    }
}

struct BlockPieceView: View {
    let piece: BlockPiece
    let layout: PieceLayout
    var isFloating = false
    @AppStorage(AppSettings.blockStyleKey) private var selectedBlockStyle = BlockStyle.classic.rawValue

    private var blockStyle: BlockStyle {
        BlockStyle.current(rawValue: selectedBlockStyle)
    }

    var body: some View {
        let radius = min(layout.cellSide * 0.22, isFloating ? 8 : 5)

        ZStack {
            ForEach(piece.cells, id: \.self) { cell in
                blockView(radius: radius)
                    .position(
                        x: CGFloat(cell.col) * (layout.cellSide + layout.spacing) + layout.cellSide / 2,
                        y: CGFloat(cell.row) * (layout.cellSide + layout.spacing) + layout.cellSide / 2
                    )
            }
        }
        .frame(width: layout.size.width, height: layout.size.height, alignment: .topLeading)
    }

    @ViewBuilder
    private func blockView(radius: CGFloat) -> some View {
        if piece.isBomb {
            BombBlockView(side: layout.cellSide, radius: radius, isFloating: isFloating)
        } else {
            BlockSurfaceView(
                color: piece.color,
                style: blockStyle,
                cornerRadius: radius,
                side: layout.cellSide
            )
        }
    }
}

private struct BombBlockView: View {
    let side: CGFloat
    let radius: CGFloat
    let isFloating: Bool

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 24.0)) { context in
            let phase = context.date.timeIntervalSinceReferenceDate
            bombBody(phase: phase)
        }
        .frame(width: side, height: side)
    }

    private func bombBody(phase: TimeInterval) -> some View {
        let pulse = 0.5 + 0.5 * sin(phase * 3.2)
        let sparkPulse = 0.5 + 0.5 * sin(phase * 7.0)
        let glowOpacity = isFloating ? 0.42 + pulse * 0.28 : 0.20 + pulse * 0.16
        let flameSize = max(8, side * (0.26 + sparkPulse * 0.06))

        return ZStack {
            aura(pulse: pulse, glowOpacity: glowOpacity)
            shell
            energyRing(phase: phase, pulse: pulse)
            bombCore(pulse: pulse)
            fuse
            flame(size: flameSize, pulse: sparkPulse)
            glints(pulse: sparkPulse)
        }
        .frame(width: side, height: side)
    }

    private func aura(pulse: Double, glowOpacity: Double) -> some View {
        let glowColor = Color(red: 1.0, green: 0.56, blue: 0.16).opacity(glowOpacity)
        let lineWidth = max(1, side * 0.04)
        let blurRadius = isFloating ? 7 + pulse * 3 : 3 + pulse * 2
        let scale = 1.03 + pulse * 0.04

        return RoundedRectangle(cornerRadius: radius)
            .stroke(glowColor, lineWidth: lineWidth)
            .blur(radius: blurRadius)
            .scaleEffect(scale)
    }

    private var shell: some View {
        RoundedRectangle(cornerRadius: radius)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.22, green: 0.22, blue: 0.26),
                        Color(red: 0.06, green: 0.07, blue: 0.10)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                RoundedRectangle(cornerRadius: radius)
                    .stroke(.white.opacity(0.24), lineWidth: 1)
            }
            .overlay(alignment: .bottomLeading) {
                warningStripe
                    .padding(side * 0.10)
            }
    }

    private var warningStripe: some View {
        HStack(spacing: max(1, side * 0.025)) {
            ForEach(0..<3, id: \.self) { _ in
                Capsule()
                    .fill(Color(red: 1.0, green: 0.72, blue: 0.20).opacity(0.85))
                    .frame(width: max(2, side * 0.055), height: max(8, side * 0.24))
                    .rotationEffect(.degrees(28))
            }
        }
        .opacity(0.55)
    }

    private func energyRing(phase: TimeInterval, pulse: Double) -> some View {
        Circle()
            .trim(from: 0.08, to: 0.78)
            .stroke(
                AngularGradient(
                    colors: [
                        Color(red: 1.0, green: 0.86, blue: 0.28),
                        Color(red: 1.0, green: 0.34, blue: 0.16),
                        Color(red: 0.30, green: 0.86, blue: 1.0),
                        Color(red: 1.0, green: 0.86, blue: 0.28)
                    ],
                    center: .center
                ),
                style: StrokeStyle(lineWidth: max(1.2, side * 0.045), lineCap: .round)
            )
            .frame(width: side * 0.78, height: side * 0.78)
            .rotationEffect(.degrees(phase * 72))
            .opacity(isFloating ? 0.90 : 0.55 + pulse * 0.25)
            .shadow(color: Color(red: 1.0, green: 0.48, blue: 0.10).opacity(0.45), radius: isFloating ? 7 : 3)
    }

    private func bombCore(pulse: Double) -> some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Color.white.opacity(0.34),
                        Color(red: 0.12, green: 0.13, blue: 0.16),
                        Color.black
                    ],
                    center: .topLeading,
                    startRadius: 1,
                    endRadius: max(8, side * 0.58)
                )
            )
            .frame(width: side * 0.64, height: side * 0.64)
            .overlay {
                Circle()
                    .stroke(.white.opacity(0.22), lineWidth: 1)
            }
            .overlay(alignment: .topLeading) {
                Circle()
                    .fill(.white.opacity(0.30))
                    .frame(width: side * 0.14, height: side * 0.14)
                    .offset(x: side * 0.16, y: side * 0.15)
            }
            .shadow(color: .black.opacity(0.45), radius: isFloating ? 8 : 3, y: 2)
            .scaleEffect(1 + pulse * 0.025)
    }

    private var fuse: some View {
        Capsule()
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.62, green: 0.43, blue: 0.26),
                        Color(red: 0.23, green: 0.15, blue: 0.10)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: side * 0.12, height: side * 0.31)
            .overlay {
                Capsule()
                    .stroke(Color(red: 1.0, green: 0.78, blue: 0.42).opacity(0.28), lineWidth: 1)
            }
            .rotationEffect(.degrees(-38))
            .offset(x: side * 0.21, y: -side * 0.24)
    }

    private func flame(size: CGFloat, pulse: Double) -> some View {
        Image(systemName: "flame.fill")
            .font(.system(size: size, weight: .black))
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        Color.white,
                        Color(red: 1.0, green: 0.78, blue: 0.20),
                        Color(red: 1.0, green: 0.22, blue: 0.12)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .shadow(color: Color(red: 1.0, green: 0.36, blue: 0.08).opacity(0.9), radius: 4 + pulse * 3)
            .offset(x: side * 0.31, y: -side * 0.36)
            .rotationEffect(.degrees(-10 + pulse * 14))
    }

    private func glints(pulse: Double) -> some View {
        ZStack {
            Image(systemName: "sparkle")
                .font(.system(size: max(5, side * 0.15), weight: .black))
                .foregroundStyle(.white.opacity(0.85))
                .offset(x: -side * 0.23, y: -side * 0.20)

            Image(systemName: "sparkle")
                .font(.system(size: max(4, side * 0.11), weight: .black))
                .foregroundStyle(Color(red: 1.0, green: 0.76, blue: 0.20).opacity(0.80 + pulse * 0.20))
                .offset(x: side * 0.25, y: side * 0.20)
        }
    }
}

struct PieceSlotView: View {
    let piece: BlockPiece
    let isActive: Bool
    let size: CGSize

    var body: some View {
        let layout = GameLayout.pieceLayout(for: piece, presentation: .tray(slotSize: size))

        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(isActive ? Color.black.opacity(0.30) : Color.black.opacity(0.16))

            BlockPieceView(piece: piece, layout: layout)
        }
        .frame(width: size.width, height: size.height)
        .clipped()
        .opacity(isActive ? 0.28 : 1)
    }
}
