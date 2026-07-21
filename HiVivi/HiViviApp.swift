
import SwiftUI

@main
struct HiViviApp: App {
    @UIApplicationDelegateAdaptor(VellumOrbitAppDelegate.self)
    private var vellumOrbitAppDelegate

    var body: some Scene {
        WindowGroup {
            QuiescentMorrowBPackageRoot()
            .environment(\.font, VoiceWhisperFontKit.regular(14))
            .prismTrailPulseToastLoadingOverlay()
            .lunarCoveGuestLimitOverlay()
            .onAppear {
                HiViviDeferredLaunchCoordinator.startIfNeeded()
            }
        }
    }
}

@MainActor
private enum HiViviDeferredLaunchCoordinator {
    private static var hasStarted = false

    static func startIfNeeded() {
        guard hasStarted == false else { return }
        hasStarted = true

        // Give SwiftUI's first frame priority over analytics and local seed maintenance.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            VellumOrbitAdjustManager.shared.vellumOrbitStartLaunchInitialization()
            SonicSeedDataBootstrap.initializeLocalDataIfNeeded()
        }
    }
}
