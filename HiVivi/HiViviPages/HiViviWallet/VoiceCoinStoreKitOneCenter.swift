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
    static let all: [VoiceCoinRechargeProduct] = [
        VoiceCoinRechargeProduct(id: "tlqfhnbnyykqjgbk", coinAmount: 400, fallbackPrice: "$0.99"),
        VoiceCoinRechargeProduct(id: "jrargtnmceopagmw", coinAmount: 800, fallbackPrice: "$1.99"),
        VoiceCoinRechargeProduct(id: "zqvnykmpjdrxtbca", coinAmount: 2190, fallbackPrice: "$3.99"),
        VoiceCoinRechargeProduct(id: "xbgodczxvtkaanvo", coinAmount: 2450, fallbackPrice: "$4.99"),
        VoiceCoinRechargeProduct(id: "nwdkpfvuyqjzrmhc", coinAmount: 3950, fallbackPrice: "$7.99"),
        VoiceCoinRechargeProduct(id: "feagylrrbbywjkfv", coinAmount: 5150, fallbackPrice: "$9.99"),
        VoiceCoinRechargeProduct(id: "mqzndbwpklavyeft", coinAmount: 7700, fallbackPrice: "$14.99"),
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
    case productsLoadFailed
    case purchaseInProgress

    var errorDescription: String? {
        switch self {
        case .paymentsUnavailable:
            return "Payments are unavailable."
        case .productNotFound:
            return "Recharge product not found."
        case .paymentCancelled:
            return "Payment cancelled."
        case .productsLoadFailed:
            return "Recharge products failed to load."
        case .purchaseInProgress:
            return "Another purchase is in progress."
        }
    }
}

enum VoiceCoinBPackagePurchaseResult {
    case success(coins: Int)
    case cancelled
    case pending
    case failed(message: String)
}

final class VoiceCoinStoreKitOneCenter: NSObject, ObservableObject {
    static let shared = VoiceCoinStoreKitOneCenter()

    @Published private(set) var voiceCoinBalance = 0
    @Published private(set) var voiceCoinProductsByID: [String: SKProduct] = [:]

    private var voiceCoinProductsRequest: SKProductsRequest?
    private var voiceCoinProductsCompletions: [(Result<[SKProduct], Error>) -> Void] = []
    private var voiceCoinPurchaseCompletions: [String: (Result<String, Error>) -> Void] = [:]
    private var voiceCoinBPurchaseCompletions: [String: (VoiceCoinBPackagePurchaseResult) -> Void] = [:]
    private var voiceCoinPendingBPurchasesByProductID: [String: NacreWispPendingPurchase] = [:]
    private var voiceCoinVerifyingTransactionIDs: Set<String> = []
    private var voiceCoinActiveBProductID: String?
    private var voiceCoinPurchasingProductID: String?
    private var voiceCoinDidLoadProducts = false
    private var voiceCoinIsLoadingProducts = false
    private let voiceCoinReloadDelay: TimeInterval = 2
    private let voiceCoinVerificationMaxAttempts = 3

    private override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }

    func voiceCoinLoadProductsIfNeeded() {
        guard !voiceCoinDidLoadProducts else {
            return
        }

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
        productIDs: Set<String> = Set(VoiceCoinRechargeCatalog.all.map(\.productID)),
        completion: @escaping (Result<[SKProduct], Error>) -> Void
    ) {
        let voiceCachedProducts = productIDs.compactMap { voiceCoinProductsByID[$0] }
        if productIDs.isEmpty == false, voiceCachedProducts.count == productIDs.count {
            completion(.success(voiceCachedProducts))
            return
        }

        voiceCoinProductsCompletions.append(completion)
        guard voiceCoinIsLoadingProducts == false else { return }

        voiceCoinIsLoadingProducts = true
        voiceCoinProductsRequest?.cancel()

        let voiceRequest = SKProductsRequest(productIdentifiers: productIDs)
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
        guard voiceCoinPurchasingProductID == nil else {
            completion(.failure(VoiceCoinStoreKitError.purchaseInProgress))
            return
        }
        guard voiceCoinPendingBPurchase(productID: productID) == nil else {
            completion(.failure(VoiceCoinStoreKitError.purchaseInProgress))
            return
        }

        voiceCoinPurchasingProductID = productID
        voiceCoinPurchaseCompletions[productID] = completion
        SKPaymentQueue.default().add(SKPayment(product: voiceProduct))
    }

    func voiceCoinPrepareBPackageProducts() {
        voiceCoinLoadProducts { _ in }
    }

    func voiceCoinPurchaseForBPackage(
        productID: String,
        orderCode: String,
        completion: @escaping (VoiceCoinBPackagePurchaseResult) -> Void
    ) {
        let voiceCoinNormalizedProductID = productID.trimmingCharacters(in: .whitespacesAndNewlines)
        let voiceCoinNormalizedOrderCode = orderCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard voiceCoinNormalizedProductID.isEmpty == false,
              voiceCoinNormalizedOrderCode.isEmpty == false else {
            completion(.failed(message: "Invalid purchase request"))
            return
        }

        guard SKPaymentQueue.canMakePayments() else {
            completion(.failed(message: "Payments are unavailable"))
            return
        }
        guard voiceCoinPurchasingProductID == nil, voiceCoinActiveBProductID == nil else {
            completion(.failed(message: "Another purchase is in progress"))
            return
        }
        if voiceCoinPendingBPurchase(productID: voiceCoinNormalizedProductID) != nil {
            if voiceCoinHasStoreKitTransaction(productID: voiceCoinNormalizedProductID) {
                completion(.failed(message: "A purchase for this product is already pending"))
                return
            }
            voiceCoinPendingBPurchasesByProductID.removeValue(forKey: voiceCoinNormalizedProductID)
            NacreWispBInfoStore.shared.nacreWispRemovePendingPurchase(
                productID: voiceCoinNormalizedProductID
            )
        }

        voiceCoinActiveBProductID = voiceCoinNormalizedProductID
        voiceCoinPurchasingProductID = voiceCoinNormalizedProductID
        voiceCoinBPurchaseCompletions[voiceCoinNormalizedProductID] = completion

        if let voiceProduct = voiceCoinProductsByID[voiceCoinNormalizedProductID] {
            voiceCoinStartBPackagePayment(
                product: voiceProduct,
                orderCode: voiceCoinNormalizedOrderCode
            )
            return
        }

        voiceCoinLoadProduct(productID: voiceCoinNormalizedProductID) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let voiceProduct):
                    self.voiceCoinStartBPackagePayment(
                        product: voiceProduct,
                        orderCode: voiceCoinNormalizedOrderCode
                    )

                case .failure(let error):
                    self.voiceCoinCompleteBPackageResult(
                        .failed(message: error.localizedDescription),
                        productID: voiceCoinNormalizedProductID,
                        removesPendingPurchase: false
                    )
                }
            }
        }
    }

    private func voiceCoinStartBPackagePayment(product: SKProduct, orderCode: String) {
        let voicePendingPurchase = NacreWispPendingPurchase(
            productID: product.productIdentifier,
            orderCode: orderCode,
            origin: .packageB,
            createdAt: Date()
        )
        voiceCoinPendingBPurchasesByProductID[product.productIdentifier] = voicePendingPurchase
        NacreWispBInfoStore.shared.nacreWispSavePendingPurchase(voicePendingPurchase)
        NacreWispAppStorage.nacreWispIsB = true
        SKPaymentQueue.default().add(SKPayment(product: product))
    }

    private func voiceCoinLoadProduct(
        productID: String,
        completion: @escaping (Result<SKProduct, Error>) -> Void
    ) {
        if let voiceProduct = voiceCoinProductsByID[productID] {
            completion(.success(voiceProduct))
            return
        }

        if voiceCoinIsLoadingProducts {
            voiceCoinLoadProducts { [weak self] _ in
                self?.voiceCoinLoadProduct(productID: productID, completion: completion)
            }
            return
        }

        voiceCoinLoadProducts(productIDs: [productID]) { [weak self] voiceResult in
            guard let self else { return }
            switch voiceResult {
            case .success:
                if let voiceProduct = self.voiceCoinProductsByID[productID] {
                    completion(.success(voiceProduct))
                } else {
                    completion(.failure(VoiceCoinStoreKitError.productNotFound))
                }
            case .failure(let voiceError):
                completion(.failure(voiceError))
            }
        }
    }

    private func voiceCoinHasStoreKitTransaction(productID: String) -> Bool {
        SKPaymentQueue.default().transactions.contains {
            $0.payment.productIdentifier == productID
                && $0.transactionState != .failed
        }
    }

    private func voiceCoinCompleteBPackageResult(
        _ result: VoiceCoinBPackagePurchaseResult,
        productID: String,
        removesPendingPurchase: Bool
    ) {
        if removesPendingPurchase {
            voiceCoinPendingBPurchasesByProductID.removeValue(forKey: productID)
            NacreWispBInfoStore.shared.nacreWispRemovePendingPurchase(productID: productID)
        }
        if voiceCoinActiveBProductID == productID {
            voiceCoinActiveBProductID = nil
        }
        if voiceCoinPurchasingProductID == productID {
            voiceCoinPurchasingProductID = nil
        }
        let completion = voiceCoinBPurchaseCompletions.removeValue(forKey: productID)
        completion?(result)
    }

    private func voiceCoinPendingBPurchase(productID: String) -> NacreWispPendingPurchase? {
        voiceCoinPendingBPurchasesByProductID[productID]
            ?? NacreWispBInfoStore.shared.nacreWispPendingPurchase(productID: productID)
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
            self.voiceCoinProductsByID.merge(
                Dictionary(uniqueKeysWithValues: voiceProducts.map { ($0.productIdentifier, $0) })
            ) { _, voiceNewProduct in
                voiceNewProduct
            }
            self.voiceCoinIsLoadingProducts = false
            self.voiceCoinDidLoadProducts = voiceProducts.isEmpty == false
            let voiceCompletions = self.voiceCoinProductsCompletions
            self.voiceCoinProductsCompletions.removeAll()
            self.voiceCoinProductsRequest = nil
            let voiceResult: Result<[SKProduct], Error> = voiceProducts.isEmpty
                ? .failure(VoiceCoinStoreKitError.productsLoadFailed)
                : .success(voiceProducts)
            voiceCompletions.forEach { $0(voiceResult) }
        }
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.voiceCoinIsLoadingProducts = false
            let voiceCompletions = self.voiceCoinProductsCompletions
            self.voiceCoinProductsCompletions.removeAll()
            self.voiceCoinProductsRequest = nil
            voiceCompletions.forEach { $0(.failure(error)) }
        }
    }
}

extension VoiceCoinStoreKitOneCenter: SKPaymentTransactionObserver {
    func paymentQueue(
        _ queue: SKPaymentQueue,
        updatedTransactions transactions: [SKPaymentTransaction]
    ) {
        DispatchQueue.main.async { [weak self] in
            self?.voiceCoinHandleTransactions(transactions, queue: queue)
        }
    }

    private func voiceCoinHandleTransactions(
        _ transactions: [SKPaymentTransaction],
        queue: SKPaymentQueue
    ) {
        for voiceTransaction in transactions {
            let voiceProductID = voiceTransaction.payment.productIdentifier
            let voicePendingPurchase = voiceCoinPendingBPurchase(productID: voiceProductID)
            let voiceIsBPackageTransaction = voicePendingPurchase?.origin == .packageB
                || voiceCoinActiveBProductID == voiceProductID
                || voiceCoinBPurchaseCompletions[voiceProductID] != nil

            switch voiceTransaction.transactionState {
            case .purchased, .restored:
                if voiceIsBPackageTransaction, let voicePendingPurchase {
                    voiceCoinVerifyBPackagePurchase(voiceTransaction, pendingPurchase: voicePendingPurchase)
                } else if voiceIsBPackageTransaction {
                    voiceCoinCompleteBPackageResult(
                        .failed(message: "Purchase order unavailable"),
                        productID: voiceProductID,
                        removesPendingPurchase: false
                    )
                } else {
                    voiceCoinFinish(transaction: voiceTransaction, result: .success(voiceProductID))
                }
            case .failed:
                let voiceError = voiceTransaction.error as NSError?
                if voiceIsBPackageTransaction {
                    let voiceResult: VoiceCoinBPackagePurchaseResult
                    if voiceError?.domain == SKErrorDomain && voiceError?.code == SKError.paymentCancelled.rawValue {
                        voiceResult = .cancelled
                    } else {
                        voiceResult = .failed(message: voiceTransaction.error?.localizedDescription ?? "Purchase failed")
                    }
                    queue.finishTransaction(voiceTransaction)
                    voiceCoinCompleteBPackageResult(
                        voiceResult,
                        productID: voiceProductID,
                        removesPendingPurchase: true
                    )
                    continue
                }
                let voiceResult: Result<String, Error>
                if voiceError?.domain == SKErrorDomain && voiceError?.code == SKError.paymentCancelled.rawValue {
                    voiceResult = .failure(VoiceCoinStoreKitError.paymentCancelled)
                } else {
                    voiceResult = .failure(voiceTransaction.error ?? VoiceCoinStoreKitError.productNotFound)
                }
                voiceCoinFinish(transaction: voiceTransaction, result: voiceResult)
            case .deferred:
                if voiceIsBPackageTransaction {
                    voiceCoinCompleteBPackageResult(
                        .pending,
                        productID: voiceProductID,
                        removesPendingPurchase: false
                    )
                }
            case .purchasing:
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
        if voiceCoinPurchasingProductID == voiceProductID {
            voiceCoinPurchasingProductID = nil
        }
        SKPaymentQueue.default().finishTransaction(transaction)

        voiceCompletion?(result)
    }

    private func voiceCoinVerifyBPackagePurchase(
        _ transaction: SKPaymentTransaction,
        pendingPurchase: NacreWispPendingPurchase
    ) {
        guard let transactionID = transaction.transactionIdentifier,
              transactionID.isEmpty == false else {
            voiceCoinCompleteBPackageResult(
                .failed(message: "Purchase transaction unavailable"),
                productID: pendingPurchase.productID,
                removesPendingPurchase: false
            )
            return
        }
        guard voiceCoinVerifyingTransactionIDs.insert(transactionID).inserted else {
            return
        }

        guard let receiptURL = Bundle.main.appStoreReceiptURL,
              let receiptData = try? Data(contentsOf: receiptURL),
              receiptData.isEmpty == false else {
            voiceCoinVerifyingTransactionIDs.remove(transactionID)
            voiceCoinCompleteBPackageResult(
                .failed(message: "Purchase receipt unavailable"),
                productID: pendingPurchase.productID,
                removesPendingPurchase: false
            )
            return
        }

        Task {
            let voiceVerified = await self.voiceCoinVerifyBPackageReceipt(
                transactionID: transactionID,
                receiptData: receiptData,
                orderCode: pendingPurchase.orderCode
            )

            await MainActor.run {
                self.voiceCoinVerifyingTransactionIDs.remove(transactionID)
                guard voiceVerified else {
                    self.voiceCoinCompleteBPackageResult(
                        .failed(message: "Purchase verification is pending"),
                        productID: pendingPurchase.productID,
                        removesPendingPurchase: false
                    )
                    return
                }

                SKPaymentQueue.default().finishTransaction(transaction)
                let voiceCoins = VoiceCoinRechargeCatalog.voiceCoinProduct(
                    for: pendingPurchase.productID
                )?.coinAmount ?? 0
                let voiceProductPrice = self.voiceCoinProductsByID[
                    pendingPurchase.productID
                ]?.price.doubleValue ?? 0
                VellumOrbitAdjustManager.shared.vellumOrbitTrackPurchase(dollar: voiceProductPrice)
                self.voiceCoinCompleteBPackageResult(
                    .success(coins: voiceCoins),
                    productID: pendingPurchase.productID,
                    removesPendingPurchase: true
                )
            }
        }
    }

    private func voiceCoinVerifyBPackageReceipt(
        transactionID: String,
        receiptData: Data,
        orderCode: String
    ) async -> Bool {
        for voiceAttempt in 1...voiceCoinVerificationMaxAttempts {
            do {
                let voiceVerified = try await AbyssalQuillApiCall().abyssalQuillPayCall(
                    purchaseID: transactionID,
                    serverVerificationData: receiptData.base64EncodedString(),
                    orderCode: orderCode
                )
                if voiceVerified {
                    return true
                }
            } catch {}

            guard voiceAttempt < voiceCoinVerificationMaxAttempts else { break }
            let voiceDelay = UInt64(voiceAttempt) * 1_000_000_000
            try? await Task.sleep(nanoseconds: voiceDelay)
            if Task.isCancelled {
                return false
            }
        }

        return false
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
