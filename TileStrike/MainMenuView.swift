import SwiftUI

struct MainMenuView: View {
    let hasActiveGame: Bool
    let onContinue: () -> Void
    let onNewGame: () -> Void
    let onScores: () -> Void

    @AppStorage("bestScore") private var bestScore = 0

    var body: some View {
        ZStack {
            Image("MenuBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color.black.opacity(0.14),
                    Color.black.opacity(0.28),
                    Color.black.opacity(0.48)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Color(red: 0.05, green: 0.07, blue: 0.09)
                .opacity(0.18)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 10) {
                    Text("TileStrike")
                        .font(.system(size: 52, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Satır ya da sütunu doldur, patlat")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.55))

                    if bestScore > 0 {
                        Text("Rekor \(bestScore)")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(red: 1.0, green: 0.80, blue: 0.34))
                            .padding(.top, 6)
                    }
                }

                Spacer()

                VStack(spacing: 12) {
                    if hasActiveGame {
                        Button(action: onContinue) {
                            Label("Devam Et", systemImage: "play.fill")
                                .font(.title3.weight(.heavy))
                                .foregroundStyle(Color(red: 0.08, green: 0.10, blue: 0.13))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 1.0, green: 0.82, blue: 0.32),
                                            Color(red: 1.0, green: 0.62, blue: 0.22)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    in: RoundedRectangle(cornerRadius: 16)
                                )
                        }
                        .accessibilityLabel("Devam et")

                        Button(action: onNewGame) {
                            Label("Yeni Oyun", systemImage: "arrow.counterclockwise")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.white.opacity(0.80))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(.white.opacity(0.09), in: RoundedRectangle(cornerRadius: 16))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(.white.opacity(0.14), lineWidth: 1)
                                }
                        }
                        .accessibilityLabel("Yeni oyun başlat")
                    } else {
                        Button(action: onNewGame) {
                            Label("Oyna", systemImage: "play.fill")
                                .font(.title3.weight(.heavy))
                                .foregroundStyle(Color(red: 0.08, green: 0.10, blue: 0.13))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 1.0, green: 0.82, blue: 0.32),
                                            Color(red: 1.0, green: 0.62, blue: 0.22)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    in: RoundedRectangle(cornerRadius: 16)
                                )
                        }
                        .accessibilityLabel("Oyunu başlat")
                    }

                    Button(action: onScores) {
                        Label("Skorlar", systemImage: "list.number")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white.opacity(0.80))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(.white.opacity(0.09), in: RoundedRectangle(cornerRadius: 16))
                            .overlay {
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.white.opacity(0.14), lineWidth: 1)
                            }
                    }
                    .accessibilityLabel("Skor geçmişini görüntüle")
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 56)
            }
        }
    }
}
