import Combine
import Foundation
import StoreKit

struct VoiceCoinRechargeProduct: Identifiable, Equatable {
    let id: String
    let coinAmount: Int
    let fallbackPrice: String

    var productID: String {
        id
    }
}

enum VoiceCoinRechargeCatalog {
//    static let all: [VoiceCoinRechargeProduct] = [
//        VoiceCoinRechargeProduct(id: "tlqfhnbnyykqjgbk", coinAmount: 400, fallbackPrice: "$0.99"),
//        VoiceCoinRechargeProduct(id: "jrargtnmceopagmw", coinAmount: 800, fallbackPrice: "$1.99"),
//        VoiceCoinRechargeProduct(id: "zqvnykmpjdrxtbca", coinAmount: 2190, fallbackPrice: "$3.99"),
//        VoiceCoinRechargeProduct(id: "xbgodczxvtkaanvo", coinAmount: 2450, fallbackPrice: "$4.99"),
//        VoiceCoinRechargeProduct(id: "nwdkpfvuyqjzrmhc", coinAmount: 3950, fallbackPrice: "$8.99"),
//        VoiceCoinRechargeProduct(id: "feagylrrbbywjkfv", coinAmount: 5150, fallbackPrice: "$9.99"),
//        VoiceCoinRechargeProduct(id: "mqzndbwpklavyeft", coinAmount: 5700, fallbackPrice: "$14.99"),
//        VoiceCoinRechargeProduct(id: "atpyvfkvzahgtedd", coinAmount: 10800, fallbackPrice: "$19.99"),
//        VoiceCoinRechargeProduct(id: "ptamrfaqrvojtfpx", coinAmount: 29400, fallbackPrice: "$49.99"),
//        VoiceCoinRechargeProduct(id: "wxswjcemjyhfampj", coinAmount: 63700, fallbackPrice: "$99.99")
//    ]
    static let all: [VoiceCoinRechargeProduct] = [
        VoiceCoinRechargeProduct(id: "lvbsvhxcgcrvesor", coinAmount: 400, fallbackPrice: "$0.99"),
        VoiceCoinRechargeProduct(id: "dxismgcwewhrtezo", coinAmount: 800, fallbackPrice: "$1.99"),
        VoiceCoinRechargeProduct(id: "khtxlcejaxmqcsra", coinAmount: 2190, fallbackPrice: "$3.99"),
        VoiceCoinRechargeProduct(id: "yadwwvxspgxwlndb", coinAmount: 2450, fallbackPrice: "$4.99"),
        VoiceCoinRechargeProduct(id: "nwdkpfvuyqjzrmhc", coinAmount: 3950, fallbackPrice: "$8.99"),
        VoiceCoinRechargeProduct(id: "feagylrrbbywjkfv", coinAmount: 5150, fallbackPrice: "$9.99"),
        VoiceCoinRechargeProduct(id: "mqzndbwpklavyeft", coinAmount: 5700, fallbackPrice: "$14.99"),
        VoiceCoinRechargeProduct(id: "atpyvfkvzahgtedd", coinAmount: 10800, fallbackPrice: "$19.99"),
        VoiceCoinRechargeProduct(id: "ptamrfaqrvojtfpx", coinAmount: 29400, fallbackPrice: "$49.99"),
        VoiceCoinRechargeProduct(id: "wxswjcemjyhfampj", coinAmount: 63700, fallbackPrice: "$99.99")
    ]

    static func voiceCoinProduct(for productID: String) -> VoiceCoinRechargeProduct? {
        all.first { $0.productID == productID }
    }
}

enum VoiceCoinStoreKitError: LocalizedError {
    case paymentsUnavailable
    case productNotFound
    case paymentCancelled

    var errorDescription: String? {
        switch self {
        case .paymentsUnavailable:
            return "Payments are unavailable."
        case .productNotFound:
            return "Recharge product not found."
        case .paymentCancelled:
            return "Payment cancelled."
        }
    }
}

final class VoiceCoinStoreKitOneCenter: NSObject, ObservableObject {
    static let shared = VoiceCoinStoreKitOneCenter()

    @Published private(set) var voiceCoinBalance = 0
    @Published private(set) var voiceCoinProductsByID: [String: SKProduct] = [:]

    private var voiceCoinProductsRequest: SKProductsRequest?
    private var voiceCoinProductsCompletion: ((Result<[SKProduct], Error>) -> Void)?
    private var voiceCoinPurchaseCompletions: [String: (Result<String, Error>) -> Void] = [:]
    private var voiceCoinDidLoadProducts = false
    private var voiceCoinIsLoadingProducts = false
    private let voiceCoinReloadDelay: TimeInterval = 2

    private override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }

    func voiceCoinLoadProductsIfNeeded() {
        guard !voiceCoinDidLoadProducts, !voiceCoinIsLoadingProducts else {
            return
        }

        voiceCoinIsLoadingProducts = true
        PrismTrailPulseToastLoadingCenter.shared.showLoading("Loading...", showsMask: true)
        voiceCoinLoadProducts { [weak self] walletForgeResult in
            PrismTrailPulseToastLoadingCenter.shared.hideLoading()
            guard let self else {
                return
            }

            self.voiceCoinIsLoadingProducts = false
            switch walletForgeResult {
            case .success(let voiceProducts):
                guard !voiceProducts.isEmpty else {
                    return
                }
                self.voiceCoinDidLoadProducts = true
            case .failure:
                self.voiceCoinScheduleReloadProducts()
            }
        }
    }

    func voiceCoinReloadBalance() {
        guard
            let voiceUserID = SilverGardenSessionLoginStore.readCurrentUserID(),
            let voiceUser = VoiceUserProfileStore.read(id: voiceUserID)
        else {
            voiceCoinBalance = 0
            return
        }

        voiceCoinBalance = voiceUser.voiceUserCoinCount
    }

    func voiceCoinDisplayPrice(for pack: VoiceCoinRechargeProduct) -> String {
        voiceCoinProduct(for: pack.productID)?.voiceCoinLocalizedPrice ?? pack.fallbackPrice
    }

    func voiceCoinPurchase(_ pack: VoiceCoinRechargeProduct) {
        guard SilverGardenSessionLoginStore.readCurrentUserID() != nil else {
            PrismTrailPulseToastLoadingCenter.shared.showToast("Please log in first.", kind: .normal)
            return
        }

        guard voiceCoinProduct(for: pack.productID) != nil else {
            PrismTrailPulseToastLoadingCenter.shared.showToast("Recharge product unavailable. Please try again later.", kind: .normal)
            voiceCoinLoadProductsIfNeeded()
            return
        }

        PrismTrailPulseToastLoadingCenter.shared.showLoading("Purchasing...", showsMask: true)
        voiceCoinPurchase(productID: pack.productID) { [weak self] walletForgeResult in
            PrismTrailPulseToastLoadingCenter.shared.hideLoading()
            switch walletForgeResult {
            case .success(let voiceProductID):
                self?.voiceCoinCompletePurchase(productID: voiceProductID)
            case .failure(let error):
                if let voiceStoreError = error as? VoiceCoinStoreKitError,
                   voiceStoreError == .paymentCancelled {
                    return
                }
                PrismTrailPulseToastLoadingCenter.shared.showToast(error.localizedDescription, kind: .error)
            }
        }
    }

    func voiceCoinLoadProducts(
        completion: @escaping (Result<[SKProduct], Error>) -> Void
    ) {
        voiceCoinProductsRequest?.cancel()
        voiceCoinProductsCompletion = completion

        let voiceProductIDs = Set(VoiceCoinRechargeCatalog.all.map(\.productID))
        let voiceRequest = SKProductsRequest(productIdentifiers: voiceProductIDs)
        voiceRequest.delegate = self
        voiceCoinProductsRequest = voiceRequest
        voiceRequest.start()
    }

    func voiceCoinProduct(for productID: String) -> SKProduct? {
        voiceCoinProductsByID[productID]
    }

    func voiceCoinPurchase(
        productID: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard SKPaymentQueue.canMakePayments() else {
            completion(.failure(VoiceCoinStoreKitError.paymentsUnavailable))
            return
        }

        guard let voiceProduct = voiceCoinProductsByID[productID] else {
            completion(.failure(VoiceCoinStoreKitError.productNotFound))
            return
        }

        voiceCoinPurchaseCompletions[productID] = completion
        SKPaymentQueue.default().add(SKPayment(product: voiceProduct))
    }

    private func voiceCoinCompletePurchase(productID: String) {
        guard
            let voicePack = VoiceCoinRechargeCatalog.voiceCoinProduct(for: productID),
            let voiceUserID = SilverGardenSessionLoginStore.readCurrentUserID()
        else {
            PrismTrailPulseToastLoadingCenter.shared.showToast("Recharge product not found.", kind: .error)
            return
        }

        VoiceUserProfileStore.update(id: voiceUserID) { voiceUser in
            voiceUser.voiceUserCoinCount += voicePack.coinAmount
        }
        voiceCoinReloadBalance()
        PrismTrailPulseToastLoadingCenter.shared.showToast("Recharge successful", kind: .success)
    }

    private func voiceCoinScheduleReloadProducts() {
        DispatchQueue.main.asyncAfter(deadline: .now() + voiceCoinReloadDelay) { [weak self] in
            self?.voiceCoinLoadProductsIfNeeded()
        }
    }
}

extension VoiceCoinStoreKitOneCenter: SKProductsRequestDelegate {
    func productsRequest(
        _ request: SKProductsRequest,
        didReceive response: SKProductsResponse
    ) {
        let voiceProducts = response.products.sorted { firstProduct, secondProduct in
            guard
                let firstIndex = VoiceCoinRechargeCatalog.all.firstIndex(where: { $0.productID == firstProduct.productIdentifier }),
                let secondIndex = VoiceCoinRechargeCatalog.all.firstIndex(where: { $0.productID == secondProduct.productIdentifier })
            else {
                return firstProduct.productIdentifier < secondProduct.productIdentifier
            }
            return firstIndex < secondIndex
        }

        DispatchQueue.main.async {
            self.voiceCoinProductsByID = Dictionary(
                uniqueKeysWithValues: voiceProducts.map { ($0.productIdentifier, $0) }
            )
            self.voiceCoinProductsCompletion?(.success(voiceProducts))
            self.voiceCoinProductsCompletion = nil
            self.voiceCoinProductsRequest = nil
        }
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.voiceCoinProductsCompletion?(.failure(error))
            self.voiceCoinProductsCompletion = nil
            self.voiceCoinProductsRequest = nil
        }
    }
}

extension VoiceCoinStoreKitOneCenter: SKPaymentTransactionObserver {
    func paymentQueue(
        _ queue: SKPaymentQueue,
        updatedTransactions transactions: [SKPaymentTransaction]
    ) {
        for voiceTransaction in transactions {
            switch voiceTransaction.transactionState {
            case .purchased, .restored:
                voiceCoinFinish(transaction: voiceTransaction, result: .success(voiceTransaction.payment.productIdentifier))
            case .failed:
                let voiceError = voiceTransaction.error as NSError?
                let voiceResult: Result<String, Error>
                if voiceError?.domain == SKErrorDomain && voiceError?.code == SKError.paymentCancelled.rawValue {
                    voiceResult = .failure(VoiceCoinStoreKitError.paymentCancelled)
                } else {
                    voiceResult = .failure(voiceTransaction.error ?? VoiceCoinStoreKitError.productNotFound)
                }
                voiceCoinFinish(transaction: voiceTransaction, result: voiceResult)
            case .purchasing, .deferred:
                break
            @unknown default:
                break
            }
        }
    }

    private func voiceCoinFinish(
        transaction: SKPaymentTransaction,
        result: Result<String, Error>
    ) {
        let voiceProductID = transaction.payment.productIdentifier
        let voiceCompletion = voiceCoinPurchaseCompletions.removeValue(forKey: voiceProductID)
        SKPaymentQueue.default().finishTransaction(transaction)

        DispatchQueue.main.async {
            voiceCompletion?(result)
        }
    }
}

extension SKProduct {
    var voiceCoinLocalizedPrice: String {
        let voiceFormatter = NumberFormatter()
        voiceFormatter.numberStyle = .currency
        voiceFormatter.locale = priceLocale
        return voiceFormatter.string(from: price) ?? "\(price)"
    }
}
