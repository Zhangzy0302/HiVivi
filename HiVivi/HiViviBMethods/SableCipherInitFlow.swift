import Combine
import CoreLocation
import Foundation

enum SableCipherBRoute {
    case sableCipherAgreement(sableCipherURL: String)
}

enum SableCipherInitStatus {
    case sableCipherLoading
    case sableCipherB
    case sableCipherA
}

private enum SableCipherPollingPolicy {
    static let sableCipherRetryInterval: UInt64 = 2_000_000_000
}

private struct SableCipherDecision {
    let sableCipherValues: [String: Any]

    init?(sableCipherResponse: [String: Any]) {
        guard sableCipherResponse["code"] as? String == "0000",
              let sableCipherCiphertext = sableCipherResponse["result"] as? String else {
            return nil
        }

        let sableCipherPlaintext = sableCipherCiphertext.zephyrRuneBDecrypt()
        guard let sableCipherData = sableCipherPlaintext.data(using: .utf8),
              let sableCipherObject = try? JSONSerialization.jsonObject(with: sableCipherData),
              let sableCipherValues = sableCipherObject as? [String: Any] else {
            return nil
        }
        self.sableCipherValues = sableCipherValues
    }

    var sableCipherOpenAddress: String {
        sableCipherValues["openValue"] as? String ?? ""
    }

    var sableCipherAlreadyLoggedIn: Bool {
        Self.sableCipherInteger(sableCipherValues["loginFlag"]) == 1
    }

    var sableCipherNeedsLocation: Bool {
        Self.sableCipherInteger(sableCipherValues["locationFlag"]) == 1
    }

    private static func sableCipherInteger(_ sableCipherValue: Any?) -> Int {
        switch sableCipherValue {
        case let sableCipherInteger as Int:
            return sableCipherInteger
        case let sableCipherNumber as NSNumber:
            return sableCipherNumber.intValue
        case let sableCipherText as String:
            return Int(sableCipherText.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        default:
            return 0
        }
    }
}

private enum SableCipherSessionWriter {
    static func sableCipherStore(_ sableCipherValues: [String: Any]) {
        let sableCipherAccount = NacreWispBInfoStore.shared
        if sableCipherAccount.nacreWispPassword.isEmpty,
           let sableCipherPassword = sableCipherValues["password"] as? String {
            sableCipherAccount.nacreWispPassword = sableCipherPassword
        }
        if let sableCipherToken = sableCipherValues["token"] as? String {
            NacreWispAppStorage.nacreWispUserToken = sableCipherToken
        }
    }
}

final class SableCipherInitUtils {
    static let shared = SableCipherInitUtils()

    var sableCipherShouldFetchLocation = true

    private init() {}

    func sableCipherGoLogin() async -> SableCipherBRoute? {
        do {
            if sableCipherShouldFetchLocation {
                try await sableCipherCollectLocation()
            }

            guard let sableCipherResponse = try await AbyssalQuillApiCall().abyssalQuillQuickLogin() else {
                sableCipherShowToast("error")
                return nil
            }
            guard sableCipherResponse["code"] as? String == "0000" else {
                sableCipherShowToast("Login Error")
                return nil
            }
            guard let sableCipherDecision = SableCipherDecision(sableCipherResponse: sableCipherResponse) else {
                return nil
            }

            SableCipherSessionWriter.sableCipherStore(sableCipherDecision.sableCipherValues)
            guard let sableCipherURL = sableCipherAuthenticatedURL() else {
                return nil
            }
            return .sableCipherAgreement(sableCipherURL: sableCipherURL.absoluteString)
        } catch {
            sableCipherShowToast("error")
            return nil
        }
    }

    func sableCipherAuthenticatedURL() -> URL? {
        let sableCipherAddress = ZephyrRuneInformationCreate.zephyrRuneBuildH5Url(
            baseUrl: NacreWispAppStorage.nacreWispH5Url,
            token: NacreWispAppStorage.nacreWispUserToken
        )
        return URL(string: sableCipherAddress)
    }

    private func sableCipherCollectLocation() async throws {
        guard let sableCipherPlacemark = await ZephyrRuneLocationManager.shared
            .zephyrRuneGetCurrentLocationAndAddress() else {
            throw SableCipherInitError.sableCipherLocationUnavailable
        }
        guard let sableCipherLocation = sableCipherPlacemark.location else { return }
        ZephyrRunePhoneInfo.shared.zephyrRuneLatitude = sableCipherLocation.coordinate.latitude
        ZephyrRunePhoneInfo.shared.zephyrRuneLongitude = sableCipherLocation.coordinate.longitude
    }

    @MainActor
    private func sableCipherShowToast(_ sableCipherMessage: String) {
        PrismTrailPulseToastLoadingCenter.shared.showToast(sableCipherMessage, kind: .error)
    }
}

@MainActor
final class SableCipherInitViewModel: ObservableObject {
    @Published var sableCipherStatus: SableCipherInitStatus = .sableCipherLoading
    @Published var sableCipherNextRoute: SableCipherBRoute?

    func sableCipherInitFlow() async {
        guard sableCipherCanRequestDecision() else {
            sableCipherStatus = .sableCipherA
            return
        }

        await ZephyrRunePhoneInfo.shared.zephyrRuneGetPhoneInfo()
        await MadrigalFallowPushReadiness.madrigalFallowWaitForToken()

        guard let sableCipherResponse = await sableCipherFetchDecisionUntilResponse() else {
            return
        }

        guard let sableCipherDecision = SableCipherDecision(sableCipherResponse: sableCipherResponse),
              let sableCipherOpenURL = ZephyrRuneInformationCreate.zephyrRuneResolveH5URL(
                sableCipherDecision.sableCipherOpenAddress
              ) else {
            sableCipherStatus = .sableCipherA
            return
        }

        NacreWispAppStorage.nacreWispIsB = true
        NacreWispAppStorage.nacreWispH5Url = sableCipherOpenURL.absoluteString
        SableCipherSessionWriter.sableCipherStore(sableCipherDecision.sableCipherValues)

        let sableCipherLoginReady = sableCipherDecision.sableCipherAlreadyLoggedIn
            && NacreWispAppStorage.nacreWispUserToken.isEmpty == false
        if sableCipherLoginReady,
           let sableCipherURL = SableCipherInitUtils.shared.sableCipherAuthenticatedURL() {
            sableCipherNextRoute = .sableCipherAgreement(sableCipherURL: sableCipherURL.absoluteString)
        } else {
            await sableCipherPrepareGuestEntry(sableCipherDecision)
        }
        sableCipherStatus = .sableCipherB
    }

    private func sableCipherFetchDecisionUntilResponse() async -> [String: Any]? {
        while Task.isCancelled == false {
            do {
                if let sableCipherResponse = try await AbyssalQuillApiCall().abyssalQuillGetDecision() {
                    return sableCipherResponse
                }
            } catch {}

            do {
                try await Task.sleep(nanoseconds: SableCipherPollingPolicy.sableCipherRetryInterval)
            } catch {
                return nil
            }
        }

        return nil
    }

    private func sableCipherPrepareGuestEntry(_ sableCipherDecision: SableCipherDecision) async {
        SableCipherInitUtils.shared.sableCipherShouldFetchLocation = sableCipherDecision.sableCipherNeedsLocation
        if sableCipherDecision.sableCipherNeedsLocation {
            _ = await ZephyrRuneLocationManager.shared.zephyrRuneCheckAndRequestLocation()
        }
    }

    private func sableCipherCanRequestDecision() -> Bool {
        guard let sableCipherDate = Calendar.current.date(
            from: ZephyrRuneInformationCreate.zephyrRuneVerifyDate
        ) else {
            return false
        }
        return Date() >= sableCipherDate
    }
}

private enum SableCipherInitError: Error {
    case sableCipherLocationUnavailable
}
