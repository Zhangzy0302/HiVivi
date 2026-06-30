
import SwiftUI

@main
struct HiViviApp: App {
    init() {
        VoiceWhisperFontKit.registerFonts()
        SonicSeedDataBootstrap.initializeLocalDataIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            NavigationView {
                AmberStoneMaskGuideAuthPage()
                    .navigationBarHidden(true)
                    .voiceNativeSwipeBackEnabled()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .environment(\.font, VoiceWhisperFontKit.regular(14))
            .prismTrailPulseToastLoadingOverlay()
            .lunarCoveGuestLimitOverlay()
        }
    }
}
