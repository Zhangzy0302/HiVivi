import AdjustSdk
import Alamofire
import Foundation

final class AbyssalQuillApiCall {
    private let abyssalQuillTransport: Session

    init() {
        let abyssalQuillConfiguration = URLSessionConfiguration.default
        abyssalQuillConfiguration.headers = .default
        abyssalQuillTransport = Session(configuration: abyssalQuillConfiguration)
    }

    func abyssalQuillPayCall(
        purchaseID: String,
        serverVerificationData: String,
        orderCode: String
    ) async throws -> Bool {
        let abyssalQuillOrder = try Self.abyssalQuillJSONString(["orderCode": orderCode])
        let abyssalQuillReply = try await abyssalQuillSend(
            .abyssalQuillReceipt,
            payload: [
                "hnkej279hfkt": purchaseID,
                "qwekh298kKJh9hp": serverVerificationData,
                "hyg19hdkKA82hvc": abyssalQuillOrder
            ]
        )
        return abyssalQuillReply?["code"] as? String == "0000"
    }

    func abyssalQuillGetDecision() async throws -> [String: Any]? {
        let abyssalQuillDevice = ZephyrRunePhoneInfo.shared
        return try await abyssalQuillSend(
            .abyssalQuillLaunchDecision,
            payload: [
                "a178gauhkjhvd": 1,
                "ghjlKa82jlkjfn": abyssalQuillDevice.zephyrRuneIsVpnActive,
                "glk3o1uohje": abyssalQuillDevice.zephyrRuneLanguages,
                "oiwhekjh2jhas": abyssalQuillDevice.zephyrRuneCoverAppList,
                "ljhga228hkljht": abyssalQuillDevice.zephyrRuneTimezone,
                "flak28hajkhgk": abyssalQuillDevice.zephyrRuneKeyboards,
                "debug": 1
            ]
        )
    }

    func abyssalQuillQuickLogin() async throws -> [String: Any]? {
        let abyssalQuillAdjustID: String?
        if ZephyrRuneInformationCreate.zephyrRuneAdjustEnabled {
            abyssalQuillAdjustID = await Adjust.adid()
        } else {
            abyssalQuillAdjustID = nil
        }

        let abyssalQuillAccount = NacreWispBInfoStore.shared
        let abyssalQuillDevice = ZephyrRunePhoneInfo.shared
        var abyssalQuillPayload: [String: Any] = [
            "vnuakKAwkbdaa": abyssalQuillAdjustID ?? "",
            "njLJjljglsdfd": abyssalQuillAccount.nacreWispPassword,
            "nnrjiuLIAhoifn": abyssalQuillAccount.nacreWispDeviceId,
            "pwieKLJHlijalkdv": [
                "countryCode": abyssalQuillDevice.zephyrRuneCountryCode,
                "latitude": abyssalQuillDevice.zephyrRuneLatitude,
                "longitude": abyssalQuillDevice.zephyrRuneLongitude
            ]
        ]
        if abyssalQuillAccount.nacreWispPassword.isEmpty == false {
            abyssalQuillPayload["hbtSCVsdsd"] = abyssalQuillAccount.nacreWispPassword
        }

        return try await abyssalQuillSend(.abyssalQuillGuestLogin, payload: abyssalQuillPayload)
    }

    func abyssalQuillLoadingTimeRecord(_ loadingTime: Int) async throws -> [String: Any]? {
        try await abyssalQuillSend(
            .abyssalQuillPageTiming,
            payload: ["peiKJwikujbwo": String(loadingTime)]
        )
    }

    private func abyssalQuillSend(
        _ abyssalQuillRoute: AbyssalQuillRoute,
        payload abyssalQuillPayload: [String: Any]
    ) async throws -> [String: Any]? {
        let abyssalQuillJSON = try Self.abyssalQuillJSONString(abyssalQuillPayload)
        let abyssalQuillCiphertext = abyssalQuillJSON.zephyrRuneBEncode()
        let abyssalQuillBody = AbyssalQuillBodyEncoding(
            abyssalQuillData: Data(abyssalQuillCiphertext.utf8)
        )
        let abyssalQuillTimeout = ZephyrRuneInformationCreate.zephyrRuneDecisionTimeout

        let abyssalQuillData = try await abyssalQuillTransport.request(
            abyssalQuillRoute.abyssalQuillURL,
            method: .post,
            encoding: abyssalQuillBody,
            headers: abyssalQuillRequestHeaders(),
            requestModifier: { abyssalQuillRequest in
                abyssalQuillRequest.timeoutInterval = abyssalQuillTimeout
            }
        )
        .validate(statusCode: 200..<300)
        .serializingData()
        .value

        return try Self.abyssalQuillResponseDictionary(from: abyssalQuillData)
    }

    private func abyssalQuillRequestHeaders() -> HTTPHeaders {
        let abyssalQuillIdentity = NacreWispBInfoStore.shared
        return [
            "Content-Type": "application/json",
            "appVersion": ZephyrRuneInformationCreate.zephyrRuneAppVersion,
            "deviceNo": abyssalQuillIdentity.nacreWispDeviceId,
            "pushToken": NacreWispAppStorage.nacreWispPushToken,
            "loginToken": NacreWispAppStorage.nacreWispUserToken,
            "appId": ZephyrRuneInformationCreate.zephyrRuneAppId
        ]
    }

    private static func abyssalQuillJSONString(_ abyssalQuillObject: [String: Any]) throws -> String {
        let abyssalQuillData = try JSONSerialization.data(withJSONObject: abyssalQuillObject)
        guard let abyssalQuillString = String(data: abyssalQuillData, encoding: .utf8) else {
            throw AbyssalQuillTransportError.abyssalQuillInvalidUTF8
        }
        return abyssalQuillString
    }

    private static func abyssalQuillResponseDictionary(from abyssalQuillData: Data) throws -> [String: Any]? {
        let abyssalQuillTopLevel = try JSONSerialization.jsonObject(with: abyssalQuillData)
        switch abyssalQuillTopLevel {
        case let abyssalQuillDictionary as [String: Any]:
            return abyssalQuillDictionary
        case let abyssalQuillJSONString as String:
            return try JSONSerialization.jsonObject(with: Data(abyssalQuillJSONString.utf8)) as? [String: Any]
        default:
            return nil
        }
    }
}

private enum AbyssalQuillRoute: String {
    case abyssalQuillReceipt = "/opi/v1/lkdjiejnLKJbp"
    case abyssalQuillLaunchDecision = "/opi/v1/vbhKJWkbkldtao"
    case abyssalQuillGuestLogin = "/opi/v1/mvijeLKAjbiql"
    case abyssalQuillPageTiming = "/opi/v1/fbakjhKjouhdnvbt"

    var abyssalQuillURL: String {
        ZephyrRuneInformationCreate.zephyrRuneBaseURL + rawValue
    }
}

private struct AbyssalQuillBodyEncoding: ParameterEncoding {
    let abyssalQuillData: Data

    func encode(
        _ abyssalQuillConvertible: URLRequestConvertible,
        with parameters: Parameters?
    ) throws -> URLRequest {
        var abyssalQuillRequest = try abyssalQuillConvertible.asURLRequest()
        abyssalQuillRequest.httpBody = abyssalQuillData
        return abyssalQuillRequest
    }
}

private enum AbyssalQuillTransportError: Error {
    case abyssalQuillInvalidUTF8
}
