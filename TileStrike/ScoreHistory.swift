import Foundation

struct ScoreEntry: Codable, Identifiable {
    let id: UUID
    let score: Int
    let date: Date

    init(score: Int) {
        self.id = UUID()
        self.score = score
        self.date = Date()
    }
}

final class ScoreHistory {
    static let shared = ScoreHistory()

    private(set) var entries: [ScoreEntry] = []
    private let key = "scoreHistory_v1"
    private let maxEntries = 10

    private init() { load() }

    func record(score: Int) {
        guard score > 0 else { return }
        entries.insert(ScoreEntry(score: score), at: 0)
        if entries.count > maxEntries {
            entries = Array(entries.prefix(maxEntries))
        }
        persist()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([ScoreEntry].self, from: data)
        else { return }
        entries = decoded
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
