import SwiftUI
import Combine

enum PrismTrailPulseToastKind {
    case normal
    case error
    case success

    var voiceIconName: String {
        switch self {
        case .normal:
            return "waveform"
        case .error:
            return "xmark.circle.fill"
        case .success:
            return "checkmark.circle.fill"
        }
    }

    var voiceTintColor: Color {
        switch self {
        case .normal:
            return VoiceEchoStyleKit.prismTrailPulsePurple
        case .error:
            return Color(red: 1.0, green: 0.33, blue: 0.39)
        case .success:
            return VoiceEchoStyleKit.voiceNeonGreen
        }
    }
}

struct PrismTrailPulseToastState: Identifiable, Equatable {
    let id = UUID()
    let voiceMessage: String
    let voiceKind: PrismTrailPulseToastKind
}

struct PrismTrailPulseLoadingState: Equatable {
    let voiceMessage: String?
    let voiceShowsMask: Bool
}

@MainActor
final class PrismTrailPulseToastLoadingCenter: ObservableObject {
    static let shared = PrismTrailPulseToastLoadingCenter()

    @Published private(set) var prismTrailToastState: PrismTrailPulseToastState?
    @Published private(set) var voiceLoadingState: PrismTrailPulseLoadingState?

    private var prismTrailToastDismissWorkItem: DispatchWorkItem?

    private init() {}

    func showToast(
        _ voiceMessage: String,
        kind voiceKind: PrismTrailPulseToastKind = .normal,
        duration: TimeInterval = 1.5
    ) {
        prismTrailToastDismissWorkItem?.cancel()
        prismTrailToastState = PrismTrailPulseToastState(
            voiceMessage: voiceMessage,
            voiceKind: voiceKind
        )

        let prismTrailDismissWorkItem = DispatchWorkItem { [weak self] in
            Task { @MainActor in
                self?.hideToast()
            }
        }
        prismTrailToastDismissWorkItem = prismTrailDismissWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: prismTrailDismissWorkItem)
    }

    func hideToast() {
        prismTrailToastDismissWorkItem?.cancel()
        prismTrailToastDismissWorkItem = nil
        prismTrailToastState = nil
    }

    func showLoading(
        _ voiceMessage: String? = nil,
        showsMask: Bool = true
    ) {
        voiceLoadingState = PrismTrailPulseLoadingState(
            voiceMessage: voiceMessage,
            voiceShowsMask: showsMask
        )
    }

    func hideLoading() {
        voiceLoadingState = nil
    }
}

struct PrismTrailPulseToastLoadingOverlay: ViewModifier {
    @StateObject private var prismTrailPulseCenter = PrismTrailPulseToastLoadingCenter.shared

    func body(content: Content) -> some View {
        ZStack {
            content

            if let voiceLoadingState = prismTrailPulseCenter.voiceLoadingState {
                PrismTrailPulseLoadingOverlay(loadingState: voiceLoadingState)
                    .zIndex(20)
            }

            if let prismTrailToastState = prismTrailPulseCenter.prismTrailToastState {
                PrismTrailPulseToastDismissLayer {
                    prismTrailPulseCenter.hideToast()
                }
                .zIndex(30)

                PrismTrailPulseToastCapsule(toastState: prismTrailToastState)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .zIndex(31)
            }
        }
        .animation(.easeInOut(duration: 0.18), value: prismTrailPulseCenter.prismTrailToastState)
        .animation(.easeInOut(duration: 0.18), value: prismTrailPulseCenter.voiceLoadingState)
    }
}

extension View {
    func prismTrailPulseToastLoadingOverlay() -> some View {
        modifier(PrismTrailPulseToastLoadingOverlay())
    }
}

private struct PrismTrailPulseToastDismissLayer: View {
    let onDismiss: () -> Void

    var body: some View {
        Color.clear
            .contentShape(Rectangle())
            .ignoresSafeArea()
            .onTapGesture(perform: onDismiss)
    }
}

private struct PrismTrailPulseToastCapsule: View {
    let toastState: PrismTrailPulseToastState

    var body: some View {
        VStack {
            HStack(spacing: 10) {
                Image(systemName: toastState.voiceKind.voiceIconName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(toastState.voiceKind.voiceTintColor)

                Text(toastState.voiceMessage)
                    .font(VoiceWhisperFontKit.bold(15))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 18)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(VoiceEchoStyleKit.voiceShadowPanel.opacity(0.96))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(toastState.voiceKind.voiceTintColor.opacity(0.55), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.28), radius: 14, x: 0, y: 8)
            .padding(.top, 62)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .allowsHitTesting(false)
    }
}

private struct PrismTrailPulseLoadingOverlay: View {
    let loadingState: PrismTrailPulseLoadingState

    var body: some View {
        ZStack {
            if loadingState.voiceShowsMask {
                Color.black.opacity(0.5)
            } else {
                Color.clear
            }

            VStack(spacing: 13) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: VoiceEchoStyleKit.voiceNeonGreen))
                    .scaleEffect(1.18)

                if let voiceMessage = loadingState.voiceMessage,
                   !voiceMessage.isEmpty {
                    Text(voiceMessage)
                        .font(VoiceWhisperFontKit.bold(14))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(VoiceEchoStyleKit.voiceShadowPanel.opacity(0.96))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(VoiceEchoStyleKit.voiceNeonGreen.opacity(0.45), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.32), radius: 18, x: 0, y: 10)
        }
        .contentShape(Rectangle())
        .ignoresSafeArea()
    }
}
