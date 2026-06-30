import AVFoundation
import Combine
import SwiftUI

struct VoiceMorphAssistantPage: View {
    let isGuestUser: Bool
    let onGuestLimit: () -> Void
    let onRecharge: () -> Void
    let onBack: () -> Void

    @State private var assistNovaToneSelectedIndex = 1
    @State private var voiceCoinShowsPaymentDialog = false
    @State private var voiceCoinShowsInsufficientDialog = false
    @State private var voiceMorphCurrentUser: VoiceUserProfileData?
    @StateObject private var voiceMorphAudioPreview = VoiceMorphAudioPreviewController()

    private let voiceMorphVoices = VoiceMorphAIVoiceCatalog.all
    private let assistNovaTonePanelColor = VoiceEchoStyleKit.voiceMossPanel
    private let whisperPulseGreen = VoiceEchoStyleKit.voiceNeonGreen
    private let voiceMorphUnlockCost = 200

    init(
        isGuestUser: Bool = false,
        onGuestLimit: @escaping () -> Void = {},
        onRecharge: @escaping () -> Void = {},
        onBack: @escaping () -> Void
    ) {
        self.isGuestUser = isGuestUser
        self.onGuestLimit = onGuestLimit
        self.onRecharge = onRecharge
        self.onBack = onBack
    }

    var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { _ in
                VoiceRippleMainBackdrop()
            }

            VStack(spacing: 0) {
                HStack(spacing: 17) {
                    Button(action: onBack) {
                        Image("HIVV_back_btn")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Text("Selection Assistant")
                        .font(VoiceWhisperFontKit.bold(18))
                        .foregroundColor(.white)

                    Spacer()
                }
                .padding(.top, 10)
                .padding(.horizontal, 18)
                
                ZStack(alignment: .top){
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.fixed(60), spacing: 26), count: 4),
                        spacing: 23
                    ) {
                        ForEach(voiceMorphVoices.indices, id: \.self) { toneShiftIndex in
                            VoiceMorphAvatarButton(
                                imageName: voiceMorphVoices[toneShiftIndex].avatarName,
                                isSelected: assistNovaToneSelectedIndex == toneShiftIndex,
                                isPurchased: voiceMorphIsPurchased(voiceMorphVoices[toneShiftIndex])
                            ) {
                                assistNovaToneSelectedIndex = toneShiftIndex
                            }
                        }
                    }

                    ZStack(alignment: .top) {
                        VStack(spacing: 0) {
                            Spacer()
                                .frame(height: 57)

                            Text(selectedVoiceName)
                                .font(VoiceWhisperFontKit.bold(16))
                                .foregroundColor(whisperPulseGreen)

                            VoiceMorphAudioPreviewBubble(
                                isPlaying: voiceMorphAudioPreview.isPlaying(for: voiceMorphSelectedVoice?.id),
                                action: voiceMorphPlaySelectedPreview
                            )
                                .padding(.top, 27)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 187)
                        .background(assistNovaTonePanelColor)
                        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                        .padding(.horizontal, 21)
                        .padding(.top, 63)

                        VoiceMorphSelectedAvatar(imageName: selectedImageName)
                    }
                    .padding(.top, 187)

                }
                .padding(.top, 24)

                
                HStack(spacing: 9) {
                    Image("HIVV_coin")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 31, height: 31)

                    Text(voiceMorphSelectedVoice.map { voiceMorphIsPurchased($0) } == true ? "Owned" : "-\(voiceMorphUnlockCost)")
                        .font(VoiceWhisperFontKit.bold(18))
                        .foregroundColor(.white)
                }
                .padding(.top, 48)

                Button(action: voiceMorphSetDefaultAssistant) {
                    Text("Set Default Assistant")
                        .font(VoiceWhisperFontKit.bold(16))
                        .foregroundColor(.black)
                        .frame(width: 247, height: 48)
                        .background(whisperPulseGreen)
                        .clipShape(Capsule())
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 13)

                Spacer()
            }

            if voiceCoinShowsPaymentDialog {
                VoiceCoinPaymentDialog(
                    onCancel: {
                        voiceCoinShowsPaymentDialog = false
                    },
                    onSure: {
                        voiceCoinShowsPaymentDialog = false
                        voiceMorphConfirmPurchase()
                    }
                )
                .zIndex(20)
                .transition(.opacity)
            }

            if voiceCoinShowsInsufficientDialog {
                VoiceCoinInsufficientDialog(
                    onCancel: {
                        voiceCoinShowsInsufficientDialog = false
                    },
                    onSure: {
                        voiceCoinShowsInsufficientDialog = false
                        onRecharge()
                    }
                )
                .zIndex(21)
                .transition(.opacity)
            }
        }
        .onAppear(perform: voiceMorphReloadCurrentUser)
        .onChange(of: assistNovaToneSelectedIndex) { _ in
            voiceMorphAudioPreview.stop()
        }
        .onDisappear {
            voiceMorphAudioPreview.stop()
        }
        .animation(.easeOut(duration: 0.24), value: voiceCoinShowsPaymentDialog)
        .animation(.easeOut(duration: 0.24), value: voiceCoinShowsInsufficientDialog)
    }

    private var voiceMorphSelectedVoice: VoiceMorphAIVoicePreset? {
        guard voiceMorphVoices.indices.contains(assistNovaToneSelectedIndex) else {
            return nil
        }
        return voiceMorphVoices[assistNovaToneSelectedIndex]
    }

    private var selectedImageName: String {
        voiceMorphSelectedVoice?.avatarName ?? VoiceEchoStyleKit.voiceDefaultAvatarName
    }

    private var selectedVoiceName: String {
        voiceMorphSelectedVoice?.name ?? ""
    }

    private func voiceMorphSetDefaultAssistant() {
        guard !isGuestUser else {
            onGuestLimit()
            return
        }

        guard let voiceMorphSelectedVoice else {
            return
        }

        if voiceMorphIsPurchased(voiceMorphSelectedVoice) {
            PrismTrailPulseToastLoadingCenter.shared.showToast("Default assistant selected", kind: .success)
        } else {
            voiceCoinShowsPaymentDialog = true
        }
    }

    private func voiceMorphReloadCurrentUser() {
        guard let assistNovaCurrentUserID = SilverGardenSessionLoginStore.readCurrentUserID() else {
            voiceMorphCurrentUser = nil
            return
        }

        voiceMorphCurrentUser = VoiceUserProfileStore.read(id: assistNovaCurrentUserID)
    }

    private func voiceMorphIsPurchased(_ voiceMorphVoice: VoiceMorphAIVoicePreset) -> Bool {
        voiceMorphCurrentUser?.voiceUserPurchasedAIVoiceIDs.contains(voiceMorphVoice.id) == true
    }

    private func voiceMorphConfirmPurchase() {
        guard let voiceMorphSelectedVoice,
              let assistNovaCurrentUserID = SilverGardenSessionLoginStore.readCurrentUserID(),
              let assistNovaCurrentUser = VoiceUserProfileStore.read(id: assistNovaCurrentUserID) else {
            return
        }

        if assistNovaCurrentUser.voiceUserPurchasedAIVoiceIDs.contains(voiceMorphSelectedVoice.id) {
            PrismTrailPulseToastLoadingCenter.shared.showToast("Already owned", kind: .normal)
            voiceMorphReloadCurrentUser()
            return
        }

        guard assistNovaCurrentUser.voiceUserCoinCount >= voiceMorphUnlockCost else {
            voiceCoinShowsInsufficientDialog = true
            return
        }

        VoiceUserProfileStore.update(id: assistNovaCurrentUserID) { voiceUser in
            voiceUser.voiceUserCoinCount -= voiceMorphUnlockCost
            if !voiceUser.voiceUserPurchasedAIVoiceIDs.contains(voiceMorphSelectedVoice.id) {
                voiceUser.voiceUserPurchasedAIVoiceIDs.append(voiceMorphSelectedVoice.id)
            }
        }
        voiceMorphReloadCurrentUser()
        PrismTrailPulseToastLoadingCenter.shared.showToast("Voice unlocked", kind: .success)
    }

    private func voiceMorphPlaySelectedPreview() {
        guard let voiceMorphSelectedVoice else {
            PrismTrailPulseToastLoadingCenter.shared.showToast("Please select an AI voice", kind: .normal)
            return
        }

        guard let voiceMorphURL = VoiceMorphAIVoiceCatalog.voiceMorphAudioURL(for: voiceMorphSelectedVoice) else {
            PrismTrailPulseToastLoadingCenter.shared.showToast("Voice file not found", kind: .error)
            return
        }

        do {
            try voiceMorphAudioPreview.toggle(url: voiceMorphURL, voiceID: voiceMorphSelectedVoice.id)
        } catch {
            PrismTrailPulseToastLoadingCenter.shared.showToast("Voice playback failed", kind: .error)
        }
    }

}

@MainActor
private final class VoiceMorphAudioPreviewController: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published private var voicePlayingID: String?

    private var voiceAudioPlayer: AVAudioPlayer?

    func isPlaying(for voiceID: String?) -> Bool {
        guard let voiceID else {
            return false
        }

        return voicePlayingID == voiceID && voiceAudioPlayer?.isPlaying == true
    }

    func toggle(url voiceURL: URL, voiceID: String) throws {
        if voicePlayingID == voiceID && voiceAudioPlayer?.isPlaying == true {
            stop()
            return
        }

        stop()
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try AVAudioSession.sharedInstance().setActive(true)

        let voicePlayer = try AVAudioPlayer(contentsOf: voiceURL)
        voicePlayer.delegate = self
        voicePlayer.prepareToPlay()
        voicePlayer.play()

        voiceAudioPlayer = voicePlayer
        voicePlayingID = voiceID
    }

    func stop() {
        voiceAudioPlayer?.stop()
        voiceAudioPlayer = nil
        voicePlayingID = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
    }

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            stop()
        }
    }

    nonisolated func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        Task { @MainActor in
            stop()
        }
    }
}

private struct VoiceMorphAvatarButton: View {
    let imageName: String
    let isSelected: Bool
    let isPurchased: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomTrailing) {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(isSelected ? VoiceEchoStyleKit.voiceNeonGreen : Color.clear, lineWidth: 3)
                    )

                if isPurchased {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(VoiceEchoStyleKit.voiceNeonGreen)
                        .background(Color.black.clipShape(Circle()))
                }
            }
            .frame(width: 60, height: 60)
            .contentShape(Circle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private struct VoiceMorphSelectedAvatar: View {
    let imageName: String

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(width: 120, height: 120)
            .clipShape(Circle())
    }
}

private struct VoiceMorphAudioPreviewBubble: View {
    let isPlaying: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 11) {
                HStack(spacing: 3) {
                    ForEach(0..<18, id: \.self) { assistNovaWaveIndex in
                        RoundedRectangle(cornerRadius: 1)
                            .fill(Color.white)
                            .frame(width: 2, height: CGFloat([6, 12, 9, 17, 7, 14][assistNovaWaveIndex % 6]))
                    }
                }

                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.25))
                        .frame(width: 32, height: 32)

                    Circle()
                        .fill(Color.white.opacity(0.16))
                        .frame(width: 42, height: 42)

                    Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.leading, 27)
            .padding(.trailing, 12)
            .frame(width: 184, height: 50)
            .background(Color.white.opacity(0.13))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview("Voice Morph - Assistant") {
    let _ = VoiceWhisperFontKit.registerFonts()
    VoiceMorphAssistantPage {}
}
