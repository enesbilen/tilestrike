import SwiftUI

enum BlockStyle: String, CaseIterable, Identifiable {
    case classic
    case wood
    case metallic

    var id: String { rawValue }

    var title: String {
        switch self {
        case .classic:
            return "Klasik"
        case .wood:
            return "Wood"
        case .metallic:
            return "Metallic"
        }
    }

    var subtitle: String {
        switch self {
        case .classic:
            return "Temiz renkli bloklar"
        case .wood:
            return "Sicak ahsap damarli yuzey"
        case .metallic:
            return "Parlak metalik yuzey"
        }
    }

    var iconName: String {
        switch self {
        case .classic:
            return "square.fill"
        case .wood:
            return "tree.fill"
        case .metallic:
            return "shield.lefthalf.filled"
        }
    }

    static func current(rawValue: String) -> BlockStyle {
        BlockStyle(rawValue: rawValue) ?? .classic
    }
}

struct BlockSurfaceView: View {
    let color: Color
    let style: BlockStyle
    let cornerRadius: CGFloat
    let side: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(baseFill)
            .overlay {
                styleOverlay
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: 1)
            }
            .shadow(color: shadowColor, radius: shadowRadius, y: shadowY)
            .frame(width: side, height: side)
    }

    private var baseFill: AnyShapeStyle {
        switch style {
        case .classic:
            return AnyShapeStyle(color)
        case .wood:
            return AnyShapeStyle(LinearGradient(
                colors: [
                    Color(red: 0.56, green: 0.32, blue: 0.15),
                    color.opacity(0.82),
                    Color(red: 0.30, green: 0.16, blue: 0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
        case .metallic:
            return AnyShapeStyle(LinearGradient(
                colors: [
                    Color.white.opacity(0.74),
                    color.opacity(0.92),
                    Color.black.opacity(0.32),
                    color.opacity(0.78)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
        }
    }

    @ViewBuilder
    private var styleOverlay: some View {
        switch style {
        case .classic:
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.18), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        case .wood:
            ZStack {
                ForEach(0..<4, id: \.self) { index in
                    Capsule()
                        .fill(Color(red: 0.96, green: 0.66, blue: 0.34).opacity(0.20))
                        .frame(width: side * 0.92, height: max(1.4, side * 0.035))
                        .rotationEffect(.degrees(index.isMultiple(of: 2) ? -8 : 7))
                        .offset(y: CGFloat(index - 2) * side * 0.18)
                }

                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.black.opacity(0.18), lineWidth: max(1, side * 0.04))
                    .blur(radius: 1.4)
            }
        case .metallic:
            ZStack {
                LinearGradient(
                    colors: [
                        .white.opacity(0.62),
                        .clear,
                        .black.opacity(0.18),
                        .white.opacity(0.20)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Capsule()
                    .fill(.white.opacity(0.46))
                    .frame(width: side * 0.82, height: max(2, side * 0.08))
                    .rotationEffect(.degrees(-28))
                    .offset(x: -side * 0.08, y: -side * 0.18)
            }
        }
    }

    private var borderColor: Color {
        switch style {
        case .classic:
            return .white.opacity(0.22)
        case .wood:
            return Color(red: 1.0, green: 0.76, blue: 0.42).opacity(0.28)
        case .metallic:
            return .white.opacity(0.42)
        }
    }

    private var shadowColor: Color {
        style == .metallic ? .white.opacity(0.10) : .black.opacity(0.16)
    }

    private var shadowRadius: CGFloat {
        style == .metallic ? 3 : 1
    }

    private var shadowY: CGFloat {
        style == .metallic ? 0 : 1
    }
}
