import Foundation

enum GameMode: String, CaseIterable, Identifiable {
    case classic
    case bombRush
    case zen
    case magnet

    var id: String { rawValue }

    var title: String {
        switch self {
        case .classic:
            return "Klasik"
        case .bombRush:
            return "Bomb Rush"
        case .zen:
            return "Zen"
        case .magnet:
            return "Magnet"
        }
    }

    var subtitle: String {
        switch self {
        case .classic:
            return "Dengeli blok bulmaca akışı"
        case .bombRush:
            return "Daha sık bomba, daha yüksek çizgi puanı"
        case .zen:
            return "Sıkışınca kurtarıcı tekli parça"
        case .magnet:
            return "Çizgi patlayınca bloklar merkeze çekilir"
        }
    }

    var iconName: String {
        switch self {
        case .classic:
            return "square.grid.3x3.fill"
        case .bombRush:
            return "burst.fill"
        case .zen:
            return "leaf.fill"
        case .magnet:
            return "dot.scope"
        }
    }

    var startMessage: String {
        switch self {
        case .classic:
            return "Klasik mod başladı"
        case .bombRush:
            return "Bomb Rush başladı"
        case .zen:
            return "Zen mod başladı"
        case .magnet:
            return "Magnet mod başladı"
        }
    }

    static func current(rawValue: String) -> GameMode {
        GameMode(rawValue: rawValue) ?? .classic
    }
}
