import Foundation
import SystemConfiguration.CaptiveNetwork
import UIKit

final class ZephyrRunePhoneInfo {
    static let shared = ZephyrRunePhoneInfo()

    private let zephyrRuneCollectionGate = ZephyrRunePhoneInfoCollectionGate()

    var zephyrRuneLanguages: [String] = []
    var zephyrRuneCountryCode = ""
    var zephyrRuneLatitude: Double = 0
    var zephyrRuneLongitude: Double = 0
    var zephyrRuneCoverAppList: [String] = []
    var zephyrRuneKeyboards: [String] = []
    var zephyrRuneTimezone = ""
    var zephyrRuneIsVpnActive = 0

    func zephyrRuneGetPhoneInfo() async {
        let zephyrRuneSnapshot = await zephyrRuneCollectionGate.zephyrRuneSnapshot()
        zephyrRuneLanguages = zephyrRuneSnapshot.zephyrRuneLanguages
        zephyrRuneTimezone = zephyrRuneSnapshot.zephyrRuneTimezone
        zephyrRuneIsVpnActive = zephyrRuneSnapshot.zephyrRuneIsVpnActive
        zephyrRuneCoverAppList = zephyrRuneSnapshot.zephyrRuneCoverAppList
        zephyrRuneKeyboards = zephyrRuneSnapshot.zephyrRuneKeyboards

        if NacreWispBInfoStore.shared.nacreWispDeviceId.isEmpty {
            NacreWispBInfoStore.shared.nacreWispDeviceId = zephyrRuneSnapshot.zephyrRuneDeviceId
        }
    }

    func zephyrRuneGetLanguages() async {
        zephyrRuneLanguages = Locale.preferredLanguages
    }

    func zephyrRuneGetTimezone() async {
        zephyrRuneTimezone = TimeZone.current.identifier
    }

    func zephyrRuneCheckVPN() async {
        zephyrRuneIsVpnActive = PalimpsestNocturneProbe.palimpsestNocturneVPNActive() ? 1 : 0
    }

    func zephyrRuneGetInstalledApps() async {
        zephyrRuneCoverAppList = await PalimpsestNocturneProbe.palimpsestNocturneInstalledApps()
    }

    func zephyrRuneGetSystemKeyboards() async {
        zephyrRuneKeyboards = await PalimpsestNocturneProbe.palimpsestNocturneKeyboards()
    }

    func zephyrRuneGetDeviceId(appId zephyrRuneAppId: String) async -> String {
        (UIDevice.current.identifierForVendor?.uuidString ?? "") + zephyrRuneAppId
    }

}

private struct ZephyrRunePhoneInfoSnapshot {
    let zephyrRuneLanguages: [String]
    let zephyrRuneTimezone: String
    let zephyrRuneIsVpnActive: Int
    let zephyrRuneCoverAppList: [String]
    let zephyrRuneKeyboards: [String]
    let zephyrRuneDeviceId: String

    static func zephyrRuneCollect() async -> ZephyrRunePhoneInfoSnapshot {
        async let zephyrRuneApps = PalimpsestNocturneProbe.palimpsestNocturneInstalledApps()
        async let zephyrRuneKeyboards = PalimpsestNocturneProbe.palimpsestNocturneKeyboards()
        async let zephyrRuneDeviceId = MainActor.run {
            (UIDevice.current.identifierForVendor?.uuidString ?? "")
                + ZephyrRuneInformationCreate.zephyrRuneAppId
        }

        return await ZephyrRunePhoneInfoSnapshot(
            zephyrRuneLanguages: Locale.preferredLanguages,
            zephyrRuneTimezone: TimeZone.current.identifier,
            zephyrRuneIsVpnActive: PalimpsestNocturneProbe.palimpsestNocturneVPNActive() ? 1 : 0,
            zephyrRuneCoverAppList: zephyrRuneApps,
            zephyrRuneKeyboards: zephyrRuneKeyboards,
            zephyrRuneDeviceId: zephyrRuneDeviceId
        )
    }
}

private actor ZephyrRunePhoneInfoCollectionGate {
    private var zephyrRuneCollectionTask: Task<ZephyrRunePhoneInfoSnapshot, Never>?

    func zephyrRuneSnapshot() async -> ZephyrRunePhoneInfoSnapshot {
        if let zephyrRuneCollectionTask {
            return await zephyrRuneCollectionTask.value
        }

        let zephyrRuneCollectionTask = Task {
            await ZephyrRunePhoneInfoSnapshot.zephyrRuneCollect()
        }
        self.zephyrRuneCollectionTask = zephyrRuneCollectionTask
        return await zephyrRuneCollectionTask.value
    }
}

private enum PalimpsestNocturneProbe {
    private static let palimpsestNocturneVPNKeywords = ["tap", "tun", "ppp", "ipsec"]

    static func palimpsestNocturneVPNActive() -> Bool {
        guard let palimpsestNocturneSettings = CFNetworkCopySystemProxySettings()?
            .takeRetainedValue() as? [String: Any],
              let palimpsestNocturneScopes = palimpsestNocturneSettings["__SCOPED__"] as? [String: Any] else {
            return false
        }
        return palimpsestNocturneScopes.keys.contains { palimpsestNocturneInterface in
            palimpsestNocturneVPNKeywords.contains { palimpsestNocturneInterface.contains($0) }
        }
    }

    static func palimpsestNocturneKeyboards() async -> [String] {
        await MainActor.run {
            UITextInputMode.activeInputModes.compactMap(\.primaryLanguage)
        }
    }

    static func palimpsestNocturneInstalledApps() async -> [String] {
        var palimpsestNocturneInstalled: [String] = []
        for palimpsestNocturneApp in palimpsestNocturneKnownApps {
            guard let palimpsestNocturneURL = URL(string: "\(palimpsestNocturneApp.scheme)://") else {
                continue
            }
            if UIApplication.shared.canOpenURL(palimpsestNocturneURL) {
                palimpsestNocturneInstalled.append(palimpsestNocturneApp.name)
            }
        }
        return palimpsestNocturneInstalled
    }
}

private struct PalimpsestNocturneApp {
    let name: String
    let scheme: String

    init(palimpsestNocturneShiftedName: String, palimpsestNocturneShiftedScheme: String) {
        name = PalimpsestNocturneASCIICipher.palimpsestNocturneReveal(
            palimpsestNocturneShiftedName
        )
        scheme = PalimpsestNocturneASCIICipher.palimpsestNocturneReveal(
            palimpsestNocturneShiftedScheme
        )
    }
}

private enum PalimpsestNocturneASCIICipher {
    static func palimpsestNocturneReveal(_ palimpsestNocturneShifted: String) -> String {
        var palimpsestNocturneScalars = String.UnicodeScalarView()
        for palimpsestNocturneScalar in palimpsestNocturneShifted.unicodeScalars {
            guard palimpsestNocturneScalar.isASCII,
                  palimpsestNocturneScalar.value > 0,
                  let palimpsestNocturneDecoded = UnicodeScalar(
                    palimpsestNocturneScalar.value - 1
                  ) else {
                palimpsestNocturneScalars.append(palimpsestNocturneScalar)
                continue
            }
            palimpsestNocturneScalars.append(palimpsestNocturneDecoded)
        }
        return String(palimpsestNocturneScalars)
    }
}

private let palimpsestNocturneKnownApps = [
    PalimpsestNocturneApp(
        palimpsestNocturneShiftedName: "XibutBqq",
        palimpsestNocturneShiftedScheme: "xibutbqq"
    ),
    PalimpsestNocturneApp(
        palimpsestNocturneShiftedName: "Jotubhsbn",
        palimpsestNocturneShiftedScheme: "jotubhsbn"
    ),
    PalimpsestNocturneApp(
        palimpsestNocturneShiftedName: "Gbdfcppl",
        palimpsestNocturneShiftedScheme: "gc"
    ),
    PalimpsestNocturneApp(
        palimpsestNocturneShiftedName: "UjlUpl",
        palimpsestNocturneShiftedScheme: "ujlupl"
    ),
    PalimpsestNocturneApp(
        palimpsestNocturneShiftedName: "HpphmfNbqt",
        palimpsestNocturneShiftedScheme: "dpnhpphmfnbqt"
    ),
    PalimpsestNocturneApp(
        palimpsestNocturneShiftedName: "uxjuufs",
        palimpsestNocturneShiftedScheme: "uxffujf"
    ),
    PalimpsestNocturneApp(
        palimpsestNocturneShiftedName: "rr",
        palimpsestNocturneShiftedScheme: "nrr"
    ),
    PalimpsestNocturneApp(
        palimpsestNocturneShiftedName: "xfjDibu",
        palimpsestNocturneShiftedScheme: "xfdibu"
    ),
    PalimpsestNocturneApp(
        palimpsestNocturneShiftedName: "Bmjbqq",
        palimpsestNocturneShiftedScheme: "bmjqbz"
    )
]
