import Combine
import Foundation
import SwiftUI
import UIKit
import WebKit

private enum VirelaiGloamingASCIICipher {
    static func virelaiGloamingReveal(_ virelaiGloamingShifted: String) -> String {
        var virelaiGloamingScalars = String.UnicodeScalarView()
        for virelaiGloamingScalar in virelaiGloamingShifted.unicodeScalars {
            guard virelaiGloamingScalar.isASCII,
                  virelaiGloamingScalar.value > 0,
                  let virelaiGloamingDecoded = UnicodeScalar(virelaiGloamingScalar.value - 1) else {
                virelaiGloamingScalars.append(virelaiGloamingScalar)
                continue
            }
            virelaiGloamingScalars.append(virelaiGloamingDecoded)
        }
        return String(virelaiGloamingScalars)
    }
}

final class VirelaiGloamingScriptBridge: ObservableObject {
    weak var virelaiGloamingWebView: WKWebView?

    func virelaiGloamingReload() {
        virelaiGloamingWebView?.reload()
    }

    func virelaiGloamingEmit(event: String, detail: [String: Any]) {
        guard JSONSerialization.isValidJSONObject(detail),
              let virelaiGloamingDetailData = try? JSONSerialization.data(withJSONObject: detail),
              let virelaiGloamingDetail = String(data: virelaiGloamingDetailData, encoding: .utf8),
              let virelaiGloamingEventData = try? JSONEncoder().encode(event),
              let virelaiGloamingEvent = String(data: virelaiGloamingEventData, encoding: .utf8) else {
            return
        }
        let virelaiGloamingScript = VirelaiGloamingASCIICipher.virelaiGloamingReveal(
            "xjoepx/ejtqbudiFwfou)ofx!DvtupnFwfou)"
        ) + virelaiGloamingEvent
            + VirelaiGloamingASCIICipher.virelaiGloamingReveal("-!|!efubjm;!")
            + virelaiGloamingDetail
            + VirelaiGloamingASCIICipher.virelaiGloamingReveal("!~**<")
        DispatchQueue.main.async { [weak self] in
            self?.virelaiGloamingWebView?.evaluateJavaScript(virelaiGloamingScript)
        }
    }
}

struct VirelaiGloamingCallbacks {
    let virelaiGloamingDidStart: () -> Void
    let virelaiGloamingDidFinish: (Int) -> Void
    let virelaiGloamingDidFail: (String) -> Void
    let virelaiGloamingDidRequestClose: () -> Void
    let virelaiGloamingDidRequestPurchase: (VirelaiGloamingPurchaseRequest) -> Void
    let virelaiGloamingDidRequestExternalOpen: (VirelaiGloamingExternalRequest) -> Void
    let virelaiGloamingDidRejectMessage: (String?, String) -> Void
}

struct VirelaiGloamingExternalRequest {
    let virelaiGloamingRequestID: String?
    let virelaiGloamingURLString: String

    init?(virelaiGloamingBody: Any) {
        let virelaiGloamingDictionary = virelaiGloamingBody as? [String: Any]
        let virelaiGloamingAddress = (
            virelaiGloamingDictionary?[
                VirelaiGloamingASCIICipher.virelaiGloamingReveal("vsm")
            ] as? String
                ?? virelaiGloamingBody as? String
        )?.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let virelaiGloamingAddress, virelaiGloamingAddress.isEmpty == false else {
            return nil
        }

        let virelaiGloamingCandidateID = (virelaiGloamingDictionary?[
            VirelaiGloamingASCIICipher.virelaiGloamingReveal("sfrvftuJe")
        ] as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        virelaiGloamingRequestID = virelaiGloamingCandidateID?.isEmpty == false
            ? virelaiGloamingCandidateID
            : nil
        virelaiGloamingURLString = virelaiGloamingAddress
    }
}

struct VirelaiGloamingPurchaseRequest {
    let virelaiGloamingRequestID: String
    let virelaiGloamingOrderCode: String
    let virelaiGloamingProductID: String

    init?(virelaiGloamingBody: Any) {
        guard let virelaiGloamingDictionary = Self.virelaiGloamingDictionary(
            from: virelaiGloamingBody
        ),
              let virelaiGloamingOrder = Self.virelaiGloamingText(
                virelaiGloamingDictionary[
                    VirelaiGloamingASCIICipher.virelaiGloamingReveal("psefsDpef")
                ]
              ),
              let virelaiGloamingProduct = Self.virelaiGloamingText(
                virelaiGloamingDictionary[
                    VirelaiGloamingASCIICipher.virelaiGloamingReveal("qspevduJe")
                ]
                    ?? virelaiGloamingDictionary[
                        VirelaiGloamingASCIICipher.virelaiGloamingReveal("qspevduJE")
                    ]
                    ?? virelaiGloamingDictionary[
                        VirelaiGloamingASCIICipher.virelaiGloamingReveal("cbudiOp")
                    ]
              ) else {
            return nil
        }

        let virelaiGloamingCandidate = Self.virelaiGloamingText(
            virelaiGloamingDictionary[
                VirelaiGloamingASCIICipher.virelaiGloamingReveal("sfrvftuJe")
            ]
        )
        virelaiGloamingRequestID = virelaiGloamingCandidate?.isEmpty == false
            ? virelaiGloamingCandidate!
            : UUID().uuidString
        virelaiGloamingOrderCode = virelaiGloamingOrder
        virelaiGloamingProductID = virelaiGloamingProduct
    }

    private static func virelaiGloamingDictionary(from virelaiGloamingBody: Any) -> [String: Any]? {
        if let virelaiGloamingDictionary = virelaiGloamingBody as? [String: Any] {
            return virelaiGloamingDictionary
        }
        guard let virelaiGloamingJSON = virelaiGloamingBody as? String,
              let virelaiGloamingData = virelaiGloamingJSON.data(using: .utf8) else {
            return nil
        }
        return try? JSONSerialization.jsonObject(with: virelaiGloamingData) as? [String: Any]
    }

    private static func virelaiGloamingText(_ virelaiGloamingValue: Any?) -> String? {
        let virelaiGloamingText: String?
        switch virelaiGloamingValue {
        case let virelaiGloamingString as String:
            virelaiGloamingText = virelaiGloamingString
        case let virelaiGloamingNumber as NSNumber:
            virelaiGloamingText = virelaiGloamingNumber.stringValue
        default:
            virelaiGloamingText = nil
        }

        let virelaiGloamingTrimmed = virelaiGloamingText?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return virelaiGloamingTrimmed?.isEmpty == false ? virelaiGloamingTrimmed : nil
    }
}

struct VirelaiGloamingWebSurface: UIViewRepresentable {
    let virelaiGloamingURL: URL
    let virelaiGloamingBridge: VirelaiGloamingScriptBridge
    let virelaiGloamingCallbacks: VirelaiGloamingCallbacks

    func makeCoordinator() -> VirelaiGloamingCoordinator {
        VirelaiGloamingCoordinator(virelaiGloamingCallbacks: virelaiGloamingCallbacks)
    }

    func makeUIView(context: Context) -> WKWebView {
        let virelaiGloamingWebView = WKWebView(
            frame: .zero,
            configuration: virelaiGloamingConfiguration(coordinator: context.coordinator)
        )
        virelaiGloamingStyle(virelaiGloamingWebView, coordinator: context.coordinator)
        virelaiGloamingBridge.virelaiGloamingWebView = virelaiGloamingWebView
        virelaiGloamingWebView.load(URLRequest(url: virelaiGloamingURL))
        NobleSpringSurfWebPreheater.nobleSpringSurfReleaseWarmView()
        return virelaiGloamingWebView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        context.coordinator.virelaiGloamingCallbacks = virelaiGloamingCallbacks
    }

    static func dismantleUIView(_ uiView: WKWebView, coordinator: VirelaiGloamingCoordinator) {
        VirelaiGloamingAction.allCases.forEach {
            uiView.configuration.userContentController.removeScriptMessageHandler(forName: $0.rawValue)
        }
        uiView.navigationDelegate = nil
        uiView.uiDelegate = nil
    }

    private func virelaiGloamingConfiguration(
        coordinator: VirelaiGloamingCoordinator
    ) -> WKWebViewConfiguration {
        let virelaiGloamingController = WKUserContentController()
        VirelaiGloamingAction.allCases.forEach {
            virelaiGloamingController.add(coordinator, name: $0.rawValue)
        }
        let virelaiGloamingConfiguration = NobleSpringSurfWebPreheater.nobleSpringSurfMakeConfiguration()
        virelaiGloamingConfiguration.userContentController = virelaiGloamingController
        virelaiGloamingConfiguration.mediaTypesRequiringUserActionForPlayback = []
        virelaiGloamingConfiguration.allowsInlineMediaPlayback = true
        return virelaiGloamingConfiguration
    }

    private func virelaiGloamingStyle(
        _ virelaiGloamingWebView: WKWebView,
        coordinator: VirelaiGloamingCoordinator
    ) {
        virelaiGloamingWebView.navigationDelegate = coordinator
        virelaiGloamingWebView.uiDelegate = coordinator
        virelaiGloamingWebView.backgroundColor = .clear
        virelaiGloamingWebView.isOpaque = false
        virelaiGloamingWebView.scrollView.backgroundColor = .clear
        virelaiGloamingWebView.scrollView.contentInsetAdjustmentBehavior = .never
        virelaiGloamingWebView.scrollView.contentInset = .zero
        virelaiGloamingWebView.scrollView.scrollIndicatorInsets = .zero
        virelaiGloamingWebView.allowsBackForwardNavigationGestures = true
    }
}

final class VirelaiGloamingCoordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate {
    var virelaiGloamingCallbacks: VirelaiGloamingCallbacks
    private var virelaiGloamingNavigationBeganAt = Date()

    init(virelaiGloamingCallbacks: VirelaiGloamingCallbacks) {
        self.virelaiGloamingCallbacks = virelaiGloamingCallbacks
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        virelaiGloamingNavigationBeganAt = Date()
        virelaiGloamingCallbacks.virelaiGloamingDidStart()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let virelaiGloamingMilliseconds = Int(
            Date().timeIntervalSince(virelaiGloamingNavigationBeganAt) * 1_000
        )
        virelaiGloamingCallbacks.virelaiGloamingDidFinish(virelaiGloamingMilliseconds)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        virelaiGloamingCallbacks.virelaiGloamingDidFail(error.localizedDescription)
    }

    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        virelaiGloamingCallbacks.virelaiGloamingDidFail(error.localizedDescription)
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let virelaiGloamingURL = navigationAction.request.url,
              let virelaiGloamingScheme = virelaiGloamingURL.scheme?.lowercased() else {
            decisionHandler(.allow)
            return
        }

        if VirelaiGloamingNavigation.virelaiGloamingWebSchemes.contains(virelaiGloamingScheme) {
            decisionHandler(.allow)
        } else {
            virelaiGloamingOpenNonWebURL(virelaiGloamingURL, webView: webView)
            decisionHandler(.cancel)
        }
    }

    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        guard let virelaiGloamingURL = navigationAction.request.url else { return nil }
        if VirelaiGloamingNavigation.virelaiGloamingIsAppStore(virelaiGloamingURL) {
            UIApplication.shared.open(virelaiGloamingURL)
        } else {
            webView.load(URLRequest(url: virelaiGloamingURL))
        }
        return nil
    }

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        let virelaiGloamingBody = message.body as? [String: Any]
        let virelaiGloamingRequestID = virelaiGloamingBody?[
            VirelaiGloamingASCIICipher.virelaiGloamingReveal("sfrvftuJe")
        ] as? String
        guard let virelaiGloamingAction = VirelaiGloamingAction(rawValue: message.name) else { return }

        switch virelaiGloamingAction {
        case .virelaiGloamingClose:
            virelaiGloamingCallbacks.virelaiGloamingDidRequestClose()
        case .virelaiGloamingRecharge:
            guard let virelaiGloamingRequest = VirelaiGloamingPurchaseRequest(
                virelaiGloamingBody: message.body
            ) else {
                virelaiGloamingCallbacks.virelaiGloamingDidRejectMessage(
                    virelaiGloamingRequestID,
                    virelaiGloamingAction.rawValue
                )
                return
            }
            virelaiGloamingCallbacks.virelaiGloamingDidRequestPurchase(virelaiGloamingRequest)
        case .virelaiGloamingOpenBrowser:
            guard let virelaiGloamingRequest = VirelaiGloamingExternalRequest(
                virelaiGloamingBody: message.body
            ) else {
                virelaiGloamingCallbacks.virelaiGloamingDidRejectMessage(
                    virelaiGloamingRequestID,
                    virelaiGloamingAction.rawValue
                )
                return
            }
            virelaiGloamingCallbacks.virelaiGloamingDidRequestExternalOpen(virelaiGloamingRequest)
        }
    }

    @available(iOS 15.0, *)
    func webView(
        _ webView: WKWebView,
        requestMediaCapturePermissionFor origin: WKSecurityOrigin,
        initiatedByFrame frame: WKFrameInfo,
        type: WKMediaCaptureType,
        decisionHandler: @escaping (WKPermissionDecision) -> Void
    ) {
        decisionHandler(.grant)
    }

    private func virelaiGloamingOpenNonWebURL(_ virelaiGloamingURL: URL, webView: WKWebView) {
        UIApplication.shared.open(virelaiGloamingURL, options: [:]) { virelaiGloamingSuccess in
            let virelaiGloamingScript = VirelaiGloamingNavigation.virelaiGloamingOpenResultScript(
                state: VirelaiGloamingASCIICipher.virelaiGloamingReveal(
                    virelaiGloamingSuccess ? "tvddftt" : "gbjmfe"
                ),
                url: virelaiGloamingURL.absoluteString
            )
            DispatchQueue.main.async {
                webView.evaluateJavaScript(virelaiGloamingScript)
            }
        }
    }
}

private enum VirelaiGloamingAction: CaseIterable {
    case virelaiGloamingRecharge
    case virelaiGloamingClose
    case virelaiGloamingOpenBrowser

    init?(rawValue: String) {
        guard let virelaiGloamingAction = Self.allCases.first(where: { $0.rawValue == rawValue }) else {
            return nil
        }
        self = virelaiGloamingAction
    }

    var rawValue: String {
        switch self {
        case .virelaiGloamingRecharge:
            return VirelaiGloamingASCIICipher.virelaiGloamingReveal("sfdibshfQbz")
        case .virelaiGloamingClose:
            return VirelaiGloamingASCIICipher.virelaiGloamingReveal("Dmptf")
        case .virelaiGloamingOpenBrowser:
            return VirelaiGloamingASCIICipher.virelaiGloamingReveal("pqfoCspxtfs")
        }
    }
}

private enum VirelaiGloamingNavigation {
    static let virelaiGloamingWebSchemes: Set<String> = [
        "iuuq", "iuuqt", "gjmf", "bcpvu"
    ].reduce(into: Set<String>()) { virelaiGloamingResult, virelaiGloamingShifted in
        virelaiGloamingResult.insert(
            VirelaiGloamingASCIICipher.virelaiGloamingReveal(virelaiGloamingShifted)
        )
    }

    static func virelaiGloamingIsAppStore(_ virelaiGloamingURL: URL) -> Bool {
        let virelaiGloamingText = virelaiGloamingURL.absoluteString.lowercased()
        return virelaiGloamingURL.scheme
            == VirelaiGloamingASCIICipher.virelaiGloamingReveal("junt.bqqt")
            || virelaiGloamingURL.scheme
            == VirelaiGloamingASCIICipher.virelaiGloamingReveal("junt.tfswjdft")
            || virelaiGloamingText.contains(
                VirelaiGloamingASCIICipher.virelaiGloamingReveal("bqqt/bqqmf/dpn")
            )
    }

    static func virelaiGloamingOpenResultScript(state: String, url: String) -> String {
        let virelaiGloamingState = virelaiGloamingEscape(state)
        let virelaiGloamingURL = virelaiGloamingEscape(url)
        return VirelaiGloamingASCIICipher.virelaiGloamingReveal(
            "xjoepx/ejtqbudiFwfou)ofx!DvtupnFwfou)(obujwfPqfoTubuf(-!|!efubjm;!|!tubuf;!("
        ) + virelaiGloamingState
            + VirelaiGloamingASCIICipher.virelaiGloamingReveal("(-!vsm;!(")
            + virelaiGloamingURL
            + VirelaiGloamingASCIICipher.virelaiGloamingReveal("(!~!~**<")
    }

    private static func virelaiGloamingEscape(_ virelaiGloamingValue: String) -> String {
        virelaiGloamingValue
            .replacingOccurrences(
                of: VirelaiGloamingASCIICipher.virelaiGloamingReveal("]"),
                with: VirelaiGloamingASCIICipher.virelaiGloamingReveal("]]"))
            .replacingOccurrences(
                of: VirelaiGloamingASCIICipher.virelaiGloamingReveal("("),
                with: VirelaiGloamingASCIICipher.virelaiGloamingReveal("]("))
            .replacingOccurrences(
                of: String(UnicodeScalar(10)!),
                with: VirelaiGloamingASCIICipher.virelaiGloamingReveal("]o"))
            .replacingOccurrences(
                of: String(UnicodeScalar(13)!),
                with: VirelaiGloamingASCIICipher.virelaiGloamingReveal("]s"))
    }
}
