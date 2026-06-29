import SwiftUI

struct ScoreHistoryView: View {
    let onDismiss: () -> Void

    private let entries = ScoreHistory.shared.entries

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.07, green: 0.09, blue: 0.12),
                    Color(red: 0.12, green: 0.16, blue: 0.17)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Text("Skorlar")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .frame(width: 36, height: 36)
                            .foregroundStyle(.white.opacity(0.70))
                            .background(.white.opacity(0.10), in: Circle())
                    }
                    .accessibilityLabel("Kapat")
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 20)

                if entries.isEmpty {
                    Spacer()
                    Text("Henüz tamamlanmış oyun yok")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.38))
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                                ScoreRowView(rank: index + 1, entry: entry, isBest: index == 0)
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
    }
}

private struct ScoreRowView: View {
    let rank: Int
    let entry: ScoreEntry
    let isBest: Bool

    private let gold = Color(red: 1.0, green: 0.80, blue: 0.34)

    var body: some View {
        HStack(spacing: 12) {
            Text("#\(rank)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(isBest ? gold : .white.opacity(0.36))
                .frame(width: 30, alignment: .leading)

            Text("\(entry.score)")
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundStyle(isBest ? gold : .white)

            Spacer()

            Text(entry.date.formatted(.dateTime.day().month(.abbreviated).year()))
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.38))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .background(.white.opacity(isBest ? 0.10 : 0.06), in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            if isBest {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(gold.opacity(0.30), lineWidth: 1)
            }
        }
    }
}
