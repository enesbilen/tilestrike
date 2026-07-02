import SwiftUI

enum GameTheme: String, CaseIterable, Identifiable {
    case ember
    case neon
    case ocean

    var id: String { rawValue }

    var title: String {
        switch self {
        case .ember:
            return "Klasik"
        case .neon:
            return "Neon"
        case .ocean:
            return "Ocean"
        }
    }

    var subtitle: String {
        switch self {
        case .ember:
            return "Sıcak vurgu, koyu pano"
        case .neon:
            return "Canlı arcade renkleri"
        case .ocean:
            return "Serin ve temiz görünüm"
        }
    }

    var iconName: String {
        switch self {
        case .ember:
            return "flame.fill"
        case .neon:
            return "bolt.fill"
        case .ocean:
            return "drop.fill"
        }
    }

    var background: [Color] {
        switch self {
        case .ember:
            return [
                Color(red: 0.07, green: 0.09, blue: 0.12),
                Color(red: 0.12, green: 0.16, blue: 0.17)
            ]
        case .neon:
            return [
                Color(red: 0.04, green: 0.05, blue: 0.12),
                Color(red: 0.12, green: 0.04, blue: 0.18)
            ]
        case .ocean:
            return [
                Color(red: 0.03, green: 0.12, blue: 0.15),
                Color(red: 0.06, green: 0.21, blue: 0.22)
            ]
        }
    }

    var accent: Color {
        switch self {
        case .ember:
            return Color(red: 1.0, green: 0.72, blue: 0.24)
        case .neon:
            return Color(red: 0.62, green: 0.92, blue: 1.0)
        case .ocean:
            return Color(red: 0.42, green: 0.92, blue: 0.78)
        }
    }

    var buttonText: Color {
        switch self {
        case .ember:
            return Color(red: 0.08, green: 0.10, blue: 0.13)
        case .neon:
            return Color(red: 0.02, green: 0.04, blue: 0.09)
        case .ocean:
            return Color(red: 0.02, green: 0.08, blue: 0.09)
        }
    }

    var buttonGradient: [Color] {
        switch self {
        case .ember:
            return [
                Color(red: 1.0, green: 0.82, blue: 0.32),
                Color(red: 1.0, green: 0.62, blue: 0.22)
            ]
        case .neon:
            return [
                Color(red: 0.54, green: 0.94, blue: 1.0),
                Color(red: 0.95, green: 0.46, blue: 1.0)
            ]
        case .ocean:
            return [
                Color(red: 0.46, green: 0.94, blue: 0.78),
                Color(red: 0.34, green: 0.70, blue: 1.0)
            ]
        }
    }

    var emptyCell: Color {
        switch self {
        case .ember:
            return Color.white.opacity(0.08)
        case .neon:
            return Color(red: 0.58, green: 0.88, blue: 1.0).opacity(0.10)
        case .ocean:
            return Color(red: 0.78, green: 1.0, blue: 0.92).opacity(0.10)
        }
    }

    var panelOpacity: Double {
        switch self {
        case .ember:
            return 0.08
        case .neon:
            return 0.11
        case .ocean:
            return 0.09
        }
    }

    var palette: [Color] {
        switch self {
        case .ember:
            return [
                Color(red: 0.20, green: 0.78, blue: 0.70),
                Color(red: 0.97, green: 0.42, blue: 0.38),
                Color(red: 1.00, green: 0.75, blue: 0.30),
                Color(red: 0.40, green: 0.58, blue: 0.98),
                Color(red: 0.66, green: 0.50, blue: 0.98),
                Color(red: 0.47, green: 0.83, blue: 0.42)
            ]
        case .neon:
            return [
                Color(red: 0.20, green: 0.95, blue: 1.00),
                Color(red: 1.00, green: 0.34, blue: 0.92),
                Color(red: 0.77, green: 1.00, blue: 0.30),
                Color(red: 0.54, green: 0.48, blue: 1.00),
                Color(red: 1.00, green: 0.54, blue: 0.20),
                Color(red: 0.38, green: 1.00, blue: 0.64)
            ]
        case .ocean:
            return [
                Color(red: 0.28, green: 0.82, blue: 0.76),
                Color(red: 0.35, green: 0.62, blue: 0.96),
                Color(red: 0.62, green: 0.88, blue: 0.52),
                Color(red: 0.95, green: 0.70, blue: 0.36),
                Color(red: 0.53, green: 0.78, blue: 0.95),
                Color(red: 0.72, green: 0.62, blue: 0.92)
            ]
        }
    }

    static func current(rawValue: String) -> GameTheme {
        GameTheme(rawValue: rawValue) ?? .ember
    }
}
