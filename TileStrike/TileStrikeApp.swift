import SwiftUI
import GoogleMobileAds

@main
struct TileStrikeApp: App {
    init() {
        AdMobService.shared.start()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
