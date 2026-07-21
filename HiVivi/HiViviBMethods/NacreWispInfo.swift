import Foundation
import Security

private enum NacreWispSecureKey: String {
    case nacreWispDeviceId = "nacreWispDeviceId7"
    case nacreWispPassword = "nacreWispPassword7"
    case nacreWispPendingPurchases = "HiVivi.BPackage.pendingPurchases"
}

private struct NacreWispKeychainVault {
    func nacreWispRead(_ nacreWispKey: NacreWispSecureKey) -> String? {
        var nacreWispQuery = nacreWispIdentityQuery(nacreWispKey)
        nacreWispQuery[kSecReturnData as String] = true
        nacreWispQuery[kSecMatchLimit as String] = kSecMatchLimitOne

        var nacreWispItem: AnyObject?
        guard SecItemCopyMatching(nacreWispQuery as CFDictionary, &nacreWispItem) == errSecSuccess,
              let nacreWispData = nacreWispItem as? Data else {
            return nil
        }
        return String(data: nacreWispData, encoding: .utf8)
    }

    @discardableResult
    func nacreWispWrite(_ nacreWispValue: String, key nacreWispKey: NacreWispSecureKey) -> Bool {
        guard let nacreWispData = nacreWispValue.data(using: .utf8) else { return false }
        nacreWispDelete(nacreWispKey)

        var nacreWispQuery = nacreWispIdentityQuery(nacreWispKey)
        nacreWispQuery[kSecValueData as String] = nacreWispData
        nacreWispQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        return SecItemAdd(nacreWispQuery as CFDictionary, nil) == errSecSuccess
    }

    func nacreWispDelete(_ nacreWispKey: NacreWispSecureKey) {
        SecItemDelete(nacreWispIdentityQuery(nacreWispKey) as CFDictionary)
    }

    private func nacreWispIdentityQuery(_ nacreWispKey: NacreWispSecureKey) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: nacreWispKey.rawValue
        ]
    }
}

final class NacreWispBInfoStore {
    static let shared = NacreWispBInfoStore()
    private let nacreWispVault = NacreWispKeychainVault()

    private init() {}

    var nacreWispDeviceId: String {
        get { nacreWispVault.nacreWispRead(.nacreWispDeviceId) ?? "" }
        set { nacreWispVault.nacreWispWrite(newValue, key: .nacreWispDeviceId) }
    }

    var nacreWispPassword: String {
        get { nacreWispVault.nacreWispRead(.nacreWispPassword) ?? "" }
        set { nacreWispVault.nacreWispWrite(newValue, key: .nacreWispPassword) }
    }

    func nacreWispSavePendingPurchase(_ nacreWispPurchase: NacreWispPendingPurchase) {
        var nacreWispPurchases = nacreWispReadPendingPurchases()
        nacreWispPurchases.removeAll { $0.productID == nacreWispPurchase.productID }
        nacreWispPurchases.append(nacreWispPurchase)
        nacreWispStorePendingPurchases(nacreWispPurchases)
    }

    func nacreWispPendingPurchase(productID nacreWispProductID: String) -> NacreWispPendingPurchase? {
        nacreWispReadPendingPurchases().first { $0.productID == nacreWispProductID }
    }

    func nacreWispRemovePendingPurchase(productID nacreWispProductID: String) {
        let nacreWispRemaining = nacreWispReadPendingPurchases().filter {
            $0.productID != nacreWispProductID
        }
        nacreWispStorePendingPurchases(nacreWispRemaining)
    }

    func nacreWispClearSession() {
        nacreWispPassword = ""
        NacreWispAppStorage.nacreWispUserToken = ""
        NacreWispAppStorage.nacreWispH5Url = ""
        NacreWispAppStorage.nacreWispIsB = false
    }

    private func nacreWispReadPendingPurchases() -> [NacreWispPendingPurchase] {
        guard let nacreWispText = nacreWispVault.nacreWispRead(.nacreWispPendingPurchases) else {
            return []
        }
        return (try? JSONDecoder().decode(
            [NacreWispPendingPurchase].self,
            from: Data(nacreWispText.utf8)
        )) ?? []
    }

    private func nacreWispStorePendingPurchases(_ nacreWispPurchases: [NacreWispPendingPurchase]) {
        guard nacreWispPurchases.isEmpty == false else {
            nacreWispVault.nacreWispDelete(.nacreWispPendingPurchases)
            return
        }
        guard let nacreWispData = try? JSONEncoder().encode(nacreWispPurchases),
              let nacreWispText = String(data: nacreWispData, encoding: .utf8) else {
            return
        }
        nacreWispVault.nacreWispWrite(nacreWispText, key: .nacreWispPendingPurchases)
    }
}

final class NacreWispAppStorage {
    private enum NacreWispDefaultsKey {
        static let nacreWispIsB = "nacreWispIsB"
        static let nacreWispUserToken = "nacreWispUserToken"
        static let nacreWispPushToken = "nacreWispPushToken"
        static let nacreWispH5URL = "nacreWispH5Url"
    }

    private static let nacreWispDefaults = UserDefaults.standard

    static var nacreWispIsB: Bool {
        get { nacreWispDefaults.bool(forKey: NacreWispDefaultsKey.nacreWispIsB) }
        set { nacreWispDefaults.set(newValue, forKey: NacreWispDefaultsKey.nacreWispIsB) }
    }

    static var nacreWispUserToken: String {
        get { nacreWispText(for: NacreWispDefaultsKey.nacreWispUserToken) }
        set {
            if newValue.isEmpty {
                nacreWispDefaults.removeObject(forKey: NacreWispDefaultsKey.nacreWispUserToken)
            } else {
                nacreWispDefaults.set(newValue, forKey: NacreWispDefaultsKey.nacreWispUserToken)
            }
        }
    }

    static var nacreWispPushToken: String {
        get { nacreWispText(for: NacreWispDefaultsKey.nacreWispPushToken) }
        set { nacreWispDefaults.set(newValue, forKey: NacreWispDefaultsKey.nacreWispPushToken) }
    }

    static var nacreWispH5Url: String {
        get { nacreWispText(for: NacreWispDefaultsKey.nacreWispH5URL) }
        set { nacreWispDefaults.set(newValue, forKey: NacreWispDefaultsKey.nacreWispH5URL) }
    }

    private static func nacreWispText(for nacreWispKey: String) -> String {
        nacreWispDefaults.string(forKey: nacreWispKey) ?? ""
    }
}

enum NacreWispPurchaseOrigin: String, Codable {
    case packageA
    case packageB
}

struct NacreWispPendingPurchase: Codable, Equatable {
    let productID: String
    let orderCode: String
    let origin: NacreWispPurchaseOrigin
    let createdAt: Date
}
