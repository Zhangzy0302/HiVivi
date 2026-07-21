import Combine
import Foundation
import ScreenShield
import SwiftUI
import UIKit

struct ObsidianSereinProtectedWebPage: View {
    @StateObject private var obsidianSereinState: ObsidianSereinWebState
    @StateObject private var obsidianSereinCapture = LacustrineAubadeCaptureMonitor()
    let obsidianSereinCloseAction: () -> Void

    init(obsidianSereinAddress: String, obsidianSereinCloseAction: @escaping () -> Void) {
        _obsidianSereinState = StateObject(
            wrappedValue: ObsidianSereinWebState(obsidianSereinAddress: obsidianSereinAddress)
        )
        self.obsidianSereinCloseAction = obsidianSereinCloseAction
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if obsidianSereinState.obsidianSereinIsLoading {
                VoiceWhisperGuideBackdrop().ignoresSafeArea()
            }

            obsidianSereinWebLayer

            if obsidianSereinState.obsidianSereinIsLoading {
                ObsidianSereinLoadingLayer()
                    .transition(.opacity)
            }

            if let obsidianSereinError = obsidianSereinState.obsidianSereinError {
                ObsidianSereinFailureLayer(
                    obsidianSereinMessage: obsidianSereinError,
                    obsidianSereinRetry: obsidianSereinState.obsidianSereinRetry
                )
            }

            if obsidianSereinCapture.lacustrineAubadeIsCaptured {
                ObsidianSereinCaptureLayer()
                    .zIndex(300)
            }
        }
        .protectScreenshot()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .statusBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .voiceNativeSwipeBackDisabled()
        .animation(.easeOut(duration: 0.2), value: obsidianSereinState.obsidianSereinIsLoading)
        .onAppear {
            MadrigalFallowPushCoordinator.shared.madrigalFallowRequestAuthorization()
            obsidianSereinState.obsidianSereinActivate()
            obsidianSereinCapture.lacustrineAubadeStart()
        }
        .onDisappear {
            obsidianSereinCapture.lacustrineAubadeStop()
            obsidianSereinState.obsidianSereinDeactivate()
        }
    }

    @ViewBuilder
    private var obsidianSereinWebLayer: some View {
        if let obsidianSereinURL = obsidianSereinState.obsidianSereinURL {
            VirelaiGloamingWebSurface(
                virelaiGloamingURL: obsidianSereinURL,
                virelaiGloamingBridge: obsidianSereinState.obsidianSereinBridge,
                virelaiGloamingCallbacks: VirelaiGloamingCallbacks(
                    virelaiGloamingDidStart: obsidianSereinState.obsidianSereinLoadingStarted,
                    virelaiGloamingDidFinish: obsidianSereinState.obsidianSereinLoadingFinished,
                    virelaiGloamingDidFail: obsidianSereinState.obsidianSereinLoadingFailed,
                    virelaiGloamingDidRequestClose: obsidianSereinCloseRequested,
                    virelaiGloamingDidRequestPurchase: obsidianSereinState.obsidianSereinPurchaseRequested,
                    virelaiGloamingDidRequestExternalOpen: obsidianSereinState.obsidianSereinExternalOpenRequested,
                    virelaiGloamingDidRejectMessage: obsidianSereinState.obsidianSereinInvalidMessage
                )
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .opacity(obsidianSereinState.obsidianSereinIsLoading ? 0 : 1)
        } else {
            ObsidianSereinFailureLayer(
                obsidianSereinMessage: "Invalid web address",
                obsidianSereinRetry: obsidianSereinCloseAction
            )
        }
    }

    private func obsidianSereinCloseRequested() {
        NacreWispBInfoStore.shared.nacreWispClearSession()
        obsidianSereinCloseAction()
    }
}

private struct ObsidianSereinLoadingLayer: View {
    var body: some View {
        VStack(spacing: 18) {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.white)
                .scaleEffect(1.28)
            Text("Loading...")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.28))
        .allowsHitTesting(true)
    }
}

private struct ObsidianSereinFailureLayer: View {
    let obsidianSereinMessage: String
    let obsidianSereinRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Unable to load")
                .font(VoiceWhisperFontKit.bold(20))
                .foregroundColor(.white)
            Text(obsidianSereinMessage)
                .font(VoiceWhisperFontKit.regular(14))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            Button("Retry", action: obsidianSereinRetry)
                .font(VoiceWhisperFontKit.bold(15))
                .foregroundColor(.black)
                .frame(width: 130, height: 44)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.9))
    }
}

private struct ObsidianSereinCaptureLayer: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 14) {
                Image(systemName: "eye.slash.fill")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.white)
                Text("Screen recording not allowed")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(true)
    }
}

@MainActor
private final class ObsidianSereinWebState: ObservableObject {
    let obsidianSereinURL: URL?
    let obsidianSereinBridge = VirelaiGloamingScriptBridge()

    @Published var obsidianSereinIsLoading = true
    @Published var obsidianSereinError: String?
    private var obsidianSereinActivePurchaseID: String?

    init(obsidianSereinAddress: String) {
        obsidianSereinURL = ZephyrRuneInformationCreate.zephyrRuneResolveH5URL(obsidianSereinAddress)
    }

    func obsidianSereinActivate() {
        VoiceCoinStoreKitOneCenter.shared.voiceCoinPrepareBPackageProducts()
    }

    func obsidianSereinDeactivate() {
        obsidianSereinFinishPurchase(requestID: nil)
    }

    func obsidianSereinLoadingStarted() {
        obsidianSereinError = nil
        obsidianSereinIsLoading = true
    }

    func obsidianSereinLoadingFinished(milliseconds: Int) {
        Task { try? await AbyssalQuillApiCall().abyssalQuillLoadingTimeRecord(milliseconds) }
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 250_000_000)
            obsidianSereinIsLoading = false
        }
    }

    func obsidianSereinLoadingFailed(message: String) {
        obsidianSereinIsLoading = false
        obsidianSereinError = message
    }

    func obsidianSereinRetry() {
        obsidianSereinError = nil
        obsidianSereinIsLoading = true
        obsidianSereinBridge.virelaiGloamingReload()
    }

    func obsidianSereinPurchaseRequested(_ obsidianSereinRequest: VirelaiGloamingPurchaseRequest) {
        guard obsidianSereinActivePurchaseID == nil else {
            obsidianSereinBridge.virelaiGloamingEmit(
                event: "nativeRechargeState",
                detail: [
                    "requestId": obsidianSereinRequest.virelaiGloamingRequestID,
                    "state": "pending",
                    "coins": 0
                ]
            )
            return
        }

        obsidianSereinActivePurchaseID = obsidianSereinRequest.virelaiGloamingRequestID
        PrismTrailPulseToastLoadingCenter.shared.showLoading("Processing payment...", showsMask: true)
        VoiceCoinStoreKitOneCenter.shared.voiceCoinPurchaseForBPackage(
            productID: obsidianSereinRequest.virelaiGloamingProductID,
            orderCode: obsidianSereinRequest.virelaiGloamingOrderCode
        ) { [weak self] obsidianSereinResult in
            guard let self,
                  self.obsidianSereinActivePurchaseID == obsidianSereinRequest.virelaiGloamingRequestID else {
                return
            }
            self.obsidianSereinFinishPurchase(requestID: obsidianSereinRequest.virelaiGloamingRequestID)

            var obsidianSereinDetail: [String: Any] = [
                "requestId": obsidianSereinRequest.virelaiGloamingRequestID,
                "coins": 0
            ]
            switch obsidianSereinResult {
            case .success(let obsidianSereinCoins):
                obsidianSereinDetail["state"] = "success"
                obsidianSereinDetail["coins"] = obsidianSereinCoins
            case .cancelled:
                obsidianSereinDetail["state"] = "cancelled"
            case .pending:
                obsidianSereinDetail["state"] = "pending"
            case .failed(let obsidianSereinMessage):
                obsidianSereinDetail["state"] = "failed"
                obsidianSereinDetail["error"] = obsidianSereinMessage
            }
            self.obsidianSereinBridge.virelaiGloamingEmit(
                event: "nativeRechargeState",
                detail: obsidianSereinDetail
            )
        }
    }

    func obsidianSereinExternalOpenRequested(_ obsidianSereinRequest: VirelaiGloamingExternalRequest) {
        guard let obsidianSereinURL = URL(string: obsidianSereinRequest.virelaiGloamingURLString) else {
            obsidianSereinBridge.virelaiGloamingEmit(
                event: "nativeOpenState",
                detail: obsidianSereinExternalOpenDetail(
                    request: obsidianSereinRequest,
                    state: "failed"
                )
            )
            return
        }
        UIApplication.shared.open(obsidianSereinURL, options: [:]) { [weak self] obsidianSereinSuccess in
            self?.obsidianSereinBridge.virelaiGloamingEmit(
                event: "nativeOpenState",
                detail: self?.obsidianSereinExternalOpenDetail(
                    request: obsidianSereinRequest,
                    state: obsidianSereinSuccess ? "success" : "failed"
                ) ?? [:]
            )
        }
    }

    func obsidianSereinInvalidMessage(requestID: String?, action: String) {
        let obsidianSereinEvent = action == "openBrowser" ? "nativeOpenState" : "nativeRechargeState"
        obsidianSereinBridge.virelaiGloamingEmit(
            event: obsidianSereinEvent,
            detail: ["requestId": requestID ?? "", "state": "failed", "error": "Invalid request"]
        )
    }

    private func obsidianSereinFinishPurchase(requestID: String?) {
        if let requestID, obsidianSereinActivePurchaseID != requestID { return }
        guard obsidianSereinActivePurchaseID != nil else { return }
        obsidianSereinActivePurchaseID = nil
        PrismTrailPulseToastLoadingCenter.shared.hideLoading()
    }

    private func obsidianSereinExternalOpenDetail(
        request obsidianSereinRequest: VirelaiGloamingExternalRequest,
        state obsidianSereinState: String
    ) -> [String: Any] {
        var obsidianSereinDetail: [String: Any] = [
            "state": obsidianSereinState,
            "url": obsidianSereinRequest.virelaiGloamingURLString
        ]
        if let obsidianSereinRequestID = obsidianSereinRequest.virelaiGloamingRequestID {
            obsidianSereinDetail["requestId"] = obsidianSereinRequestID
        }
        return obsidianSereinDetail
    }
}
