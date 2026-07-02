import Foundation
import GoogleMobileAds

@MainActor
final class AdMobService: NSObject, FullScreenContentDelegate {
    static let shared = AdMobService()

    #if DEBUG
    private let gameOverInterstitialUnitID = "ca-app-pub-3940256099942544/4411468910"
    #else
    private let gameOverInterstitialUnitID = "ca-app-pub-1773816265483184/4173051432"
    #endif

    private var interstitialAd: InterstitialAd?
    private var isLoading = false
    private var gameOverCount = 0
    private var lastShownAt: Date?
    private let showEveryGameOverCount = 4
    private let minimumSecondsBetweenAds: TimeInterval = 120

    private override init() {
        super.init()
    }

    func start() {
        MobileAds.shared.start()
        Task {
            await loadGameOverAd()
        }
    }

    func showGameOverAdIfNeeded() {
        gameOverCount += 1

        guard gameOverCount >= showEveryGameOverCount, canShowAnotherAdNow else {
            if interstitialAd == nil {
                Task {
                    await loadGameOverAd()
                }
            }
            return
        }

        gameOverCount = 0

        guard let interstitialAd else {
            Task {
                await loadGameOverAd()
            }
            return
        }

        interstitialAd.present(from: nil)
        lastShownAt = Date()
    }

    private var canShowAnotherAdNow: Bool {
        guard let lastShownAt else { return true }
        return Date().timeIntervalSince(lastShownAt) >= minimumSecondsBetweenAds
    }

    private func loadGameOverAd() async {
        guard !isLoading, interstitialAd == nil else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let ad = try await InterstitialAd.load(
                with: gameOverInterstitialUnitID,
                request: Request()
            )
            ad.fullScreenContentDelegate = self
            interstitialAd = ad
        } catch {
            interstitialAd = nil
        }
    }

    func ad(
        _ ad: FullScreenPresentingAd,
        didFailToPresentFullScreenContentWithError error: Error
    ) {
        interstitialAd = nil
        Task {
            await loadGameOverAd()
        }
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        interstitialAd = nil
        Task {
            await loadGameOverAd()
        }
    }
}
