import CommonCrypto
import Foundation

extension String {
    func zephyrRuneBEncode() -> String {
        ZephyrRuneAESCoder.zephyrRuneEncrypt(self)
    }

    func zephyrRuneBDecrypt() -> String {
        ZephyrRuneAESCoder.zephyrRuneDecrypt(self)
    }
}

private enum ZephyrRuneAESCoder {
    private static let zephyrRuneAESKey = "a8dw4ikjpde94f6v"
    private static let zephyrRuneAESIV = "l34r8otozp2mdsv8"

    static func zephyrRuneEncrypt(_ zephyrRunePlainText: String) -> String {
        guard let zephyrRuneData = zephyrRunePlainText.data(using: .utf8),
              let zephyrRuneEncrypted = zephyrRuneCrypt(
                zephyrRuneData,
                zephyrRuneOperation: CCOperation(kCCEncrypt)
              ) else {
            return ""
        }
        return zephyrRuneEncrypted.map { String(format: "%02x", $0) }.joined()
    }

    static func zephyrRuneDecrypt(_ zephyrRuneCipherText: String) -> String {
        guard let zephyrRuneEncryptedData = zephyrRuneHexData(zephyrRuneCipherText),
              let zephyrRuneDecrypted = zephyrRuneCrypt(
                zephyrRuneEncryptedData,
                zephyrRuneOperation: CCOperation(kCCDecrypt)
              ),
              let zephyrRuneResult = String(data: zephyrRuneDecrypted, encoding: .utf8) else {
            return ""
        }
        return zephyrRuneResult
    }

    private static func zephyrRuneCrypt(
        _ zephyrRuneData: Data,
        zephyrRuneOperation: CCOperation
    ) -> Data? {
        let zephyrRuneKeyData = Data(zephyrRuneAESKey.utf8)
        let zephyrRuneIVData = Data(zephyrRuneAESIV.utf8)
        let zephyrRuneOutputCapacity = zephyrRuneData.count + kCCBlockSizeAES128
        var zephyrRuneOutput = Data(count: zephyrRuneOutputCapacity)
        var zephyrRuneWritten = 0

        let zephyrRuneStatus = zephyrRuneOutput.withUnsafeMutableBytes { zephyrRuneOutputBuffer in
            zephyrRuneData.withUnsafeBytes { zephyrRuneInputBuffer in
                zephyrRuneKeyData.withUnsafeBytes { zephyrRuneKeyBuffer in
                    zephyrRuneIVData.withUnsafeBytes { zephyrRuneIVBuffer in
                        CCCrypt(
                            zephyrRuneOperation,
                            CCAlgorithm(kCCAlgorithmAES),
                            CCOptions(kCCOptionPKCS7Padding),
                            zephyrRuneKeyBuffer.baseAddress,
                            kCCKeySizeAES128,
                            zephyrRuneIVBuffer.baseAddress,
                            zephyrRuneInputBuffer.baseAddress,
                            zephyrRuneData.count,
                            zephyrRuneOutputBuffer.baseAddress,
                            zephyrRuneOutputCapacity,
                            &zephyrRuneWritten
                        )
                    }
                }
            }
        }
        guard zephyrRuneStatus == kCCSuccess else { return nil }
        return zephyrRuneOutput.prefix(zephyrRuneWritten)
    }

    private static func zephyrRuneHexData(_ zephyrRuneText: String) -> Data? {
        var zephyrRuneResult = Data(capacity: zephyrRuneText.count / 2)
        var zephyrRuneCursor = zephyrRuneText.startIndex
        for _ in 0..<(zephyrRuneText.count / 2) {
            let zephyrRuneNext = zephyrRuneText.index(zephyrRuneCursor, offsetBy: 2)
            guard let zephyrRuneByte = UInt8(zephyrRuneText[zephyrRuneCursor..<zephyrRuneNext], radix: 16) else {
                return nil
            }
            zephyrRuneResult.append(zephyrRuneByte)
            zephyrRuneCursor = zephyrRuneNext
        }
        return zephyrRuneResult
    }
}

final class ZephyrRuneInformationCreate {
    static let zephyrRuneBaseURL = "https://opi.u5mmdj3g.link"
    static let zephyrRuneAppId = "49577470"
    static let zephyrRuneAppVersion = "1.1.0"
    static let zephyrRuneDecisionTimeout: TimeInterval = 10
    static let zephyrRuneAdjustEnabled = true
    static let zephyrRunePushEnabled = true
    static let zephyrRunePushTokenWaitTimeout: TimeInterval = 3
    static let zephyrRuneVerifyDate = DateComponents(year: 2026, month: 7, day: 22, hour: 9)

    static func zephyrRuneBuildH5Url(baseUrl zephyrRuneBaseURL: String, token zephyrRuneToken: String) -> String {
        guard let zephyrRuneURL = zephyrRuneResolveH5URL(zephyrRuneBaseURL),
              let zephyrRunePayloadData = try? JSONSerialization.data(
                withJSONObject: [
                    "token": zephyrRuneToken,
                    "timestamp": Int(Date().timeIntervalSince1970 * 1_000)
                ]
              ),
              let zephyrRunePayload = String(data: zephyrRunePayloadData, encoding: .utf8) else {
            return ""
        }

        var zephyrRuneComponents = URLComponents(url: zephyrRuneURL, resolvingAgainstBaseURL: false)
        var zephyrRuneItems = zephyrRuneComponents?.queryItems ?? []
        zephyrRuneItems.append(URLQueryItem(name: "openParams", value: zephyrRunePayload.zephyrRuneBEncode()))
        zephyrRuneItems.append(URLQueryItem(name: "appId", value: zephyrRuneAppId))
        zephyrRuneComponents?.queryItems = zephyrRuneItems
        return zephyrRuneComponents?.url?.absoluteString ?? ""
    }

    static func zephyrRuneIsAllowedH5URL(_ zephyrRuneURL: URL) -> Bool {
        zephyrRuneIsWebURL(zephyrRuneURL)
    }

    static func zephyrRuneResolveAllowedH5URL(_ zephyrRuneAddress: String) -> URL? {
        zephyrRuneResolveH5URL(zephyrRuneAddress)
    }

    static func zephyrRuneResolveH5URL(_ zephyrRuneAddress: String) -> URL? {
        let zephyrRuneTrimmed = zephyrRuneAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        guard zephyrRuneTrimmed.isEmpty == false else { return nil }
        if let zephyrRuneURL = URL(string: zephyrRuneTrimmed), zephyrRuneURL.scheme?.isEmpty == false {
            return zephyrRuneURL
        }
        return URL(string: "https://\(zephyrRuneTrimmed)")
    }

    static func zephyrRuneIsWebURL(_ zephyrRuneURL: URL) -> Bool {
        guard let zephyrRuneScheme = zephyrRuneURL.scheme?.lowercased() else { return false }
        return ["http", "https", "file", "about"].contains(zephyrRuneScheme)
    }
}
