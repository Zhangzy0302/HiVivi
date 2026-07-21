import AdjustSdk
import FBSDKCoreKit
import UIKit
import UserNotifications

final class VellumOrbitAdjustManager: NSObject, AdjustDelegate {
    static let shared = VellumOrbitAdjustManager()

    private struct VellumOrbitTokens {
        let vellumOrbitInstall = "r6m63f"
        let vellumOrbitPurchase = "ofcax7"
        let vellumOrbitApplication = "3tn9dmfx6tds"
    }

    private enum VellumOrbitLaunchStage {
        case vellumOrbitIdle
        case vellumOrbitCollectingDevice
        case vellumOrbitReady
    }

    private let vellumOrbitTokens = VellumOrbitTokens()
    private var vellumOrbitStage = VellumOrbitLaunchStage.vellumOrbitIdle
    private var vellumOrbitSDKStarted = false

    private override init() {}

    func vellumOrbitStartLaunchInitialization() {
        guard vellumOrbitStage == .vellumOrbitIdle else { return }
        vellumOrbitStage = .vellumOrbitCollectingDevice

        Task { @MainActor [weak self] in
            await ZephyrRunePhoneInfo.shared.zephyrRuneGetPhoneInfo()
            self?.vellumOrbitInitialize()
            self?.vellumOrbitStage = .vellumOrbitReady
        }
    }

    func vellumOrbitInitialize() {
        guard vellumOrbitSDKStarted == false,
              let vellumOrbitConfiguration = vellumOrbitMakeConfiguration() else {
            return
        }

        Adjust.addGlobalCallbackParameter(
            NacreWispBInfoStore.shared.nacreWispDeviceId,
            forKey: "ta_distinct_id"
        )
        Adjust.attribution { [weak self] vellumOrbitAttribution in
            self?.adjustAttributionChanged(vellumOrbitAttribution)
        }
        Adjust.initSdk(vellumOrbitConfiguration)
        vellumOrbitSDKStarted = true
    }

    func adjustAttributionChanged(_ attribution: ADJAttribution?) {
        Adjust.trackEvent(ADJEvent(eventToken: vellumOrbitTokens.vellumOrbitInstall))
    }

    func vellumOrbitTrackPurchase(dollar: Double) {
        let vellumOrbitEvent = ADJEvent(eventToken: vellumOrbitTokens.vellumOrbitPurchase)
        vellumOrbitEvent?.setRevenue(dollar, currency: "USD")
        Adjust.trackEvent(vellumOrbitEvent)
        vellumOrbitTrackFacebookPurchase(price: dollar)
    }

    private func vellumOrbitTrackFacebookPurchase(price vellumOrbitPrice: Double) {
        AppEvents.shared.logPurchase(
            amount: vellumOrbitPrice,
            currency: "USD",
            parameters: [
                AppEvents.ParameterName(rawValue: "fb_mobile_purchase"): "true"
            ]
        )
    }

    private func vellumOrbitMakeConfiguration() -> ADJConfig? {
        guard ZephyrRuneInformationCreate.zephyrRuneAdjustEnabled else { return nil }

        #if DEBUG
        let vellumOrbitEnvironment = ADJEnvironmentSandbox
        let vellumOrbitLogLevel = ADJLogLevel.debug
        #else
        let vellumOrbitEnvironment = ADJEnvironmentProduction
        let vellumOrbitLogLevel = ADJLogLevel.suppress
        #endif

        guard let vellumOrbitConfiguration = ADJConfig(
            appToken: vellumOrbitTokens.vellumOrbitApplication,
            environment: vellumOrbitEnvironment
        ) else {
            return nil
        }
        vellumOrbitConfiguration.logLevel = vellumOrbitLogLevel
        vellumOrbitConfiguration.enableSendingInBackground()
        vellumOrbitConfiguration.delegate = self
        return vellumOrbitConfiguration
    }
}

enum MadrigalFallowPushReadiness {
    static func madrigalFallowWaitForToken() async {
        guard ZephyrRuneInformationCreate.zephyrRunePushEnabled,
              NacreWispAppStorage.nacreWispPushToken.isEmpty else {
            return
        }

        let madrigalFallowDeadline = Date().addingTimeInterval(
            ZephyrRuneInformationCreate.zephyrRunePushTokenWaitTimeout
        )
        while NacreWispAppStorage.nacreWispPushToken.isEmpty,
              Date() < madrigalFallowDeadline {
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
    }
}

final class MadrigalFallowPushCoordinator {
    static let shared = MadrigalFallowPushCoordinator()

    private var madrigalFallowDidRequestAuthorization = false

    private init() {}

    @MainActor
    func madrigalFallowRequestAuthorization() {
        guard ZephyrRuneInformationCreate.zephyrRunePushEnabled,
              madrigalFallowDidRequestAuthorization == false else {
            return
        }
        madrigalFallowDidRequestAuthorization = true

        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { madrigalFallowGranted, _ in
            guard madrigalFallowGranted else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    func madrigalFallowStore(_ madrigalFallowDeviceToken: Data) {
        NacreWispAppStorage.nacreWispPushToken = madrigalFallowDeviceToken
            .map { String(format: "%02.2hhx", $0) }
            .joined()
    }
}

final class VellumOrbitAppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    private let vellumOrbitPushCoordinator = MadrigalFallowPushCoordinator.shared

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        VellumOrbitAdjustManager.shared.vellumOrbitStartLaunchInitialization()

        if ZephyrRuneInformationCreate.zephyrRunePushEnabled {
            UNUserNotificationCenter.current().delegate = self
            application.registerForRemoteNotifications()
        }
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        vellumOrbitPushCoordinator.madrigalFallowStore(deviceToken)
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError _: Error
    ) {}
}
